#!/bin/bash
# 全设备共享的构建修复（在 OpenWrt 树根执行）
set -e
D=$(dirname "$0")

# Go 保险：xray/sing-box 等要求 Go 1.27+
grep -q 'GO_DEFAULT_VERSION:=1.2[78]' feeds/packages/lang/golang/golang-values.mk || \
  sed -i 's/GO_DEFAULT_VERSION:=1.26/GO_DEFAULT_VERSION:=1.27/' feeds/packages/lang/golang/golang-values.mk
grep -q 'GO_DEFAULT_VERSION:=1.2[78]' feeds/packages/lang/golang/golang-values.mk || {
  echo "Go 保险未生效" >&2; exit 1; }

# ttyd 与 libwebsockets 5.1 兼容：监听 7681 后立刻退出（上游 fddd638）
mkdir -p feeds/packages/utils/ttyd/patches
cp "$D/patches/ttyd-libuv-loop.patch" feeds/packages/utils/ttyd/patches/
test -s feeds/packages/utils/ttyd/patches/ttyd-libuv-loop.patch

# luci-theme-7dollar 兼容：ucode 预编译找不到自定义模块，声明运行时解析
sed -i 's/dynlink=uloop/dynlink=uloop,dynlink=luci.7dollar/' feeds/luci/luci.mk
grep -q 'dynlink=luci.7dollar' feeds/luci/luci.mk || {
    echo "luci.mk 兼容修复未生效" >&2; exit 1; }
