#!/bin/bash
# Taras Rychkov C00319481
# top3.sh - top 3 failed-login source IPs (optional log file as $1)

AUTH_LOG=${1:-case/logs/auth.log}

TOP_ATTACKERS=$(grep "Failed password" "$AUTH_LOG" |
    awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' |
    sort | uniq -c | sort -nr | head -n 3)

echo "Top 3 failed-login sources:"
echo "$TOP_ATTACKERS"
