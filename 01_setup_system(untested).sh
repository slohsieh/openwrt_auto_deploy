#!/bin/sh

<< 'MULTILINE_COMMENT'
This script configures the system timezone and NTP (Network Time Protocol) 
settings to ensure accurate system time. Accurate time is essential for 
log consistency and security certificate validation.

This script is intended for general OpenWrt environments.

本腳本配置系統時區與 NTP（網路時間協議）設定，以確保系統時間準確。
準確的時間對於日誌一致性與安全憑證驗證至關重要。
本腳本適用於一般性的 OpenWrt 環境。
MULTILINE_COMMENT

# Define timezone variables (定義時區變數)
# CST-8 is the standard timezone string for Asia/Taipei
TIMEZONE_STR="CST-8"
TIMEZONE_NAME="Asia/Taipei"

echo "Configuring system timezone... (正在配置系統時區...)"

# Set the timezone string and display name (設定時區字串與顯示名稱)
uci set system.@system[0].zonename=$TIMEZONE_NAME
uci set system.@system[0].timezone=$TIMEZONE_STR
uci commit system

# Configure NTP servers (配置 NTP 伺服器)
echo "Setting up NTP servers... (正在設定 NTP 伺服器...)"

# Clear existing NTP server list to avoid conflicts (清除現有的 NTP 伺服器清單以避免衝突)
uci delete system.ntp.server
uci add_list system.ntp.server='0.tw.pool.ntp.org'
uci add_list system.ntp.server='1.tw.pool.ntp.org'
uci add_list system.ntp.server='time.google.com'
uci add_list system.ntp.server='time.windows.com'

# Enable NTP client (啟用 NTP 客戶端)
uci set system.ntp.enable_server='0'
uci set system.ntp.enabled='1'
uci commit system

# Apply changes and restart services (套用更改並重啟服務)
echo "Restarting system services to apply time settings... (正在重啟系統服務以套用時間設定...)"
/etc/init.d/system restart
/etc/init.d/sysntpd restart

# Verification (驗證)
echo "Current system time: $(date) (目前系統時間)"

echo "System time optimization completed! (系統時間優化完成！)"
