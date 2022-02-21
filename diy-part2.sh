#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP & hostname
sed -i 's/192.168.1.1/192.168.1.2/g' package/base-files/files/bin/config_generate
sed -i '/uci commit system/i\uci set system.@system[0].hostname='SmartR4S''

# Add luci-theme-argon
rm -rf package/lean/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/lean/luci-theme-argon
sed -i 's/luci-theme-bootstrap/luci-theme-argon/' 

svn co https://github.com/281677160/openwrt-package/trunk/feeds/luci/applications/luci-app-argon-config package/lean/luci-app-argon-config

# Add luci-app-poweroff
svn co https://github.com/281677160/openwrt-package/trunk/feeds/luci/applications/luci-app-poweroff package/lean/luci-app-poweroff

# Add luci-app-smartdns
svn co https://github.com/281677160/openwrt-package/trunk/feeds/luci/applications/luci-app-smartdns package/lean/luci-app-smartdns

# Replace smartdns with the official version
rm -rf packages/net/smartdns 
svn co https://github.com/openwrt/packages/trunk/net/smartdns packages/net/smartdns

feeds/luci/collections/luci/Makefile
