# 小米盒子 3 增强版 Aerial 改造项目实施计划

> **执行者要求：** 按任务逐项实现和审查；每一步使用复选框跟踪。

**目标：** 建立一个可公开复用、设备严格限定、带完整恢复与验证能力的 MiBOX3_PRO 改造仓库。

**架构：** 使用 POSIX Shell 编排 ADB 和设备端命令，以 `lib/guard.sh` 统一执行设备门禁、确认、日志与哈希校验。所有写操作按阶段拆开，状态写入忽略目录，Python `unittest` 使用伪 ADB 验证拒绝路径和命令顺序。

**技术栈：** Bash、ADB、Android 5.1 shell、Python 3 标准库、Markdown。

**设计：** `docs/2026-10-25-design.md`

## 全局约束

- 只支持 `MiBOX3_PRO`、Android 5.1/SDK 22 和文档固定固件族。
- 不提交任何 APK、提权二进制、分区镜像、密钥或设备唯一标识。
- 所有危险操作必须在备份与设备门禁成功后执行，并具备对应恢复步骤。
- 每个包单独执行 Android 包管理命令；任何失败立即停止。
- Aerial 成为可用 HOME 且人工确认前，不得停用 `com.mitv.tvhome`。

## 审查重点

- 同名但不同型号或 SDK 的设备必须在任何写操作前被拒绝。
- 缺失、截断或哈希不符的启动分区备份必须阻止永久 ROOT。
- ADB 中断后再次运行不得重复破坏性写入，必须根据阶段状态安全退出。
- 包名清单中的空格、Shell 元字符和核心包必须被拒绝。
- 日志与示例输出不得泄漏序列号、IP、Wi-Fi 名称、Android ID 或 ADB 密钥路径。

---

### 任务 1：仓库骨架与公开边界

**文件：**
- 创建：`README.md`
- 创建：`LICENSE`
- 创建：`.gitignore`
- 创建：`docs/safety.md`
- 创建：`docs/compatibility.md`
- 创建：`change.md`
- 测试：`tests/test_public_tree.py`

**产出：** 用户入口、风险边界、目标设备矩阵、忽略规则和敏感文件扫描。

- [ ] 编写失败测试，断言仓库不存在 APK、镜像、ADB 密钥和疑似设备标识。
- [ ] 运行 `python3 -m unittest tests.test_public_tree -v`，确认测试先失败。
- [ ] 创建仓库骨架、MIT 许可证、中文 README、兼容性与安全文档。
- [ ] 再次运行测试，确认通过。
- [ ] 在 `change.md` 记录本任务变更。

### 任务 2：共享设备门禁与伪 ADB 测试框架

**文件：**
- 创建：`lib/guard.sh`
- 创建：`tests/fake_adb.py`
- 创建：`tests/test_guard.py`
- 创建：`scripts/00-doctor.sh`

**接口：**
- 产出：`require_adb`、`read_device_facts`、`require_target_device`、`require_confirmation`、`sha256_file`、`run_device_step`。

- [ ] 为型号、SDK、芯片、ADB 缺失和确认语句编写失败测试。
- [ ] 运行目标测试并确认失败原因来自尚未实现的门禁。
- [ ] 实现共享门禁与只读诊断脚本，输出自动遮蔽后的报告。
- [ ] 补充审查重点中的相似型号与敏感字段测试。
- [ ] 运行全部测试并在 `change.md` 记录结果。

### 任务 3：备份、清单和完整性验证

**文件：**
- 创建：`scripts/10-backup.sh`
- 创建：`scripts/11-verify-backup.sh`
- 创建：`docs/backup-and-recovery.md`
- 测试：`tests/test_backup.py`

**接口：**
- 消费：任务 2 的设备门禁和哈希函数。
- 产出：时间戳备份目录、`manifest.sha256`、`device-facts.redacted.txt` 与备份通过标记。

- [ ] 编写缺失文件、零字节镜像和哈希不符测试。
- [ ] 实现包、设置、属性、分区信息、启动文件与关键镜像备份。
- [ ] 实现独立验证脚本，只有全部通过才生成通过标记。
- [ ] 使用伪 ADB 验证失败中断及重复执行行为。
- [ ] 运行全部测试并更新 `change.md`。

### 任务 4：第三方资源获取与校验

**文件：**
- 创建：`sources.lock`
- 创建：`scripts/20-fetch-assets.sh`
- 创建：`docs/sources.md`
- 测试：`tests/test_sources.py`

**接口：**
- 产出：忽略目录 `downloads/` 中经过 SHA-256 验证的固定版本资源。

- [ ] 编写未知版本、重定向异常、哈希不符与离线缓存测试。
- [ ] 写入本次使用的 Aerial、临时 ROOT、SuperSU 来源元数据和哈希。
- [ ] 实现下载、缓存复用和逐文件校验，校验失败删除不可信临时文件。
- [ ] 运行全部测试并更新 `change.md`。

### 任务 5：临时 ROOT 探测与永久 ROOT 安装/撤销

**文件：**
- 创建：`scripts/30-test-temp-root.sh`
- 创建：`scripts/31-install-permanent-root.sh`
- 创建：`scripts/39-remove-permanent-root.sh`
- 创建：`docs/root.md`
- 测试：`tests/test_root_flow.py`

**接口：**
- 消费：备份通过标记及已校验资源。
- 产出：ROOT 阶段日志、安装清单和可验证撤销步骤。

- [ ] 为缺失备份、分区不符、SELinux 未恢复、空间不足和二次执行编写测试。
- [ ] 实现最小临时 ROOT 身份验证并清除设备端暂存文件。
- [ ] 根据本次实机步骤实现 system-mode SuperSU 安装，保留原厂恢复/TEE 启动链。
- [ ] 实现按安装清单撤销，不对未知文件执行删除。
- [ ] 运行伪设备测试和 Shell 语法检查，更新 `change.md`。

### 任务 6：设备专用清理与逐项恢复

**文件：**
- 创建：`config/disable.txt`
- 创建：`config/remove-user0.txt`
- 创建：`config/keep.txt`
- 创建：`scripts/40-debloat.sh`
- 创建：`scripts/49-restore-apps.sh`
- 创建：`docs/apps.md`
- 测试：`tests/test_debloat.py`

**接口：**
- 产出：逐包执行日志、操作前 APK 备份、恢复清单和状态差异。

- [ ] 为非法包名、核心包、保留包、缺失 APK 备份和部分失败编写测试。
- [ ] 写入本次四项停用、十项用户卸载、相册停用及保留应用清单。
- [ ] 实现逐包操作、每步核对、失败即停和恢复顺序。
- [ ] 验证影视仓、电视管家、云视听、乐播、米家和高清播放器永不进入清理集合。
- [ ] 运行全部测试并更新 `change.md`。

### 任务 7：Aerial 安装、布局与小米桌面接管

**文件：**
- 创建：`config/aerial-layout.xml`
- 创建：`scripts/50-install-aerial.sh`
- 创建：`scripts/51-configure-aerial.sh`
- 创建：`scripts/52-disable-stock-home.sh`
- 创建：`scripts/59-restore-launchers.sh`
- 创建：`docs/aerial.md`
- 测试：`tests/test_launcher_flow.py`

**接口：**
- 产出：Aerial 安装与布局状态、HOME 验证记录、原厂桌面恢复入口。

- [ ] 为 APK 未校验、Aerial 未声明 HOME、守护未绑定、原桌面过早停用和布局恢复编写测试。
- [ ] 实现 Aerial 安装、应用顺序、屏保和窄范围设置写入。
- [ ] 将停用小米桌面拆成独立脚本，要求 Aerial 前台截图确认和精确确认语句。
- [ ] 实现恢复原桌面、关闭守护、恢复原屏保和恢复布局。
- [ ] 运行全部测试并更新 `change.md`。

### 任务 8：重启验证、人工验收与总恢复编排

**文件：**
- 创建：`scripts/90-verify.sh`
- 创建：`scripts/99-restore-all.sh`
- 创建：`docs/checklist.md`
- 创建：`docs/troubleshooting.md`
- 测试：`tests/test_verify_restore.py`

**接口：**
- 消费：前面各阶段的状态清单与恢复脚本。
- 产出：机器可读验证结果、中文人工验收清单和逆序恢复编排。

- [ ] 编写 ROOT 丢失、SELinux 异常、包被固件恢复、Aerial 未前台及 ADB 中断测试。
- [ ] 实现重启前后状态快照与差异报告，不自动替代真实遥控和播放验证。
- [ ] 实现按 `launcher → apps → root` 逆序恢复，每阶段均可停止并复核。
- [ ] 补齐已知故障：ADB 重启后消失、安装确认弹窗、无障碍因强停被移除、Home 黑屏。
- [ ] 运行全部测试、Shell 语法检查和敏感信息扫描，更新 `change.md`。

### 任务 9：真实设备演练与发布前审查

**文件：**
- 修改：`README.md`
- 修改：`docs/checklist.md`
- 修改：`change.md`

- [ ] 在当前 MiBOX3_PRO 上依次运行只读诊断、备份验证和状态验证。
- [ ] 对任何写操作使用已有状态做幂等性演练，不重复刷写已安装 ROOT。
- [ ] 用真实遥控验证方向、返回、主页和常用片源，记录不含隐私的结果。
- [ ] 执行完整离线测试与敏感信息扫描。
- [ ] 初始化独立 Git 仓库，检查仅包含可公开文件，不自动推送远端。
