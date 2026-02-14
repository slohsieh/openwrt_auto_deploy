#!/bin/sh

<< 'MULTILINE_COMMENT'
【腳本功能：UI 套件安裝與 Argon 主題自動化設定】
1. 更新套件清單並安裝：Argon 主題、配置插件、流量統計 (nlbwmon)、網頁終端 (ttyd)。
2. 自動配置 Argon：開啟 Bing 每日桌布、設定自動黑夜/白天模式。
3. 強制將 Argon 設定為系統預設主題。
4. 清理 LuCI 快取並重啟相關服務。
MULTILINE_COMMENT

# --- Step 1: 軟體包更新 ---
echo "Updating package list... (正在更新軟體包清單...)"
opkg update

# --- Step 2: 安裝 UI 組件與服務 ---
# 這些是打造現代化 OpenWrt 的核心 UI 套件
echo "Installing UI components: Argon theme, nlbwmon, and ttyd..."
opkg install luci-theme-argon luci-app-argon-config luci-app-nlbwmon luci-app-ttyd

# --- Step 3: 配置 Argon 主題偏好 ---
echo "Configuring Argon theme settings..."

# 檢查 argon 設定檔是否存在，若不存在則初始化
if [ ! -f /etc/config/argon ]; then
    touch /etc/config/argon
fi

# 確保 global[0] 區段存在，否則 uci set 會失敗
if ! uci get argon.@global[0] >/dev/null 2>&1; then
    uci add argon global
fi

# 開啟 Bing 每日桌布 (1: 開啟)
uci set argon.@global[0].bing_wallpaper='1'

# 設定主題模式為自動切換 (auto)
uci set argon.@global[0].theme_mode='auto'

# 儲存 Argon 設定
uci commit argon

# 將 Argon 設為 LuCI 預設界面主題
echo "Setting Argon as the default theme..."
uci set luci.main.mediaurlbase='/luci-static/argon'
uci commit luci

# --- Step 4: 清理並套用變更 ---
echo "-------------------------------------------------------"
echo "Cleaning up caches and restarting services..."

# 強制清除 LuCI 快取，避免主題切換後介面跑版
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache

# 重啟 Web 服務以套用新主題
/etc/init.d/uhttpd restart

# 啟用流量統計服務
echo "Enabling nlbwmon (Traffic Monitor)..."
/etc/init.d/nlbwmon enable
/etc/init.d/nlbwmon restart

# 啟用網頁終端機服務
echo "Enabling ttyd (Web Terminal)..."
/etc/init.d/ttyd enable
/etc/init.d/ttyd restart

echo "-------------------------------------------------------"
echo "UI Adjustment Complete! (UI 優化完成！)"
echo "請重新整理瀏覽器頁面，你將看到全新的 Argon 介面。"
echo "登入畫面現在會顯示 Bing 每日美圖。"
echo "-------------------------------------------------------"
