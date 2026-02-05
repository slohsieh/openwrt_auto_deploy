#!/bin/sh

<< 'MULTILINE_COMMENT'
This script configures the system timezone, NTP settings, updates the 
LAN IP address to 192.168.1.1, and sets a scheduled reboot every 
Monday at 06:00 AM.
Note: Changing the LAN IP will disconnect your current SSH session.

本腳本配置系統時區、NTP 設定、將 LAN IP 地址更改為 192.168.1.1，
並設定每週一早上 06:00 自動重啟。
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

# Enable NTP client (啟用 NTP 客戶端)
uci set system.ntp.enable_server='0'
uci set system.ntp.enabled='1'
uci commit system

# Scheduled Reboot Setting (定時重啟設定)
echo "Configuring scheduled reboot every Monday at 06:00... (正在設定每週一 06:00 定時重啟...)"

# Add cron job: 06:00 on Monday (Day 1) (加入計畫任務：週一 06:00)
# Format: Minute Hour Day Month Weekday Command
CRON_REBOOT="0 6 * * 1 reboot"
if ! grep -q "$CRON_REBOOT" /etc/crontabs/root; then
    echo "$CRON_REBOOT" >> /etc/crontabs/root
fi

# Change LAN IP Address (修改 LAN IP 地址)
echo "Changing LAN IP to 192.168.1.1... (正在將 LAN IP 修改為 192.168.1.1...)"
uci set network.lan.ipaddr='192.168.1.1'
uci commit network

# Optional: Disable IPv6 to prevent DNS leaks through ISP (選用：禁用 IPv6 以防止 DNS 洩漏)
echo "Disabling IPv6 for maximum compatibility... (正在禁用 IPv6 以確保最高相容性...)"
uci set 'network.lan.ipv6=0'
uci set 'network.wan.ipv6=0'
uci set 'network.wan6.disabled=1'
uci commit network

# 限制 SSH 僅監聽 LAN IP (192.168.1.1)
# 將 SSH 埠號從 22 改為 2222
uci set dropbear.@dropbear[0].Interface='lan'
uci set dropbear.@dropbear[0].Port='2256'
uci commit dropbear
/etc/init.d/dropbear restart

# Apply changes and restart services (套用更改並重啟服務)
echo "Applying changes and restarting services... (正在套用更改並重啟服務...)"
echo "Your SSH connection will drop. Please reconnect using 192.168.1.1. (SSH 連線將中斷，請使用 192.168.1.1 重新連線。)"

# Execute service restarts (執行服務重啟)
/etc/init.d/system restart
/etc/init.d/sysntpd restart
/etc/init.d/cron enable
/etc/init.d/cron restart
/etc/init.d/network restart
