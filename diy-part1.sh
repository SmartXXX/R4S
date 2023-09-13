#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# Uncomment a feed source
# sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
# echo 'src-git helloworld https://github.com/fw876/helloworld.git' >>feeds.conf.default
# echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall.git' >>feeds.conf.default
# echo 'src-git helloworld https://github.com/sbwml/openwrt_helloworld.git' >>feeds.conf.default
# echo 'src-git helloworld https://github.com/kenzok8/openwrt-packages.git' >>feeds.conf.default
# echo 'src-git passwall https://github.com/kenzok8/small.git' >>feeds.conf.default
echo 'src-git lienol https://github.com/Lienol/openwrt-package' >>feeds.conf.default

echo 'src-git passwall https://github.com/ysx88/openwrt-packages/trunk/openwrt-passwall-packages' >>feeds.conf.default
svn export https://github.com/ysx88/openwrt-packages/trunk/luci-app-passwall feeds/passwall/luci-app-passwall
svn export https://github.com/ysx88/openwrt-packages/trunk/luci-app-passwall2 feeds/passwall/luci-app-passwall2

echo 'src-git helloworld https://github.com/ysx88/openwrt-packages/trunk/helloworld' >>feeds.conf.default
svn export https://github.com/ysx88/openwrt-packages/trunk/luci-app-ssr-plus feeds/helloworld/luci-app-ssr-plus
