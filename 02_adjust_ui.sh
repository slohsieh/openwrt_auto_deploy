#!/bin/sh

<< 'MULTILINE_COMMENT'
【 腳本功能：UI 套件安裝與 Argon 主題終極自動化 】
1. 更新軟體源並安裝核心相依組件 (luci-compat, ttyd, nlbwmon)。
2. 從 GitHub 抓取適用於 OpenWrt 23.05+ 的最新 Argon 主題與配置插件。
3. 自動初始化 UCI 設定區段，防止寫入失敗。
4. 開啟 Bing 每日壁紙與主題自動切換模式。
5. 清除系統快取並重啟 Web 服務。
MULTILINE_COMMENT

# --- Step 1: 基礎環境準備 ---
echo "Step 1: Updating package list and installing core components..."
opkg update
# 安裝流量統計、網頁終端以及 Argon 必備的相容性套件
opkg install luci-app-nlbwmon luci-app-ttyd luci-compat luci-lib-ipkg

# --- Step 2: 下載並安裝 Argon 主題與配置插件 ---
echo "Step 2: Downloading latest Argon Theme from GitHub..."
cd /tmp

# 定義下載版本 (針對 OpenWrt 23.05+ 的版本)
ARGON_URL="https://github.com/jerrykuku/luci-theme-argon/releases/download/v2.3.2/luci-theme-argon_2.3.2-r20250207_all.ipk"
ARGON_CONFIG_URL="https://github.com/jerrykuku/luci-app-argon-config/releases/download/v0.9/luci-app-argon-config_0.9_all.ipk"

# 執行下載
wget --no-check-certificate $ARGON_URL
wget --no-check-certificate -O luci-app-argon-config_0.9_all.ipk $ARGON_CONFIG_URL

# 本地安裝 ipk 檔案
echo "Installing Argon ipk files..."
opkg install luci-theme-argon*.ipk
opkg install luci-app-argon-config*.ipk --force-overwrite

# --- Step 3: 自動化設定 Argon 偏好 ---
echo "Step 3: Configuring Argon preference settings..."

# 確保設定檔存在
[ ! -f /etc/config/argon ] && touch /etc/config/argon

#
