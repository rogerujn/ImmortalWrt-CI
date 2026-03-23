#!/bin/bash
# 脚本编码声明（避免中文乱码）
export LC_ALL=C

# ====================== 核心保留：修改系统基础配置 ======================
# 修改默认IP（与工作流描述的192.168.2.1接近，可根据需求调整）
sed -i 's/192.168.1.1/192.168.2.3/g' package/base-files/files/bin/config_generate
# 修改默认主机名
sed -i "s/hostname='.*'/hostname='ImmortalWrt'/g" package/base-files/files/bin/config_generate
# 修改固件版本显示（移除原作者信息，改为通用编译信息）
sed -i "s#_('Firmware Version'), (L\.isObject(boardinfo\.release) ? boardinfo\.release\.description + ' / ' : '') + (luciversion || ''),# \
            _('Firmware Version'),\n \
            E('span', {}, [\n \
                (L.isObject(boardinfo.release)\n \
                ? boardinfo.release.description + ' / '\n \
                : '') + (luciversion || '') + ' / ',\n \
            E('a', {\n \
                href: 'https://github.com/immortalwrt/immortalwrt',\n \
                target: '_blank',\n \
                rel: 'noopener noreferrer'\n \
                }, [ 'Built on $(date "+%Y-%m-%d %H:%M:%S")' ])\n \
            ]),#" feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js

# ====================== 保留主题相关（配置文件中启用了Aurora/Argon） ======================
# 移除原有的主题包（避免冲突）
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/luci/themes/luci-theme-argon
# rm -rf feeds/luci/applications/luci-app-wechatpush

# 克隆最新的Argon主题和配置
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon feeds/luci/themes/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config feeds/luci/applications/luci-app-argon-config

# git clone --depth=1 https://github.com/tty228/luci-app-wechatpush package/luci-app-wechatpush

# ====================== 保留PassWall核心（配置文件中启用） ======================
# 移除OpenWrt Feeds自带的冲突核心库
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
# 克隆PassWall官方包
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages

# 移除过时的PassWall版本，克隆最新版
rm -rf feeds/luci/applications/luci-app-passwall
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall package/luci-app-passwall

# 清理PassWall的chnlist规则文件（精简规则）
echo "baidu.com"  > package/luci-app-passwall/luci-app-passwall/root/usr/share/passwall/rules/chnlist

# ====================== 通用更新feeds ======================
./scripts/feeds update -a
./scripts/feeds install -a
