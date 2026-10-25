import hashlib
import os
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def run_script(name, *args, env=None):
    merged = os.environ.copy()
    if env:
        merged.update(env)
    return subprocess.run(
        ["bash", str(ROOT / "scripts" / name), *args],
        cwd=ROOT,
        env=merged,
        text=True,
        capture_output=True,
    )


class WorkflowTests(unittest.TestCase):
    def test_backup_verifier_accepts_complete_manifest(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            for name in ("packages.txt", "disabled.txt", "getprop.txt", "settings-system.txt", "partition-map.txt"):
                (root / name).write_text(name, encoding="utf-8")
            lines = []
            for path in sorted(root.iterdir()):
                digest = hashlib.sha256(path.read_bytes()).hexdigest()
                lines.append(f"{digest}  {path.name}\n")
            (root / "manifest.sha256").write_text("".join(lines), encoding="utf-8")
            result = run_script("11-verify-backup.sh", str(root))
            self.assertEqual(0, result.returncode, result.stderr)
            self.assertTrue((root / ".verified").exists())

    def test_backup_verifier_rejects_zero_byte_required_file(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            for name in ("packages.txt", "disabled.txt", "getprop.txt", "settings-system.txt", "partition-map.txt"):
                (root / name).write_text("" if name == "packages.txt" else name, encoding="utf-8")
            (root / "manifest.sha256").write_text("invalid  packages.txt\n", encoding="utf-8")
            result = run_script("11-verify-backup.sh", str(root))
            self.assertNotEqual(0, result.returncode)
            self.assertIn("空文件", result.stderr)

    def test_debloat_lists_are_safe_and_disjoint(self):
        result = run_script("40-debloat.sh", "--check-lists")
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertIn("清单检查通过", result.stdout)

    def test_launcher_guard_requires_explicit_confirmation(self):
        result = run_script(
            "52-disable-stock-home.sh",
            env={"ADB": str(ROOT / "tests" / "fake_adb.py"), "NONINTERACTIVE": "1"},
        )
        self.assertNotEqual(0, result.returncode)
        self.assertIn("确认语句", result.stderr)

    def test_restore_all_dry_run_has_safe_reverse_order(self):
        result = run_script("99-restore-all.sh", "--dry-run")
        self.assertEqual(0, result.returncode, result.stderr)
        lines = [line for line in result.stdout.splitlines() if line.startswith("恢复：")]
        self.assertEqual(["恢复：桌面", "恢复：应用", "恢复：ROOT"], lines)

    def test_permanent_root_uses_verified_temporary_root_binary(self):
        result = run_script("31-install-permanent-root.sh", "--dry-run")
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertIn("mtk-su64 -c", result.stdout)
        self.assertNotIn("shell su -c", result.stdout)

    def test_every_public_script_supports_help(self):
        expected = {
            "00-doctor.sh", "10-backup.sh", "11-verify-backup.sh", "20-fetch-assets.sh",
            "30-test-temp-root.sh", "31-install-permanent-root.sh", "39-remove-permanent-root.sh",
            "40-debloat.sh", "49-restore-apps.sh", "50-install-aerial.sh",
            "51-configure-aerial.sh", "52-disable-stock-home.sh", "59-restore-launchers.sh",
            "90-verify.sh", "99-restore-all.sh",
        }
        for name in expected:
            with self.subTest(name=name):
                result = run_script(name, "--help")
                self.assertEqual(0, result.returncode, f"{name}: {result.stderr}")


if __name__ == "__main__":
    unittest.main()
