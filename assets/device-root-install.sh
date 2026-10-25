#!/system/bin/sh
# 在 mtk-su 临时 ROOT 中运行；仅适用于本项目锁定的设备。
set -e
[ "$(getprop ro.product.model)" = MiBOX3_PRO ]
[ "$(getprop ro.build.version.sdk)" = 22 ]
SRC=/data/local/tmp/mibox-root
[ -s "$SRC/install-recovery-original.sh" ]
[ ! -e /system/xbin/su ]
[ ! -e /system/bin/app_process64_original ]
mount -o remount,rw /system
cp "$SRC/su" /system/xbin/su
cp "$SRC/su" /system/xbin/daemonsu
cp "$SRC/supolicy" /system/xbin/supolicy
cp "$SRC/libsupol.so" /system/lib64/libsupol.so
chown 0:0 /system/xbin/su /system/xbin/daemonsu /system/xbin/supolicy /system/lib64/libsupol.so
chmod 755 /system/xbin/su /system/xbin/daemonsu /system/xbin/supolicy
chmod 644 /system/lib64/libsupol.so
chcon u:object_r:system_file:s0 /system/xbin/su /system/xbin/daemonsu /system/xbin/supolicy /system/lib64/libsupol.so
mkdir /system/bin/.ext
cp "$SRC/su" /system/bin/.ext/.su
chmod 755 /system/bin/.ext /system/bin/.ext/.su
chcon u:object_r:system_file:s0 /system/bin/.ext /system/bin/.ext/.su
cp "$SRC/install-recovery-original.sh" /system/etc/install-recovery-2.sh
chmod 750 /system/etc/install-recovery-2.sh
chcon u:object_r:install_recovery_exec:s0 /system/etc/install-recovery-2.sh
cp "$SRC/install-recovery-upstream.sh" /system/etc/install-recovery.sh
chmod 755 /system/etc/install-recovery.sh
chcon u:object_r:system_file:s0 /system/etc/install-recovery.sh
cp /system/bin/app_process64 /system/bin/app_process_init
chown 0:2000 /system/bin/app_process_init
chmod 755 /system/bin/app_process_init
chcon u:object_r:system_file:s0 /system/bin/app_process_init
mv /system/bin/app_process64 /system/bin/app_process64_original
ln -s /system/xbin/daemonsu /system/bin/app_process64
rm /system/bin/app_process
ln -s /system/xbin/daemonsu /system/bin/app_process
rm /system/bin/install-recovery.sh
ln -s /system/etc/install-recovery.sh /system/bin/install-recovery.sh
/system/xbin/su --install
sync
mount -o remount,ro /system
/system/xbin/daemonsu --auto-daemon &
echo PERMANENT_ROOT_FILES_INSTALLED
