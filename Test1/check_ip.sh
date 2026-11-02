#!/bin/bash
# Investigate one IPv4 address across the logs and the IOC list


if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <ip_address>" >$2
	exit 1
fi

ADDR="$1"
if ! [[ "$ADDR" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	echo "Error: '$ADDR' is not an IPv4 address" >$2
	exit 1
fi

LOGS="exam-data/case/logs"
AUTH="$LOGS/auth.log"
FW="$LOGS/firewall.log"
IOCS="exam-data/intel/iocs.txt"

FAIL_COUNT=$(grep -F "Failed password" "$AUTH" | grep -Fc " from $ADDR ")
OK_COUNT=$(grep -F "Accepted password" "$AUTH" | grep -Fc " from $ADDR ")

echo "IP	: $ADDR"
echo "Failed    : $FAIL_COUNT"
echo "Accepted  : $OK_COUNT"

if [ "$FAIL_COUNT" -ge 10 ]; then
	RISK="HIGH"
elif [ "$FAIL_COUNT" -ge 5 ]; then
	RISK="MEDIUM"
elif [ "$FAIL_COUNT" -ge 1 ]; then
	RISK="LOW"
else
	RISK="NONE"
fi
echo "Risk      : $RISK"

if grep -qxF "$ADDR" "$IOCS"; then
	echo "IOC : yes"
else
	echo "IOC : no"
fi

FW_LINES=$(grep -wF "$ADDR" "$FW")
if [ -n "$FW_LINES" ]; then
	echo "$FW_LINES"
else
	echo "Firewall: no entries"
fi

if [ "$FAIL_COUNT" -gt 0 ] && [ "$OK_COUNT" -gt 0 ]; then
	echo "WARNING: successful login after failed attempts"
fi

if grep -qwF "$ADDR" "$LOGS"/*;then
	exit 0
fi

exit 3
