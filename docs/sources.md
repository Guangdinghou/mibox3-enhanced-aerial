# 第三方资源

`sources.lock` 自动获取并校验 Aerial v1.47 与固定提交中的 ARM64 `mtk-su64`。`mtk-su` 是闭源可执行文件，来源和哈希一致不等于经过源码审计。

SuperSU 2.82-SR3 因历史分发不稳定，不由脚本从镜像站自动下载。使用者须自行取得可信的原始包，核对管理器版本、签名证书和 ARM64 核心，将以下文件放入 `downloads/supersu/`：

- `SuperSU.apk`
- `su`
- `supolicy`
- `libsupol.so`
- `install-recovery-upstream.sh`

本次实机管理器证书 SHA-256 为 `e9851fc178f6c013b182f0f3fabe34dcbcbcf5067ef93e7989cfdad9e8bc57c2`。不要混用不同 SuperSU 版本的管理器和核心。

