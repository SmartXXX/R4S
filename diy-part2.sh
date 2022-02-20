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

# Modify default IP
sed -i 's/192.168.1.1/192.168.1.2/g' package/base-files/files/bin/config_generate

# Add a feed source
svn co https://github.com/esirplayground/luci-app-poweroff package/luci-app-poweroff
svn co https://github.com/ujincn/smartdns package/smartdns
svn co https://github.com/immortalwrt/luci/branches/openwrt-21.02/applications/luci-app-smartdns package/luci-app-smartdns

# Add luci-theme-argon
rm -rf package/lean/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/lean/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/lean/luci-app-argon-config
sed -i 's/luci-theme-bootstrap/luci-theme-argon/' feeds/luci/collections/luci/Makefile
