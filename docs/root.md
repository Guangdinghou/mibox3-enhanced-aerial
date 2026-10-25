# ROOT 流程

## 临时 ROOT

先运行资源下载，再执行 `30-test-temp-root.sh`。脚本只运行身份检查，删除设备暂存文件，并要求 SELinux 回到 Enforcing。

## 永久 ROOT

永久方案复刻本次验证过的 SuperSU 2.82 system-mode 路径：复制 `su`、`daemonsu`、`supolicy` 和 `libsupol`，保存原版 `app_process64`，通过启动别名运行守护进程，并把厂家原始 recovery/TEE 脚本串接为第二段。

执行 `31-install-permanent-root.sh <备份目录>` 前必须满足：完整镜像存在且校验通过、SuperSU 资源人工验签、USB ADB 稳定、能够物理接触盒子。脚本使用经过锁定哈希的 `mtk-su64` 执行首次系统写入，不依赖尚不存在的 `su`。

撤销脚本只删除本项目安装清单内文件并恢复原版别名。系统升级或恢复出厂前应先撤销 ROOT。

