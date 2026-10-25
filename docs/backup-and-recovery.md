# 备份与恢复

`10-backup.sh` 生成基础状态备份，`11-verify-backup.sh` 逐文件校验。永久 ROOT 前还必须在临时 ROOT 下把 `boot`、`recovery`、`system` 分区及 `/system/etc/install-recovery.sh` 保存到同一目录，重新生成清单，再运行 `11-verify-backup.sh --root <目录>`。只有四项 ROOT 备份都存在、非空、列入清单且哈希一致时才生成 `.root-verified` 门禁。

分区路径必须从本机 `/proc/partitions`、挂载表和 `/dev/block/platform/` 实际映射确认，不能照抄另一台机器。镜像应在设备端和电脑端分别计算 SHA-256 并一致。`system.img` 约 1 GiB，先确认两端空间。

恢复顺序为桌面、应用、ROOT。完整分区镜像是灾难恢复材料，本项目不会自动刷写它们；刷错分区比缺少 ROOT 更严重。

