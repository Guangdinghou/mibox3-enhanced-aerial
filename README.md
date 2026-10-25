# 小米盒子 3 增强版 Aerial 改造手册

这是针对 **小米盒子 3 增强版 MDZ-18-AA / MiBOX3_PRO / Android 5.1** 的实机流程，覆盖备份、ROOT、预装应用清理、Aerial 桌面接管、验证和恢复。

> 这是高风险、设备专用项目，不是通用电视优化工具。型号、系统或分区检查不匹配时必须停止。

## 快速开始

1. 安装 Android Platform Tools，使用 USB 数据线连接盒子并开启 ADB 调试。
2. 运行 `scripts/00-doctor.sh`，确认所有只读检查通过。
3. 运行 `scripts/10-backup.sh`，再用 `scripts/11-verify-backup.sh` 校验备份。
4. 阅读 [安全说明](docs/safety.md) 和每个阶段的专项文档，再单独执行对应脚本。
5. 每次修改后运行 `scripts/90-verify.sh`，并完成人工遥控、播放和开机检查。

脚本不会把所有危险步骤串成一次执行。第三方 APK 和提权文件不在仓库中，必须通过固定来源下载并通过 SHA-256 校验。

## 文档

- [兼容性](docs/compatibility.md)
- [安全边界](docs/safety.md)
- [设计](docs/2026-10-25-design.md)
- [实施计划](docs/plans/2026-10-25-implementation.md)

## 恢复原则

按 `桌面 → 应用 → ROOT` 的逆序恢复。不要把其他固件的启动或系统镜像刷入本机。

## 许可证

MIT。第三方资源受各自许可证约束，本仓库不重新分发它们。

