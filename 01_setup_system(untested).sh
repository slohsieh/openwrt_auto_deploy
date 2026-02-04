#!/bin/sh

<< 'MULTILINE_COMMENT'
This script configures the system timezone, NTP settings (including enabling 
the NTP client), and updates the LAN IP address to 192.168.1.1. 
Note: Changing the LAN IP will disconnect your current SSH session.

本腳本配置系統時區、NTP 設定（包含啟用 NTP 客戶端），
並將 LAN IP 地址更改為 192.168.1.1。
注意：更改 LAN IP 將會中斷您目前的 SSH 連線。
MULTILINE_COMMENT

# Define timezone variables (定義時區變數)
TIMEZONE_STR="CST-8"
TIMEZONE_NAME="Asia/Taipei"

echo "Configuring system timezone... (正在配置系統時區...)"

# Set the timezone string and display name (設定時區字串與顯示名稱)
uci set system.@system[0].zonename=$TIMEZONE_NAME
uci set system.@system[0].timezone=$TIMEZONE_STR
uci commit system

# Configure NTP servers and enable NTP client (配置 NTP 伺服器並啟用 NTP 客戶端)
echo "Setting up NTP settings... (正在設定 NTP 設定...)"

# Clear existing NTP server list (清除現有的 NTP 伺服器清單)
uci delete system.ntp.server
uci add_list system.ntp.server='0.tw.pool.ntp.org'
uci add_list system.ntp.server='1.tw.pool.ntp.org'
uci add_list system.ntp.server='time.google.com'
uci add_list system.ntp.server='time.windows.com'

# Enable NTP client and disable NTP server mode (啟用 NTP 客戶端並禁用 NTP 服務端模式)
uci set system.ntp.enable_server='0'
uci set system.ntp.enabled='1'
uci commit system

# Change LAN IP Address (修改 LAN IP 地址)
# Change from default to 192.168.1.1 (將預設值修改為 192.168.1.1)
echo "Changing LAN IP to 192.168.1.1... (正在將 LAN IP 修改為 192.168.1.1...)"
uci set network.lan.ipaddr='192.168.1.1'
uci commit network

# Apply changes and restart services (套用更改並重啟服務)
echo "Applying changes and restarting network... (正在套用更改並重啟網路...)"
echo "Your SSH connection will drop. Please reconnect using 192.168.1.1. (SSH 連線將中斷，請使用 192.168.1.1 重新連線。)"

# Execute service restarts (執行服務重啟)
/etc/init.d/system restart
/etc/init.d/sysntpd restart
/etc/init.d/network restart
