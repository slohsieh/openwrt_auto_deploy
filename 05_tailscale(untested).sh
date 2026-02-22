#!/bin/sh

# 1. 更新軟體源並安裝基礎依賴
echo "正在安裝基礎依賴..."
opkg update
opkg install tailscale iptables-nft kmod-tun

# 2. 停止可能正在運行的舊服務並清理環境
echo "清理舊進程與殘留檔案..."
/etc/init.d/tailscale stop
killall -9 tailscaled 2>/dev/null
rm -f /var/run/tailscale/tailscaled.sock

# 3. 下載並替換最新版本核心 (ARM64)
echo "從官網下載最新版本核心..."
cd /tmp
wget -O tailscale_latest.tgz https://pkgs.tailscale.com/stable/tailscale_latest_arm64.tgz
tar xzf tailscale_latest.tgz
cd tailscale_*_arm64

# 4. 覆蓋系統檔案
echo "替換系統執行檔至 v1.94.2+..."
rm -f /usr/sbin/tailscale /usr/sbin/tailscaled
cp tailscale /usr/sbin/tailscale
cp tailscaled /usr/sbin/tailscaled
chmod +x /usr/sbin/tailscale /usr/sbin/tailscaled

# 5. 建立必要的狀態儲存目錄
mkdir -p /var/lib/tailscale

# 6. 啟動服務
echo "啟動 Tailscale 服務..."
tailscaled --state=/var/lib/tailscale/tailscaled.state --port=41641 &
tailscale up --accept-dns=false --advertise-exit-node --advertise-routes=192.168.1.0/24

# 7. 提示使用者進行驗證
echo "-----------------------------------------------"
echo "安裝完成！目前的版本為："
tailscale version
echo "-----------------------------------------------"
echo "請執行以下指令來完成登入與設定出口節點："
echo "tailscale up --advertise-exit-node --advertise-routes=192.168.1.0/24"
echo "-----------------------------------------------"
