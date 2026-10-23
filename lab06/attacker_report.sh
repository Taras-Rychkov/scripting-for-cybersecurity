#!/bin/bash
# Taras Rychkov C00319481
# attacker_report.sh - summary of failed SSH logins in a log file
# Usage: ./attacker_report.sh <logfile>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <logfile>" >&2
    exit 1
fi

LOGFILE=$1

if [ ! -f "$LOGFILE" ]; then
    echo "Error: file '$LOGFILE' not found" >&2
    exit 2
fi

FAILED=$(grep -c "Failed password" "$LOGFILE")

TOP_IP=$(grep "Failed password" "$LOGFILE" |
    awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' |
    sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')

TOP_USERS=$(grep "Failed password" "$LOGFILE" |
    awk '{for(i=1;i<=NF;i++) if($i=="for") print $(i+1)}' |
    sort | uniq -c | sort -nr | head -n 3)

echo "Report for      : $LOGFILE"
echo "Failed logins   : $FAILED"
echo "Top attacker    : ${TOP_IP:-none}"
echo ""
"$(dirname "$0")/top3.sh" "$LOGFILE"
echo ""
echo "Top 3 targeted usernames:"
echo "$TOP_USERS"

exit 0
