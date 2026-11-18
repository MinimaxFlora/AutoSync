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

git clone --depth 1 https://github.com/eamonxg/luci-theme-aurora
git clone --depth 1 https://github.com/eamonxg/luci-app-aurora-config
git clone --depth 1 https://github.com/eamonxg/luci-theme-shadcn
git clone --depth 1 https://github.com/LazuliKao/luci-theme-fluent
git clone --depth 1 https://github.com/anothaDev/luci-theme-vantage
git clone --depth 1 -b openwrt-25.12 https://github.com/coolsnowwolf/luci && mv -n luci/themes/luci-theme-design ./ ; rm -rf luci

### 通用插件 ###
git clone --depth 1 https://github.com/sbwml/luci-app-ramfree
git clone --depth 1 -b openwrt-25.12 https://github.com/MinimaxFlora/autocore
git clone --depth 1 https://github.com/MinimaxFlora/luci-app-adguardhome openwrt-adguardhome && mv -n openwrt-adguardhome/luci-app-adguardhome ./ ; rm -rf openwrt-adguardhome
git clone --depth 1 https://github.com/sbwml/openwrt_pkgs && mv -n openwrt_pkgs/luci-app-socat ./ ; rm -rf openwrt_pkgs
git clone --depth 1 https://github.com/sbwml/luci-app-diskman openwrt-diskman && mv -n openwrt-diskman/luci-app-diskman ./ ; rm -rf openwrt-diskman
git clone --depth 1 https://github.com/sbwml/luci-app-mentohust openwrt-mentohust && mv -n openwrt-mentohust/{mentohust,luci-app-mentohust} ./ ; rm -rf openwrt-mentohust
git clone --depth 1 -b main https://github.com/sbwml/luci-app-quickfile openwrt-quickfile && mv -n openwrt-quickfile/{quickfile,luci-app-quickfile} ./ ; rm -rf openwrt-quickfile
git clone --depth 1 -b v5 https://github.com/sbwml/luci-app-mosdns openwrt-mosdns && mv -n openwrt-mosdns/{mosdns,geo2txt,luci-app-mosdns} ./ ; rm -rf openwrt-mosdns
git clone --depth 1 -b main https://github.com/sbwml/luci-app-airconnect openwrt-airconnect && mv -n openwrt-airconnect/{airconnect,luci-app-airconnect} ./ ; rm -rf openwrt-airconnect
git clone --depth 1 -b main https://github.com/sbwml/luci-app-openlist2 openwrt-openlist2 && mv -n openwrt-openlist2/{openlist2,luci-app-openlist2} ./ ; rm -rf openwrt-openlist2
git clone --depth 1 -b main https://github.com/timsaya/luci-app-bandix-plus openwrt-bandix && mv -n openwrt-bandix/luci-app-bandix-plus ./ ; rm -rf openwrt-bandix
git clone --depth 1 https://github.com/timsaya/openwrt-bandix-plus openwrt-bandix && mv -n openwrt-bandix/openwrt-bandix-plus ./ ; rm -rf openwrt-bandix

### 科学插件 ###
git clone --depth 1 -b main https://github.com/VIKINGYFY/packages VIKINGYFY-packages && mv -n VIKINGYFY-packages/{luci-app-homeproxy,sing-box} ./ ; rm -rf VIKINGYFY-packages
git clone --depth 1 -b master https://github.com/vernesong/OpenClash && mv -n OpenClash/luci-app-openclash ./ ; rm -rf OpenClash
git clone --depth 1 -b main https://github.com/nikkinikki-org/OpenWrt-nikki OpenWrt-nikki && mv -n OpenWrt-nikki/{mihomo-meta,nikki,luci-app-nikki} ./ ; rm -rf OpenWrt-nikki
git clone --depth 1 https://github.com/Openwrt-Passwall/openwrt-passwall && mv -n openwrt-passwall/luci-app-passwall ./ ; rm -rf openwrt-passwall
git clone --depth 1 https://github.com/Openwrt-Passwall/openwrt-passwall2 && mv -n openwrt-passwall2/luci-app-passwall2 ./ ; rm -rf openwrt-passwall2
git clone --depth 1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages && mv -n openwrt-passwall-packages/{chinadns-ng,dns2socks,geoview,hysteria,ipt2socks,microsocks,naiveproxy,shadow-tls,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,v2ray-geodata,v2ray-plugin,xray-core,xray-plugin} ./ ; rm -rf openwrt-passwall-packages

### 相关设置 ###
mv openwrt-bandix-plus bandix-plus
cp -f $GITHUB_WORKSPACE/images/bg1.webp luci-theme-argon/htdocs/luci-static/argon/img/bg1.webp
sed -i "s/option primary '#5e72e4'/option primary '#F4A7B9'/g" luci-theme-argon/root/etc/config/argon
sed -i "s/option mode 'normal'/option mode 'light'/g" luci-theme-argon/root/etc/config/argon
sed -i 's#include ../../luci.mk#include $(TOPDIR)/feeds/luci/luci.mk#g' luci-theme-design/Makefile
sed -i 's#include ../../lang/golang/golang-package.mk#include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk#g' sing-box/Makefile

### openclash 中文翻译：SDK 里没有 po2lmo（luci 主机工具），同步时预生成 .lmo ###
if [ -d luci-app-openclash/po ]; then
  _luci=$(mktemp -d)
  git clone -q --depth 1 --filter=blob:none --sparse https://github.com/openwrt/luci "$_luci" 2>/dev/null || true
  ( cd "$_luci" && git sparse-checkout set modules/luci-base/src ) >/dev/null 2>&1 || true
  if make -s -C "$_luci/modules/luci-base/src" po2lmo >/dev/null 2>&1; then
    mkdir -p luci-app-openclash/lmo
    find luci-app-openclash/po -name '*.po' | while read -r _po; do
      "$_luci/modules/luci-base/src/po2lmo" "$_po" "luci-app-openclash/lmo/$(basename "${_po%.po}").lmo" || true
    done
    sed -i 's#po2lmo $(po) $(PKG_BUILD_DIR)/$(patsubst %.po,%.lmo,$(notdir $(po)));)#$(CP) $(CURDIR)/lmo/$(patsubst %.po,%.lmo,$(notdir $(po))) $(PKG_BUILD_DIR)/;#' luci-app-openclash/Makefile
    echo "openclash lmo 预生成: $(find luci-app-openclash/lmo -name '*.lmo' | wc -l) 个"
  else
    echo "::warning::po2lmo 编译失败，openclash 将不带中文翻译"
  fi
  rm -rf "$_luci"
fi

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
