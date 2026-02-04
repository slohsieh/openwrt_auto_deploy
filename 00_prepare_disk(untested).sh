#!/bin/sh

<< 'MULTILINE_COMMENT'
This script identifies unallocated space on the primary storage device,
creates a new data partition, and configures auto-mount to /mnt/sda1.
This ensures data persistence across system re-flashes.

This script is designed for general OpenWrt environments.

本腳本識別主儲存裝置上的未分配空間，建立一個新的數據分區，
並將其設定為自動掛載至 /mnt/sda1。
這能確保在重新燒錄系統後，數據依然可以保留。
本腳本適用於一般性的 OpenWrt 環境。
MULTILINE_COMMENT

# Define disk and partition variables (定義磁碟與分區變數)
# In most SD-based or MMC-based OpenWrt devices, this is /dev/mmcblk0
DISK_DEV="/dev/mmcblk0"
PART_DEV="/dev/mmcblk0p3"
MOUNT_POINT="/mnt/sda1"

echo "Checking environment and required tools... (檢查環境與必要工具...)"

# Update package list and install requirements if missing (更新套件清單並安裝缺少的必要工具)
if [ -z "$(which fdisk)" ] || [ -z "$(which mkfs.ext4)" ]; then
    echo "Required tools missing. Installing fdisk and e2fsprogs... (缺少必要工具，正在安裝 fdisk 與 e2fsprogs...)"
    opkg update
    [ -z "$(which fdisk)" ] && opkg install fdisk
    [ -z "$(which mkfs.ext4)" ] && opkg install e2fsprogs
fi

echo "Checking disk partition status... (檢查磁碟分區狀態...)"

# Check if the data partition already exists (檢查數據分區是否已存在)
if [ -b "$PART_DEV" ]; then
    echo "Found existing partition $PART_DEV. Skipping creation... (發現已存在的分區 $PART_DEV，跳過建立步驟...)"
else
    echo "Creating new partition... (正在建立新分區...)"
    
    # Use fdisk to create a new primary partition using all remaining space (使用 fdisk 建立新的主要分區，並使用所有剩餘空間)
    (
    echo n # Add a new partition (新增分區)
    echo p # Primary partition (主要分區)
    echo 3 # Partition number (分區編號)
    echo   # Default first sector (預設起始磁區)
    echo   # Default last sector (預設結束磁區)
    echo w # Write changes and exit (寫入更改並離開)
    ) | fdisk $DISK_DEV
    
    echo "Formatting partition to Ext4... (正在將分區格式化為 Ext4...)"
    # Force format the new partition (強制格式化新分區)
    mkfs.ext4 -F $PART_DEV
fi

# Create mount point directory if it does not exist (如果掛載點目錄不存在則建立它)
mkdir -p $MOUNT_POINT

# Configure auto-mount using UCI fstab (使用 UCI 設定 fstab 自動掛載)
echo "Configuring auto-mount to $MOUNT_POINT... (設定自動掛載到 $MOUNT_POINT...)"

# Remove any existing fstab entry for this mount point to avoid duplicates (刪除此掛載點已存在的舊設定，避免重複)
uci -q delete fstab.@mount[0]

# Add new fstab mount configuration (新增 fstab 掛載配置)
uci add fstab mount
uci set fstab.@mount[-1].target=$MOUNT_POINT
uci set fstab.@mount[-1].device=$PART_DEV
uci set fstab.@mount[-1].fstype='ext4'
uci set fstab.@mount[-1].enabled='1'
uci commit fstab

# Enable and restart fstab service (啟用並重啟 fstab 服務)
/etc/init.d/fstab enable
/etc/init.d/fstab restart

echo "Disk preparation completed! (磁碟準備完成！)"
# Display current mount status for verification (顯示當前掛載狀態以供確認)
df -h | grep $MOUNT_POINT
