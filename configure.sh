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

# 修改默认密码
sed -i 's|root::0:0:99999:7:::|root:$1$X4dKiB7y$KzH4MhV6D0lXlXlXlXlXl.:18888:0:99999:7:::|g' package/base-files/files/etc/shadow

# 禁用 DHCPv4 服务 (忽略此接口)
sed -i '/dhcp.lan.ignore/d' package/base-files/files/bin/config_generate
echo "set dhcp.lan.ignore='1'" >> package/base-files/files/bin/config_generate

# 禁用 IPv6 前缀分配长度
sed -i '/network.lan.ip6assign/d' package/base-files/files/bin/config_generate
echo "set network.lan.ip6assign='0'" >> package/base-files/files/bin/config_generate

# 禁用 RA 路由通告服务
sed -i '/dhcp.lan.ra/d' package/base-files/files/bin/config_generate
echo "set dhcp.lan.ra='0'" >> package/base-files/files/bin/config_generate

# 禁用 DHCPv6 服务
sed -i '/dhcp.lan.dhcpv6/d' package/base-files/files/bin/config_generate
echo "set dhcp.lan.dhcpv6='0'" >> package/base-files/files/bin/config_generate

# Hello World
echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default

# passwall
echo "src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main" >> feeds.conf.default
echo "src-git passwall2 https://github.com/Openwrt-Passwall/openwrt-passwall2.git;main" >> feeds.conf.default

# iStore
echo "src-git istore https://github.com/linkease/istore;main" >> feeds.conf.default

# ======================================================================
# Turbo ACC 网络加速 - 最终定稿配置 (X86 + OpenClash 专用)
# ======================================================================
uci -d batch << EOF
set system.@system[0].hostname=OpenWrt

# 1. 启用 软件流量卸载 (Flow Offloading)
set firewall.@defaults[0].flow_offloading='1'
set firewall.@defaults[0].flow_offloading_hw='0'

# 2. 启用 BBR 拥塞控制
set kernel.@tcp_congestion[0].tcp_congestion_control='bbr'

# 3. 启用 TCP 快速打开 TFO
set kernel.@net_tcp[0].tcp_fastopen='3'

# 4. 启用 ECN 显式拥塞通知
set kernel.@net_ipv4[0].tcp_ecn='1'

# 5. 优化网络缓冲区
set kernel.@net_core[0].netdev_max_backlog='10000'
set kernel.@net_core[0].somaxconn='4096'
set kernel.@net_ipv4[0].tcp_max_syn_backlog='8192'

# 6. 防火墙高效模式
set firewall.@defaults[0].fullcone='0'          # 重要：关闭 FullCone NAT1（避免冲突）
set firewall.@defaults[0].drop_invalid='1'

# 7. 启用 Turbo ACC 核心加速
set turboacc.config.acceleration='1'
set turboacc.config.flow_acceleration='1'
set turboacc.config.fullcone_nat='0'
set turboacc.config.tcp_bbr='1'
set turboacc.config.tcp_congestion='bbr'
set turboacc.config.tcp_fastopen='1'
set turboacc.config.dns_opt='1'
EOF

# 保存配置
uci commit
