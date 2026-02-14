#!/bin/sh

<< 'MULTILINE_COMMENT'
本腳本功能：
1. 切換 opkg 軟體源至官方預設來源 (downloads.openwrt.org)。
2. 配置系統時區 (Asia/Taipei)。
3. 加大系統日誌緩衝區 (1MB)。
4. 設定台灣 NTP 時間同步伺服器。
5. 禁用 IPv6 以提高相容性。
6. 設定每週一 06:00 定時重啟。
MULTILINE_COMMENT

# --- Step 0: Switch Software Source (切換軟體源) ---
echo "Switching opkg source to downloads.openwrt.org... (正在切換軟體源...)"
# 使用 sed 將中科大鏡像替換回官方來源
sed -i -e 's/mirrors.ustc.edu.cn\/openwrt/downloads.openwrt.org/g' /etc/opkg/distfeeds.conf
# 立即更新清單以驗證
opkg update

# --- Define Variables (定義變數) ---
TIMEZONE_STR="CST-8"
TIMEZONE_NAME="Asia/Taipei"

# --- System Timezone (系統時區) ---
echo "Configuring system timezone... (正在配置系統時區...)"
uci set system.@system[0].zonename="$TIMEZONE_NAME"
uci set system.@system[0].timezone="$TIMEZONE_STR"
uci commit system

# --- System: Increase Log Buffer Size (加大系統日誌緩衝區) ---
echo "Increasing system log buffer size to 1MB..."
uci set system.@system[0].log_size='1024'
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
echo "Configuring scheduled reboot every Monday at 06:00..."
CRON_REBOOT="0 6 * * 1 reboot"
mkdir -p /etc/crontabs
if ! grep -q "$CRON_REBOOT" /etc/crontabs/root 2>/dev/null; then
    echo "$CRON_REBOOT" >> /etc/crontabs/root
fi

# --- Network: Disable IPv6 (禁用 IPv6) ---
echo "Disabling IPv6..."
uci set 'network.lan.ipv6=0'
uci set 'network.wan.ipv6=0'
uci set 'network.wan6.disabled=1'
uci commit network

# --- Apply Changes and Restart Services (套用更改與重啟服務) ---
echo "-------------------------------------------------------"
echo "Applying changes and restarting services..."
echo "Done! Configuration completed."
echo "-------------------------------------------------------"

/etc/init.d/system restart
/etc/init.d/sysntpd restart
/etc/init.d/cron enable
/etc/init.d/cron restart
/etc/init.d/network restart
