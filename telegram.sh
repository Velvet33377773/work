#!/bin/bash

BOT_TOKEN=''
CHAT_ID=''

upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
secs=$((${upSeconds}%60))
mins=$((${upSeconds}/60%60))
hours=$((${upSeconds}/3600%24))
days=$((${upSeconds}/86400))
UPTIME=$(printf "%d days, %02dh %02dm %02ds " "$days" "$hours" "$mins" "$secs")

CPU_USAGE=$(top -bn1 | grep load | awk '{printf "%.2f%%\n", $(NF-2)}')

MEM_USED=$(free -h |awk '/Mem/ { printf $7 }')

target_date="2025-10-04"

current_date=$(date +%Y-%m-%d)

target_seconds=$(date -d "$target_date" +%s)
current_seconds=$(date -d "$current_date" +%s)

difference=$(( (target_seconds - current_seconds) / 86400 ))


MESSAGE="
================
Date: 
$(date +'%d.%m.%Y %H:%M:%S')
================

================
System information:
================
UPTIME: $UPTIME
SSD: $(df -h |grep vda1 |awk '{ print $4 }')
CPU: $CPU_USAGE
RAM: $MEM_USED
NET: $(vnstat -i eth0 -h 2 |tail -n 3 |grep -v - |head -n1 | awk '{ print $2 $3 $4 $5 $6 $7 $8 $9}')

Block: $(fail2ban-client status sshd | grep 'Currently banned' |cut -d : -f2)
Users online: $(w | awk '/USER/ {p=1; next} p {print $1}')

Payday: $difference дней
"

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" -d chat_id="${CHAT_ID}" -d text="${MESSAGE}" 2>&1 >/dev/null
