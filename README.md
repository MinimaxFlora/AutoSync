<div align="center">

# 🔄 AutoSync

### 自动同步 OpenWrt 插件包 · 汇聚上游精华到你的包源

![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-自动化流水线-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-0d1117?style=for-the-badge&labelColor=161b22&color=30363d)
![OpenWrt](https://img.shields.io/badge/OpenWrt-24.10%20%7C%2025.12-00A98F?style=for-the-badge&logo=openwrt&logoColor=white)

**把散落各处的优秀插件（主题 / 代理 / 工具）自动汇聚到一个包源仓库**

</div>

---

## ✨ 它是什么

`AutoSync` 是一个纯 GitHub Actions 驱动的自动化仓库：定时或手动触发后，从 **20+ 上游仓库**拉取最新的 OpenWrt 插件代码，自动完成翻译补齐、LuCI ACL 生成、定制修改，然后**逐包提交并推送**到 [MinimaxFlora/openwrt_package](https://github.com/MinimaxFlora/openwrt_package) 包源仓库。

> 🧠 一句话：**上游更新 → 自动同步 → 包源就绪**，全程无需人工干预。

---

## 🌟 特性

| | | |
| :--- | :--- | :--- |
| 🌐 **多源同步** | 🧩 **智能整理** | 🈶 **翻译补齐** |
| 20+ 上游仓库一键拉取 | 只保留包目录，清除 .git 等杂物 | 自动创建 `zh-cn` / `zh_Hans` 软链接 |
| 🛡️ **LuCI ACL** | ✂️ **定制修改** | 🔍 **版本感知** |
| 自动为 LuCI 应用生成 ACL 文件 | Argon 壁纸 / 禁用在线壁纸 / Makefile 适配 | 按 `PKG_VERSION` 检测变更，逐包单独提交 |
| 🎉 **花式提交** | 🧹 **自动保洁** | ⚡ **开箱即用** |
| 随机 emoji 提交信息，一眼识别 | 自动清理 1 天前的 workflow 运行记录 | 包源直接加入 feeds 即可编译 |

---

## 📦 同步来源

### 🎨 主题插件

| 包 | 上游 |
| :--- | :--- |
| luci-theme-argon / luci-app-argon-config | [jerrykuku/luci-theme-argon](https://github.com/jerrykuku/luci-theme-argon) |
| luci-theme-aurora / luci-app-aurora-config | [eamonxg/luci-theme-aurora](https://github.com/eamonxg/luci-theme-aurora) |
| luci-theme-shadcn | [eamonxg/luci-theme-shadcn](https://github.com/eamonxg/luci-theme-shadcn) |
| luci-theme-kucat / luci-app-kucat-config | [sirpdboy/luci-theme-kucat](https://github.com/sirpdboy/luci-theme-kucat) |
| luci-theme-design | [coolsnowwolf/luci](https://github.com/coolsnowwolf/luci)（openwrt-25.12 分支） |

### 🧰 通用插件

| 包 | 上游 |
| :--- | :--- |
| luci-app-ramfree | [sbwml/luci-app-ramfree](https://github.com/sbwml/luci-app-ramfree) |
| luci-app-diskman | [sbwml/luci-app-diskman](https://github.com/sbwml/luci-app-diskman) |
| mentohust / luci-app-mentohust | [sbwml/luci-app-mentohust](https://github.com/sbwml/luci-app-mentohust) |
| quickfile / luci-app-quickfile | [sbwml/luci-app-quickfile](https://github.com/sbwml/luci-app-quickfile) |
| mosdns / luci-app-mosdns / v2dat | [sbwml/luci-app-mosdns](https://github.com/sbwml/luci-app-mosdns)（v5 分支） |
| airconnect / luci-app-airconnect | [sbwml/luci-app-airconnect](https://github.com/sbwml/luci-app-airconnect) |
| openlist2 / luci-app-openlist2 | [sbwml/luci-app-openlist2](https://github.com/sbwml/luci-app-openlist2) |
| luci-app-bandix-plus / bandix-plus | [timsaya/luci-app-bandix-plus](https://github.com/timsaya/luci-app-bandix-plus) |

### 🚀 科学上网插件

| 包 | 上游 |
| :--- | :--- |
| luci-app-homeproxy | [immortalwrt/homeproxy](https://github.com/immortalwrt/homeproxy) |
| sing-box | [immortalwrt/packages](https://github.com/immortalwrt/packages)（net/sing-box） |
| luci-app-openclash | [vernesong/OpenClash](https://github.com/vernesong/OpenClash) |
| nikki / mihomo-meta / luci-app-nikki | [nikkinikki-org/OpenWrt-nikki](https://github.com/nikkinikki-org/OpenWrt-nikki) |
| luci-app-passwall | [Openwrt-Passwall/openwrt-passwall](https://github.com/Openwrt-Passwall/openwrt-passwall) |
| luci-app-passwall2 | [Openwrt-Passwall/openwrt-passwall2](https://github.com/Openwrt-Passwall/openwrt-passwall2) |
| chinadns-ng / dns2socks / geoview / hysteria / ipt2socks / microsocks / naiveproxy / shadow-tls / shadowsocks-rust / shadowsocksr-libev / simple-obfs / tcping / v2ray-geodata / v2ray-plugin / xray-core / xray-plugin | [Openwrt-Passwall/openwrt-passwall-packages](https://github.com/Openwrt-Passwall/openwrt-passwall-packages) |

---

## 🔧 工作原理

```
触发（手动 / repository_dispatch）
        │
        ▼
┌─────────────────────────────────────────────────┐
│ 1. Checkout AutoSync                            │
│ 2. openwrt_package.sh    ← 从上游克隆全部包      │
│ 3. convert_translation.sh ← 补齐 zh-cn/zh_Hans  │
│ 4. create_acl_for_luci.sh ← 生成 LuCI ACL       │
│ 5. Modify.sh             ← 清理杂物 + 定制修改   │
│ 6. 检测版本变更的包（PKG_VERSION/LUCI_VERSION）  │
│ 7. 逐包提交（随机 emoji + 版本/上游 commit 信息） │
│ 8. 强推 → openwrt_package 仓库                  │
│ 9. 自动清理 1 天前的 workflow 运行记录           │
└─────────────────────────────────────────────────┘
```

### 定制细节

- 🖼️ 自定义 Argon 主题壁纸（`images/bg1.jpg`）
- 🌄 禁用 Argon 在线壁纸（`option online_wallpaper 'none'`）
- 🔧 luci-theme-design / sing-box 的 Makefile 适配主流 feeds 路径
- 🧹 同步后删除所有 `.git`、`.github`、`.gitignore` 等杂物，保持包源干净

---

## 🚀 使用方法

> AutoSync 本身是**流水线仓库**，产物直接推送到 `openwrt_package` 包源。

### 部署

1. **Fork** 本仓库
2. 生成 GitHub Personal Access Token（勾选 `repo` 权限）
3. 在仓库 **Settings → Secrets and variables → Actions** 添加 `ACCESS_TOKEN`
4. 进入 **Actions** 页，手动 **Run workflow** 即可触发同步

### 触发方式

| 方式 | 说明 |
| :--- | :--- |
| 🖱️ 手动触发 | Actions 页面点击 Run workflow |
| 🔗 repository_dispatch | 外部调用 API 触发（支持 webhook / 定时任务） |

---

## ⚠️ 注意事项

- 同步会**强推** `openwrt_package` 的 `master` 分支，请勿在该仓库直接手动提交，避免被覆盖
- `README.md` 不受同步影响：每次提交前会自动还原为 HEAD 版本
- 版本变更检测基于 `PKG_VERSION` / `LUCI_VERSION`，包源更新记录可在 `openwrt_package` 的提交历史中查看

---

## 📄 相关项目

- [MinimaxFlora/openwrt_package](https://github.com/MinimaxFlora/openwrt_package) — 📦 同步产物：OpenWrt 插件包源仓库
- [MinimaxFlora/openwrt_package](https://github.com/MinimaxFlora/openwrt_package) 的 [Build Packages 工作流](https://github.com/MinimaxFlora/openwrt_package/blob/master/.github/workflows/build-packages.yml) — 一键编译 ipk/apk 并发布

## 📝 License

[MIT](LICENSE)
