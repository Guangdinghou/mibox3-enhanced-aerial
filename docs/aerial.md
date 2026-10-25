# Aerial 桌面

1. 用 `20-fetch-assets.sh` 下载并校验 Aerial v1.47 标准版。
2. `50-install-aerial.sh` 安装并打开桌面，电视端出现安装确认时需人工允许。
3. 人工检查网格和遥控后，运行 `51-configure-aerial.sh <备份目录>` 写入排序、屏保和桌面守护。
4. 用真实遥控器从应用按返回和主页，确认能回到 Aerial。
5. 最后单独运行 `52-disable-stock-home.sh` 可逆停用小米桌面。

Android 5.1 在强制停止 Aerial 后会移除其无障碍服务，所以布局写入必须先停止进程、最后再启用守护。停用小米桌面与 Aerial 官方保守建议不同，只应在 USB ADB 可恢复且真实遥控验证通过后进行。

异常时首先运行 `59-restore-launchers.sh`，不要删除小米桌面系统 APK。

