import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class PublicTreeTests(unittest.TestCase):
    def test_required_public_files_exist(self):
        for relative in (
            "README.md",
            "LICENSE",
            ".gitignore",
            "change.md",
            "docs/safety.md",
            "docs/compatibility.md",
        ):
            self.assertTrue((ROOT / relative).is_file(), relative)

    def test_private_artifacts_are_ignored(self):
        ignored = (ROOT / ".gitignore").read_text(encoding="utf-8").splitlines()
        for pattern in ("backup/", "downloads/", "work/", "shots/", "tools/adbkey/"):
            self.assertIn(pattern, ignored)

    def test_tracked_tree_has_no_private_binary(self):
        forbidden = {".apk", ".img", ".bin", ".key", ".pem"}
        bad = [str(p.relative_to(ROOT)) for p in ROOT.rglob("*") if p.is_file() and p.suffix.lower() in forbidden]
        self.assertEqual([], bad)

    def test_public_text_has_no_obvious_device_identifier(self):
        serial = re.compile(r"\b[0-9A-F]{12,}\b")
        findings = []
        for path in ROOT.rglob("*"):
            if not path.is_file() or ".git" in path.parts or ".superpowers" in path.parts:
                continue
            try:
                text = path.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                continue
            if serial.search(text):
                findings.append(str(path.relative_to(ROOT)))
        self.assertEqual([], findings)


if __name__ == "__main__":
    unittest.main()
