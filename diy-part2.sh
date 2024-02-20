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

chmod -R 755 files

# swap the network adapter driver to r8168 to gain better performance for r4s
sed -i 's/r8169/r8168/' target/linux/rockchip/image/armv8.mk
git clone -b master --depth 1 https://github.com/BROBIRD/openwrt-r8168.git package/new/r8168

echo '### CacULE ###'
sed -i '/CONFIG_NR_CPUS/d' ./target/linux/rockchip/armv8/config-5.4
echo '
CONFIG_NR_CPUS=6
' >> ./target/linux/rockchip/armv8/config-5.4
echo '###  ###'

echo '### UKSM ###'
echo '
CONFIG_KSM=y
CONFIG_UKSM=y
' >> ./target/linux/rockchip/armv8/config-5.4
echo '###  ###'

# Modify config
sed -i 's,-mcpu=generic,-mcpu=cortex-a72.cortex-a53+crypto,g' include/target.mk
sed -i "s/CONFIG_TARGET_ARCH_PACKAGES=\"aarch64_cortex-a53\"/CONFIG_TARGET_ARCH_PACKAGES=\"aarch64_cortex-a72\"/" .config
sed -i "s/CONFIG_DEFAULT_TARGET_OPTIMIZATION=\"-Os -pipe -mcpu=cortex-a53\"/CONFIG_DEFAULT_TARGET_OPTIMIZATION=\"-O3 -pipe -march=armv8-a+crypto+crc -mcpu=cortex-a72.cortex-a53+crypto+crc -mtune=cortex-a72.cortex-a53\"/" .config
sed -i "s/CONFIG_CPU_TYPE=\"cortex-a53\"/CONFIG_CPU_TYPE=\"cortex-a72.cortex-a53\"/" .config
sed -i "s/CONFIG_TARGET_OPTIMIZATION=\"-Os -pipe -mcpu=cortex-a53\"/CONFIG_TARGET_OPTIMIZATION=\"-O3 -pipe -march=armv8-a+crypto+crc -mcpu=cortex-a72.cortex-a53+crypto+crc -mtune=cortex-a72.cortex-a53\"/" .config

# Fix gn
# rm -rf feeds/passwall_packages/gn
# mkdir -p feeds/passwall_packages/gn
# git clone --depth  1 --branch master https://github.com/kenzok8/small.git temp-repo
# cp -r temp-repo/gn feeds/passwall_packages/gn
# rm -rf temp-repo

# Fix libssh
# pushd feeds/packages/libs
# rm -rf libssh
# svn export https://github.com/openwrt/packages/trunk/libs/libssh
# popd

rm -rf feeds/packages/libs/libssh
mkdir -p feeds/packages/libs/libssh
git clone --depth  1 --branch master https://github.com/openwrt/packages.git temp-repo
cp -r temp-repo/libs/libssh feeds/packages/libs/libssh
rm -rf temp-repo

# Fix apk
# rm -rf feeds/packages/utils/apk
# mkdir -p feeds/packages/utils/apk
# git clone --depth  1 --branch master https://github.com/openwrt/packages.git temp-repo
# cp -r temp-repo/utils/apk feeds/packages/utils/apk
# rm -rf temp-repo

# no need for password on ttyd
sed -i 's/\/bin\/login/\/bin\/login -f root/g' feeds/packages/utils/ttyd/files/ttyd.config

# Modify default root password
sed -i 's/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/root:$1$epiUZfww$ifgJQjh3dsGb8GwihIdXm.:15723:0:99999:7:::/g' package/lean/default-settings/files/zzz-default-settings

# Modify default IP & hostname
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate
sed -i '/uci commit system/i\uci set system.@system[0].hostname='SmartR4S'' package/lean/default-settings/files/zzz-default-settings
sed -i 's/OpenWrt /SmartR4S /g' package/lean/default-settings/files/zzz-default-settings

# 禁用ipv6前缀
# sed -i 's/^[^#].*option ula/#&/' package/base-files/files/etc/config/network

# Add firewall rules
echo 'iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE' >> package/network/config/firewall/files/firewall.user
echo 'iptables -t nat -I PREROUTING -i pppoe-wan -p tcp --dport 5001 -j DNAT --to-destination 192.168.6.6:5001' >> package/network/config/firewall/files/firewall.user
echo 'iptables -t nat -I PREROUTING -i pppoe-wan -p tcp --dport 6690 -j DNAT --to-destination 192.168.6.6:6690' >> package/network/config/firewall/files/firewall.user
echo 'iptables -t nat -I PREROUTING -i pppoe-wan -p tcp --dport 8085 -j DNAT --to-destination 192.168.6.6:8085' >> package/network/config/firewall/files/firewall.user
echo 'iptables -t nat -I PREROUTING -i pppoe-wan -p tcp --dport 9080 -j DNAT --to-destination 192.168.6.6:9080' >> package/network/config/firewall/files/firewall.user
sed -i 's/-j REDIRECT --to-ports 53/-j REDIRECT --to-ports 6153/g' package/lean/default-settings/files/zzz-default-settings

# modify Lienol's Packages
# rm -rf feeds/luci/applications/luci-app-kodexplorer
# rm -rf feeds/lienol/verysync
# rm -rf feeds/lienol/luci-app-verysync

# modify small's Packages
# rm -rf package/feeds/small/luci-app-bypass
# rm -rf package/feeds/small/luci-app-ssr-plus
# svn export https://github.com/ysx88/openwrt-packages/trunk/lua-maxminddb package/feeds/small/lua-maxminddb

# Add luci-theme-argon
rm -rf package/lean/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-argon
# rm -rf feeds/helloworld/luci-theme-argon
# rm -rf feeds/helloworld/luci-app-argon-config
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/lean/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/lean/luci-app-argon-config
rm -rf package/lean/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
cp -f $GITHUB_WORKSPACE/bg1.jpg package/lean/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
sed -i 's/luci-theme-bootstrap/luci-theme-argon/' feeds/luci/collections/luci/Makefile

# Add luci-app-poweroff
# svn export https://github.com/281677160/openwrt-package/trunk/luci-app-poweroff package/lean/luci-app-poweroff
# git clone -b lede https://github.com/281677160/openwrt-package/luci-app-poweroff package/lean/luci-app-poweroff
# svn export https://github.com/ysx88/openwrt-packages/trunk/luci-app-poweroff package/lean/luci-app-poweroff

git clone --depth  1 --branch Lede https://github.com/281677160/openwrt-package.git temp-repo
mkdir -p package/lean/luci-app-poweroff && cp -r temp-repo/luci-app-poweroff package/lean/luci-app-poweroff
rm -rf temp-repo

# Replace smartdns with the official version
# rm -rf packages/net/smartdns
# svn export https://github.com/openwrt/packages/trunk/net/smartdns packages/net/smartdns
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/openwrt-smartdns packages/net/smartdns
# svn export https://github.com/281677160/openwrt-package/trunk/smartdns packages/net/smartdns
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/openwrt-smartdns packages/net/smartdns

# Add luci-app-smartdns
rm -rf feeds/luci/applications/luci-app-smartdns
# svn export https://github.com/liuran001/openwrt-packages/trunk/luci-app-smartdns package/lean/luci-app-smartdns
# svn export https://github.com/kenzok8/openwrt-packages/trunk/luci-app-smartdns package/lean/luci-app-smartdns
# svn export https://github.com/281677160/openwrt-package/trunk/luci-app-smartdns package/lean/luci-app-smartdns
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-smartdns package/lean/luci-app-smartdns
# git clone -b lede https://github.com/pymumu/luci-app-smartdns package/lean/luci-app-smartdns
# svn export https://github.com/ysx88/openwrt-packages/trunk/luci-app-smartdns package/lean/luci-app-smartdns

git clone --depth  1 --branch master https://github.com/kenzok8/openwrt-packages.git temp-repo
mkdir -p package/lean/luci-app-smartdns && cp -r temp-repo/luci-app-smartdns package/lean/luci-app-smartdns
rm -rf temp-repo

# Add luci-app-passwall
# rm -rf feeds/passwall/hysteria
# svn export https://github.com/xiaorouji/openwrt-passwall/trunk/hysteria feeds/passwall/hysteria
# svn export https://github.com/sbwml/openwrt_helloworld/trunk/luci-app-passwall package/lean/luci-app-passwall
# svn export https://github.com/sbwml/openwrt_helloworld/trunk/luci-app-passwall2 package/lean/luci-app-passwall2
# svn export https://github.com/sbwml/openwrt_helloworld/trunk/brook package/lean/brook
# svn export https://github.com/sbwml/openwrt_helloworld/trunk/trojan-go package/lean/trojan-go
# svn export https://github.com/sbwml/openwrt_helloworld/trunk/trojan-plus package/lean/trojan-plus
# svn export https://github.com/sbwml/openwrt_helloworld/trunk/sing-box package/lean/sing-box
# svn export https://github.com/xiaorouji/openwrt-passwall/trunk/pdnsd-alt package/lean/pdnsd-alt
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/pdnsd-alt package/lean/pdnsd-alt
# git clone https://github.com/xiaorouji/openwrt-passwall feeds/passwall
# git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2 feeds/passwall2
# svn export https://github.com/xiaorouji/openwrt-passwall/branches/luci/luci-app-passwall package/lean/luci-app-passwall
# svn export https://github.com/ysx88/openwrt-packages/trunk/luci-app-passwall feeds/lienol/luci-app-passwall
# svn export https://github.com/xiaorouji/openwrt-passwall/trunk/luci-app-passwall package/lean/luci-app-passwall
# svn export https://github.com/ysx88/openwrt-packages/trunk/luci-app-passwall2 package/lean/luci-app-passwall2
# svn export --force https://github.com/ysx88/openwrt-packages/trunk/openwrt-passwall package/lean
# rm -rf feeds/small/luci-app-bypass
# rm -rf feeds/small/luci-app-ssr-plus
# rm -rf feeds/small/luci-app-passwall
# rm -rf feeds/small/luci-app-vssr

# Add luci-app-ssr-plus
# rm -rf feeds/helloworld/luci-app-ssr-plus
# svn export --force https://github.com/ysx88/openwrt-packages/trunk/helloworld package/lean
# svn export https://github.com/ysx88/openwrt-packages/trunk/luci-app-ssr-plus package/lean/luci-app-ssr-plus

# Add luci-app-vssr
# git clone --depth=1 https://github.com/jerrykuku/lua-maxminddb.git package/lean/lua-maxminddb
# git clone --depth=1 https://github.com/jerrykuku/luci-app-vssr package/lean/luci-app-vssr
# svn export https://github.com/kenzok8/openwrt-packages/trunk/lua-maxminddb package/lean/lua-maxminddb
# svn export https://github.com/281677160/openwrt-package/trunk/luci-app-vssr package/lean/luci-app-vssr
# svn export https://github.com/ysx88/openwrt-packages/trunk/lua-maxminddb package/lean/lua-maxminddb
# svn export https://github.com/ysx88/openwrt-packages/trunk/luci-app-vssr package/lean/luci-app-vssr

# Replace files ERROR
# rm -rf package/boot/uboot-rockchip
# svn export https://github.com/DHDAXCW/lede-rockchip/trunk/package/boot/uboot-rockchip package/boot/uboot-rockchip
# svn export https://github.com/immortalwrt/immortalwrt/trunk/package/boot/uboot-rockchip package/boot/uboot-rockchip

# 删除lede里的Makefile
# rm -rf target/linux/rockchip/Makefile

# 使用原openwrt中的Makefile
# svn export https://github.com/openwrt/openwrt/trunk/target/linux/rockchip/Makefile target/linux/rockchip/Makefile

# sed -i "s/^[^#].*CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Rust_Client$/#&/g" .config
# sed -i "s/^[^#].*CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Rust_Server$/#&/g" .config
# echo 'CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Rust_Client=y' >> .config
# echo 'CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Rust_Server=y' >> .config
