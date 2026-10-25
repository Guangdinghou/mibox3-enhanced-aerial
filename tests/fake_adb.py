#!/usr/bin/env python3
import os
import sys


args = sys.argv[1:]
if args[:1] == ["devices"]:
    print("List of devices attached\nFAKE\tdevice")
    raise SystemExit(0)
if args[:1] == ["get-state"]:
    print("device")
    raise SystemExit(0)
if args[:1] != ["shell"]:
    raise SystemExit(2)

command = " ".join(args[1:])
values = {
    "getprop ro.product.model": os.getenv("FAKE_MODEL", "MiBOX3_PRO"),
    "getprop ro.build.version.sdk": os.getenv("FAKE_SDK", "22"),
    "getprop ro.board.platform": os.getenv("FAKE_PLATFORM", "mt8173"),
    "getprop ro.product.device": os.getenv("FAKE_DEVICE", "kungfupanda"),
}
for key, value in values.items():
    if command == key:
        print(value)
        raise SystemExit(0)
if command == "id":
    print("uid=2000(shell) gid=2000(shell)")
    raise SystemExit(0)
print(os.getenv("FAKE_DEFAULT_OUTPUT", ""))
