#!/bin/bash

# =================================================================
# R4S System Optimization & Slimming Script
# This script removes unused services, drivers, and languages.
# R4S 系統優化與瘦身腳本
# 此腳本移除未使用的服務、驅動程式與語系。
# =================================================================

echo "Starting R4S system cleanup..."

# Update package list (更新軟體包清單)
opkg update

# Remove Adblock and its configuration
# 移除 Adblock 及其設定檔
opkg remove luci-app-adblock luci-i18n-adblock-* adblock --force-removal-of-dependent-packages
rm -f /etc/config/adblock

# Remove Aria2 download engine and temporary files
# 移除 Aria2 下載引擎與暫存檔案
opkg remove luci-app-aria2 aria2 --force-removal-of-dependent-packages
rm -rf /etc/config/aria2
rm -rf /var/run/aria2

# Remove Samba4 file sharing and related libraries
# 移除 Samba4 檔案共享與相關函式庫
opkg remove luci-app-samba4 samba4-server samba4-libs wsdd2 --force-removal-of-dependent-packages
rm -rf /etc/config/samba4
rm -rf /etc/samba/

# Remove MiniDLNA media streaming service
# 移除 MiniDLNA 多媒體串流服務
opkg remove luci-app-minidlna minidlna --force-removal-of-dependent-packages
rm -rf /etc/config/minidlna
rm -rf /var/cache/minidlna

# Remove system statistics and data collection tools
# 移除系統統計與數據收集工具
opkg remove luci-app-statistics collectd* --force-removal-of-dependent-packages

# Remove Dynamic DNS (DDNS) services
# 移除動態 DNS (DDNS) 服務
opkg remove luci-app-ddns ddns-scripts ddns-scripts-services --force-removal-of-dependent-packages
rm -f /etc/config/ddns

# Remove disk management tools and unused file systems
# 移除磁碟管理工具與未使用的檔案系統
opkg remove mkf2fs libf2fs6 hd-idle luci-app-hd-idle --force-removal-of-dependent-packages

# Remove wireless firmware (R4S lacks built-in Wi-Fi)
# 移除無線網卡韌體 (R4S 無內建 Wi-Fi)
opkg remove iwlwifi-firmware-* mt76x2-firmware mt792x-firmware rtl8822be-firmware rtl8822ce-firmware brcmfmac-firmware-usb --force-removal-of-dependent-packages

# Remove FTP server and compression utilities
# 移除 FTP 伺服器與壓縮工具
opkg remove vsftpd unrar unzip extract --force-removal-of-dependent-packages

# Remove auto-reboot utility (Watchcat)
# 移除自動重啟工具 (Watchcat)
opkg remove watchcat luci-app-watchcat --force-removal-of-dependent-packages

# Remove wireless core components and cellular protocols
# 移除無線核心組件與行動網路協議
opkg remove iw iwinfo libiwinfo-data kmod-cfg80211 kmod-brcmutil wireless-regdb wwan comgt chat uqmi umbim libqmi libmbim luci-proto-ipv6 --force-removal-of-dependent-packages

# Remove specific PPP protocols while keeping base PPPoE
# 移除特定的 PPP 協議但保留基礎 PPPoE
opkg remove ppp-mod-pppoa ppp-mod-radius ppp-mod-pppol2tp --force-removal-of-dependent-packages

# Purge all language packs except Traditional Chinese and English
# 清除除繁體中文與英文以外的所有語言包
opkg list-installed | grep luci-i18n- | grep -vE 'zh-tw|en' | awk '{print $1}' | xargs opkg remove

# Clear LuCI index and module cache (清理 LuCI 索引與模組快取)
rm -rf /tmp/luci-modulecache/
rm -rf /tmp/luci-indexcache

echo "Cleanup complete! (清理完成！)"
