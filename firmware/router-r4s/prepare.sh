#!/bin/bash
# router-r4s 设备定制：LAN 网段/主机名/时区/NTP/镜像命名（在 OpenWrt 树根执行）
set -e
sed -i 's/192.168.1.1/192.168.8.1/g' package/base-files/files/bin/config_generate
sed -i "s/hostname='OpenWrt'/hostname='Router-R4S'/g" package/base-files/files/bin/config_generate
sed -i "s/'UTC'/'CST-8'/g" package/base-files/files/bin/config_generate
sed -i "/'CST-8'/a \\\t\tset system.@system[-1].zonename='Asia/Shanghai'" package/base-files/files/bin/config_generate
sed -i "s/0.openwrt.pool.ntp.org/ntp.aliyun.com/" package/base-files/files/bin/config_generate
sed -i "s/1.openwrt.pool.ntp.org/time.asia.apple.com/" package/base-files/files/bin/config_generate
sed -i "s/2.openwrt.pool.ntp.org/ntp.tencent.com/" package/base-files/files/bin/config_generate
sed -i "s/3.openwrt.pool.ntp.org/cn.ntp.org.cn/" package/base-files/files/bin/config_generate
sed -i 's/VERSION_NICK:="[^"]*"/VERSION_NICK:="H-i-H build $(shell TZ=UTC-8 date +%Y.%m.%d)"/' include/version.mk
sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=$(shell date +%Y%m%d)-HiH-$(VERSION_DIST_SANITIZED)/' include/image.mk
