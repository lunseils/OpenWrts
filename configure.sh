#!/bin/bash
# Modify default system settings

# 修改默认IP为192.168.10.1
sed -i 's/192.168.1.1/192.168.1.111/g' package/base-files/files/bin/config_generate 

# 自定义默认网关（旁路由必备）
sed -i '/set network.lan.gateway/d' package/base-files/files/bin/config_generate
echo "set network.lan.gateway='192.168.1.1'" >> package/base-files/files/bin/config_generate

# 自定义默认 DNS
sed -i '/set network.lan.dns/d' package/base-files/files/bin/config_generate
echo "set network.lan.dns='223.5.5.5 114.114.114.114'" >> package/base-files/files/bin/config_generate

# Hello World
echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default

# passwall
echo "src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main" >> feeds.conf.default
echo "src-git passwall2 https://github.com/Openwrt-Passwall/openwrt-passwall2.git;main" >> feeds.conf.default

# iStore
echo "src-git istore https://github.com/linkease/istore;main" >> feeds.conf.default
