#!/bin/bash

# =================================================================
# AdGuard Home Docker Deployment Script
# This script creates persistence directories and starts the AGH container.
# AdGuard Home Docker 部署腳本
# 此腳本建立持久化資料夾並啟動 AGH 容器。
# =================================================================

# Create directories in /opt for persistence (在 /opt 建立持久化資料夾)
mkdir -p /opt/adguardhome/conf
mkdir -p /opt/adguardhome/work

# Pull and run AdGuard Home container
# 下載並執行 AdGuard Home 容器
docker run -d \
  --name adguardhome \
  --restart unless-stopped \
  --network host \
  -v /opt/adguardhome/conf:/opt/adguardhome/conf \
  -v /opt/adguardhome/work:/opt/adguardhome/work \
  adguard/adguardhome
# Check container status (檢查容器狀態)
docker ps | grep adguardhome
