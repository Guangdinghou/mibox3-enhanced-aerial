import os
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FAKE_ADB = ROOT / "tests" / "fake_adb.py"


def run_doctor(**overrides):
    env = os.environ.copy()
    env.update({"ADB": str(FAKE_ADB), "NONINTERACTIVE": "1"})
    env.update(overrides)
    return subprocess.run(
        ["bash", str(ROOT / "scripts" / "00-doctor.sh")],
        cwd=ROOT,
        env=env,
        text=True,
        capture_output=True,
    )


class GuardTests(unittest.TestCase):
    def test_matching_device_passes(self):
        result = run_doctor()
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertIn("设备检查通过", result.stdout)

    def test_similar_model_is_rejected(self):
        result = run_doctor(FAKE_MODEL="MiBOX3S")
        self.assertNotEqual(0, result.returncode)
        self.assertIn("型号不匹配", result.stderr)

    def test_wrong_sdk_is_rejected(self):
        result = run_doctor(FAKE_SDK="28")
        self.assertNotEqual(0, result.returncode)
        self.assertIn("SDK 不匹配", result.stderr)

    def test_wrong_platform_is_rejected(self):
        result = run_doctor(FAKE_PLATFORM="amlogic")
        self.assertNotEqual(0, result.returncode)
        self.assertIn("平台不匹配", result.stderr)


if __name__ == "__main__":
    unittest.main()
