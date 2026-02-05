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

# --- Define Variables (定義變數) ---
TIMEZONE_STR="CST-8"
TIMEZONE_NAME="Asia/Taipei"
LAN_IP="192.168.1.1"

# --- System Timezone (系統時區) ---
echo "Configuring system timezone... (正在配置系統時區...)"
uci set system.@system[0].zonename="$TIMEZONE_NAME"
uci set system.@system[0].timezone="$TIMEZONE_STR"
uci commit system

# --- NTP Settings (NTP 時間同步) ---
echo "Setting up NTP settings... (正在設定 NTP 設定...)"
uci delete system.ntp.server
uci add_list system.ntp.server='0.tw.pool.ntp.org'
uci add_list system.ntp.server='1.tw.pool.ntp.org'
uci add_list system.ntp.server='time.google.com'
uci add_list system.ntp.server='time.windows.com'
uci set system.ntp.enable_server='0'
uci set system.ntp.enabled='1'
uci commit system

# --- Scheduled Reboot (定時重啟) ---
echo "Configuring scheduled reboot every Monday at 06:00... (正在設定每週一 06:00 定時重啟...)"
CRON_REBOOT="0 6 * * 1 reboot"
if ! grep -q "$CRON_REBOOT" /etc/crontabs/root; then
    echo "$CRON_REBOOT" >> /etc/crontabs/root
fi

# --- Network: LAN IP Address (修改 LAN IP) ---
echo "Changing LAN IP to $LAN_IP... (正在將 LAN IP 修改為 $LAN_IP...)"
uci set network.lan.ipaddr="$LAN_IP"
uci commit network

# --- Network: Disable IPv6 (禁用 IPv6) ---
echo "Disabling IPv6 for maximum compatibility... (正在禁用 IPv6...)"
uci set 'network.lan.ipv6=0'
uci set 'network.wan.ipv6=0'
uci set 'network.wan6.disabled=1'
uci commit network

# --- Apply Changes and Restart Services (套用更改與重啟服務) ---
echo "-------------------------------------------------------"
echo "Applying changes and restarting services..."
echo "Your SSH connection will drop. Please reconnect using $LAN_IP."
echo "SSH 連線將中斷，請稍後使用 $LAN_IP 重新連線。"
echo "-------------------------------------------------------"

/etc/init.d/system restart
/etc/init.d/sysntpd restart
/etc/init.d/cron enable
/etc/init.d/cron restart
/etc/init.d/network restart
