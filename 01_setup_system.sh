#!/bin/sh

<< 'MULTILINE_COMMENT'
This script configures the system timezone, NTP settings, increases the 
log buffer size, and sets a scheduled reboot every Monday at 06:00 AM.
It also disables IPv6 for better compatibility.

本腳本配置系統時區、NTP 設定、加大系統日誌緩衝區、禁用 IPv6，
並設定每週一早上 06:00 自動重啟。
MULTILINE_COMMENT

# --- Define Variables (定義變數) ---
TIMEZONE_STR="CST-8"
TIMEZONE_NAME="Asia/Taipei"

# --- System Timezone (系統時區) ---
echo "Configuring system timezone... (正在配置系統時區...)"
uci set system.@system[0].zonename="$TIMEZONE_NAME"
uci set system.@system[0].timezone="$TIMEZONE_STR"
uci commit system

# --- System: Increase Log Buffer Size (加大系統日誌緩衝區) ---
echo "Increasing system log buffer size to 1MB... (正在加大系統日誌緩衝區至 1MB...)"
uci set system.@system[0].log_size='512'
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
# 確保目錄存在
mkdir -p /etc/crontabs
if ! grep -q "$CRON_REBOOT" /etc/crontabs/root 2>/dev/null; then
    echo "$CRON_REBOOT" >> /etc/crontabs/root
fi

# --- Network: Disable IPv6 (禁用 IPv6) ---
echo "Disabling IPv6 for maximum compatibility... (正在禁用 IPv6...)"
uci set 'network.lan.ipv6=0'
uci set 'network.wan.ipv6=0'
uci set 'network.wan6.disabled=1'
uci commit network

# --- Apply Changes and Restart Services (套用更改與重啟服務) ---
echo "-------------------------------------------------------"
echo "Applying changes and restarting services..."
echo "Done! Configuration completed. (配置完成！)"
echo "-------------------------------------------------------"

/etc/init.d/system restart
/etc/init.d/sysntpd restart
/etc/init.d/cron enable
/etc/init.d/cron restart
/etc/init.d/network restart
