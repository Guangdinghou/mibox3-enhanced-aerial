# 小米盒子 3 增强版：ROOT、精简与 Aerial 桌面

一套经过真实设备验证、面向普通用户的中文改造流程，适用于：

> **小米盒子 3 增强版 MDZ-18-AA · MiBOX3_PRO · Android 5.1 / SDK 22 · MT8173**

它把原本需要手工执行的大量 ADB 命令整理成中文向导，覆盖设备检查、完整备份、临时与永久 ROOT、预装应用精简、Aerial 桌面接管、重启验收和分阶段恢复。

> [!CAUTION]
> 这是高风险、设备专用项目，不是通用 Android TV 优化工具。型号、SDK、芯片或分区布局有任何一项不同，都不要继续。ROOT 和系统修改可能导致设备无法启动。

## 最终效果

- 使用开源 [Aerial](https://github.com/pengchujin/aerial-tv) 替代带推荐内容的小米桌面。
- 返回键和主页键直接回到 Aerial，重启后仍然生效。
- 保留影视仓、电视管家、云视听小电视、乐播/无线投屏、米家和高清播放器。
- 可选清理体感总动员、电视商城、时尚画报、游戏、购物、音乐等预装应用。
- SuperSU 2.82 system-mode ROOT 可跨重启保留，SELinux 保持 Enforcing。
- 所有阶段都有检查、记录和对应恢复入口。

## 它如何保护你的盒子

```text
设备识别 → 基础备份 → 完整镜像校验 → ROOT → 应用清理 → Aerial → 重启验收
    ↑                                                               ↓
    └────────────── 桌面 → 应用 → ROOT，按逆序分阶段恢复 ────────────┘
```

- 危险操作不会无人值守地连续执行，每个阶段都需要人工确认。
- 永久 ROOT 前强制检查 boot、recovery、system 镜像和原厂恢复脚本的 SHA-256。
- 清理应用前先备份 APK，一次只处理一个包，失败立即停止。
- Aerial 未确认可用前，不允许停用小米原桌面。
- 仓库不包含 APK、ROOT 二进制、设备镜像、ADB 密钥或个人信息。

## 快速开始

### 普通用户一键向导

| 系统 | 准备工作 | 启动方式 |
|---|---|---|
| Windows | 安装 Android Platform Tools 和 Git for Windows | 双击 `start.cmd` |
| macOS | 安装 Android Platform Tools | 双击 `start.command`，或执行 `bash start.sh` |
| Linux | 安装 Android Platform Tools | 执行 `bash start.sh` |

向导按阶段显示中文菜单，不会无人值守地连续 ROOT 或删除应用。涉及系统写入时仍会要求输入精确确认语句，这是防止选错设备和误操作的必要门禁。

启动后会看到：

```text
1. 设备检查       4. 临时 ROOT      7. Aerial 桌面
2. 备份           5. 永久 ROOT      8. 状态验证
3. 下载资源       6. 应用清理       9. 完整恢复
```

### 手动分阶段

1. 安装 Android Platform Tools，使用 USB 数据线连接盒子并开启 ADB 调试。
2. 运行 `scripts/00-doctor.sh`，确认所有只读检查通过。
3. 运行 `scripts/10-backup.sh`，再用 `scripts/11-verify-backup.sh` 校验备份。
4. 阅读 [安全说明](docs/safety.md) 和每个阶段的专项文档，再单独执行对应脚本。
5. 每次修改后运行 `scripts/90-verify.sh`，并完成人工遥控、播放和开机检查。

脚本不会把所有危险步骤串成一次执行。第三方 APK 和提权文件不在仓库中，必须通过固定来源下载并通过 SHA-256 校验。

## 使用前必须知道

1. 准备可靠的 USB 数据线，并确保能够进入盒子的开发者选项。
2. ROOT 前预留足够空间保存约 1 GiB 的 system 镜像及 boot、recovery 镜像。
3. ADB 安装可能在电视上弹出确认窗口，需要使用真实遥控器允许。
4. 每次重启后 USB ADB 可能消失，可在开发者选项中关闭再打开调试。
5. 不要从其他型号或其他固件复制启动、恢复或系统镜像。

## 项目结构

| 路径 | 用途 |
|---|---|
| `start.*` | Windows、macOS、Linux 中文向导入口 |
| `scripts/` | 按顺序编号的检查、备份、ROOT、清理、桌面和恢复脚本 |
| `config/` | 停用、用户级清理、保留应用与 Aerial 布局清单 |
| `assets/` | 可审查的设备端安装脚本，不包含二进制 |
| `docs/` | 风险、来源、恢复、验收和故障排查文档 |
| `tests/` | 离线设备模拟、安全门禁和恢复顺序测试 |

## 文档

- [兼容性](docs/compatibility.md)
- [安全边界](docs/safety.md)
- [备份与恢复](docs/backup-and-recovery.md)
- [第三方资源](docs/sources.md)
- [ROOT](docs/root.md)
- [应用清理](docs/apps.md)
- [Aerial 桌面](docs/aerial.md)
- [验收清单](docs/checklist.md)
- [故障排查](docs/troubleshooting.md)
- [设计](docs/2026-10-25-design.md)
- [实施计划](docs/plans/2026-10-25-implementation.md)

## 恢复原则

按 `桌面 → 应用 → ROOT` 的逆序恢复。不要把其他固件的启动或系统镜像刷入本机。

紧急情况下优先运行：

```bash
# Home 黑屏或无法返回桌面
scripts/59-restore-launchers.sh

# 查看完整恢复顺序，不执行修改
scripts/99-restore-all.sh --dry-run
```

## 验证状态

- 真实设备完成过永久 ROOT、应用精简、Aerial 接管和多轮重启验证。
- 当前公开脚本通过 19 项离线测试和全部 Shell 语法检查。
- Windows 向导入口已提供；发布前仍建议在 Windows 电脑和另一台同固件设备上进行一次从零演练。

运行测试：

```bash
python3 -m unittest discover -s tests -v
```

## 许可证

MIT。第三方资源受各自许可证约束，本仓库不重新分发它们。

