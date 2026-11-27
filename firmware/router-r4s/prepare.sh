#!/bin/bash
# router-r4s 定制：LAN 网段/主机名/时区/NTP/镜像命名（在 OpenWrt 树根执行）
set -e
sed -i 's/192.168.1.1/192.168.8.1/g' package/base-files/files/bin/config_generate
sed -i "s/hostname='OpenWrt'/hostname='Router-R4S'/g" package/base-files/files/bin/config_generate
sed -i "s/'UTC'/'CST-8'/g" package/base-files/files/bin/config_generate
sed -i "/'CST-8'/a \\\t\tset system.@system[-1].zonename='Asia/Shanghai'" package/base-files/files/bin/config_generate
sed -i "s/0.openwrt.pool.ntp.org/ntp.aliyun.com/" package/base-files/files/bin/config_generate
sed -i "s/1.openwrt.pool.ntp.org/time.asia.apple.com/" package/base-files/files/bin/config_generate
sed -i "s/2.openwrt.pool.ntp.org/ntp.tencent.com/" package/base-files/files/bin/config_generate
sed -i "s/3.openwrt.pool.ntp.org/cn.ntp.org.cn/" package/base-files/files/bin/config_generate
# 版本号带日期：$(shell ...) 才被 make 执行（原 $(...) 是坑）
sed -i 's/VERSION_NICK:="[^"]*"/VERSION_NICK:="H-i-H build $(shell TZ=UTC-8 date +%Y.%m.%d)"/' include/version.mk
sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=$(shell date +%Y%m%d)-HiH-$(VERSION_DIST_SANITIZED)/' include/image.mk

# 修复 7dollar：ucode 预编译找不到自定义模块，补 dynlink 留给运行时
sed -i 's/dynlink=uloop/dynlink=uloop,dynlink=luci.7dollar/' feeds/luci/luci.mk
grep -q 'dynlink=luci.7dollar' feeds/luci/luci.mk || {
    echo "错误：luci.mk 补丁未生效" >&2; exit 1
}

# ttyd 与 libwebsockets 5.1 兼容：监听 7681 后立刻退出（上游 fddd638）
D=$(dirname "$0")
mkdir -p feeds/packages/utils/ttyd/patches
cp "$D/patches/ttyd-libuv-loop.patch" feeds/packages/utils/ttyd/patches/
test -s feeds/packages/utils/ttyd/patches/ttyd-libuv-loop.patch

# 更新脚本写入本设备短名（匹配发布资产用）
DEVNAME=$(basename "$(dirname "$0")")
sed -i "s|@DEVICE@|$DEVNAME|" "$D/files/usr/bin/hih-update"
grep -q "$DEVNAME" "$D/files/usr/bin/hih-update"
