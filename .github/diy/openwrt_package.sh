#!/bin/bash
function git_sparse_clone() {
branch="$1" rurl="$2" localdir="$3" && shift 3
git clone -b $branch --depth 1 --filter=blob:none --sparse $rurl $localdir
cd $localdir
git sparse-checkout init --cone
git sparse-checkout set $@
mv -n $@ ../
cd ..
rm -rf $localdir
}

function mvdir() {
mv -n `find $1/* -maxdepth 0 -type d` ./
rm -rf $1
}

### 主题插件 ###
git clone --depth 1 -b master https://github.com/jerrykuku/luci-theme-argon
git clone --depth 1 -b master https://github.com/jerrykuku/luci-app-argon-config
git clone --depth 1 https://github.com/eamonxg/luci-theme-aurora
git clone --depth 1 https://github.com/eamonxg/luci-app-aurora-config
git clone --depth 1 https://github.com/eamonxg/luci-theme-shadcn
git clone --depth 1 https://github.com/sirpdboy/luci-theme-kucat
git clone --depth 1 https://github.com/sirpdboy/luci-app-kucat-config
git clone --depth 1 https://github.com/LazuliKao/luci-theme-fluent
git clone --depth 1 -b openwrt-25.12 https://github.com/coolsnowwolf/luci && mv -n luci/themes/luci-theme-design ./ ; rm -rf luci

### 通用插件 ###
git clone --depth 1 https://github.com/sbwml/luci-app-ramfree
git clone --depth 1 -b openwrt-25.12 https://github.com/MinimaxFlora/autocore
git clone --depth 1 https://github.com/MinimaxFlora/luci-app-adguardhome openwrt-adguardhome && mv -n openwrt-adguardhome/luci-app-adguardhome ./ ; rm -rf openwrt-adguardhome
git clone --depth 1 https://github.com/sbwml/openwrt_pkgs && mv -n openwrt_pkgs/luci-app-socat ./ ; rm -rf openwrt_pkgs
git clone --depth 1 https://github.com/sbwml/luci-app-diskman openwrt-diskman && mv -n openwrt-diskman/luci-app-diskman ./ ; rm -rf openwrt-diskman
git clone --depth 1 https://github.com/sbwml/luci-app-mentohust openwrt-mentohust && mv -n openwrt-mentohust/{mentohust,luci-app-mentohust} ./ ; rm -rf openwrt-mentohust
git clone --depth 1 -b main https://github.com/sbwml/luci-app-quickfile openwrt-quickfile && mv -n openwrt-quickfile/{quickfile,luci-app-quickfile} ./ ; rm -rf openwrt-quickfile
git clone --depth 1 -b v5 https://github.com/sbwml/luci-app-mosdns openwrt-mosdns && mv -n openwrt-mosdns/{v2dat,mosdns,luci-app-mosdns} ./ ; rm -rf openwrt-mosdns
git clone --depth 1 -b main https://github.com/sbwml/luci-app-airconnect openwrt-airconnect && mv -n openwrt-airconnect/{airconnect,luci-app-airconnect} ./ ; rm -rf openwrt-airconnect
git clone --depth 1 -b main https://github.com/sbwml/luci-app-openlist2 openwrt-openlist2 && mv -n openwrt-openlist2/{openlist2,luci-app-openlist2} ./ ; rm -rf openwrt-openlist2
git clone --depth 1 -b main https://github.com/timsaya/luci-app-bandix-plus openwrt-bandix && mv -n openwrt-bandix/luci-app-bandix-plus ./ ; rm -rf openwrt-bandix
git clone --depth 1 https://github.com/timsaya/openwrt-bandix-plus openwrt-bandix && mv -n openwrt-bandix/openwrt-bandix-plus ./ ; rm -rf openwrt-bandix

### 科学插件 ###
git clone --depth 1 -b master https://github.com/immortalwrt/homeproxy luci-app-homeproxy
git clone --depth 1 -b master https://github.com/immortalwrt/packages && mv -n packages/net/sing-box ./ ; rm -rf packages
git clone --depth 1 -b master https://github.com/vernesong/OpenClash && mv -n OpenClash/luci-app-openclash ./ ; rm -rf OpenClash
git clone --depth 1 -b main https://github.com/nikkinikki-org/OpenWrt-nikki && mv -n OpenWrt-nikki/{nikki,mihomo-meta,luci-app-nikki} ./ ; rm -rf OpenWrt-nikki
git clone --depth 1 https://github.com/Openwrt-Passwall/openwrt-passwall && mv -n openwrt-passwall/luci-app-passwall ./ ; rm -rf openwrt-passwall
git clone --depth 1 https://github.com/Openwrt-Passwall/openwrt-passwall2 && mv -n openwrt-passwall2/luci-app-passwall2 ./ ; rm -rf openwrt-passwall2
git clone --depth 1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages && mv -n openwrt-passwall-packages/{chinadns-ng,dns2socks,geoview,hysteria,ipt2socks,microsocks,naiveproxy,shadow-tls,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,v2ray-geodata,v2ray-plugin,xray-core,xray-plugin} ./ ; rm -rf openwrt-passwall-packages

### 相关设置 ###
mv openwrt-bandix-plus bandix-plus
cp -f $GITHUB_WORKSPACE/images/bg1.jpg luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
sed -i "s/option online_wallpaper 'bing'/option online_wallpaper 'none'/g" luci-app-argon-config/root/etc/config/argon
sed -i "s/option primary '#5e72e4'/option primary '#F4A7B9'/g" luci-app-argon-config/root/etc/config/argon
sed -i "s/option mode 'normal'/option mode 'light'/g" luci-app-argon-config/root/etc/config/argon
sed -i 's#include ../../luci.mk#include $(TOPDIR)/feeds/luci/luci.mk#g' luci-theme-design/Makefile
sed -i 's#include ../../lang/golang/golang-package.mk#include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk#g' sing-box/Makefile

### 提前保存各包的上游最新 commit 信息（在删除 .git 之前）###
echo "保存上游 commit 信息..."
: > /tmp/upstream_commit_msgs.txt
for dir in */; do
    pkg="${dir%/}"
    [ -d "$pkg/.git" ] || continue
    msg=$(git -C "$pkg" log -1 --pretty=format:'%s' 2>/dev/null)
    [ -n "$msg" ] && printf '%s|%s\n' "$pkg" "$msg" >> /tmp/upstream_commit_msgs.txt
done
echo "已保存 $(wc -l < /tmp/upstream_commit_msgs.txt) 个包的 commit 信息"
rm -rf ./*/.git ./*/.gitattributes ./*/.svn ./*/.github ./*/.gitignore

exit 0
