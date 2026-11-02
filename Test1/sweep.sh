#!/bin/bash
# Part 1: sweep every IOC across the logs. Part 2: chech evidence MD5 hashes.

IOCS="exam-data/intel/iocs.txt"
GRAND_TOTAL=0

echo "=== IOC sweep ==="
for IOC in $(cat "$IOCS"); do
	LOGS_SEEN=0

	for LOG in exam-data/case/logs/*.log; do
	   HITS=$(grep -cwF "$IOC" "$LOG")

	   if [ "$HITS" -gt 0 ]; then
		echo "IOC | $(basename "$LOG") | $HITS lines"
		LOGS_SEEN=$((LOGS_SEEN + 1))
		GRAND_TOTAL=$((GRAND_TOTAL + HITS))
	   fi
	done

	echo "$IOC seen in $LOGS_SEEN log(s)"
done
echo "Total matching lines: $GRAND_TOTAL"

echo "=== Hash check ==="
for ITEM in exam-data/case/evidence/*; do
	if [ ! -f "$ITEM" ]; then
	    continue
	fi

	MD5=$(md5sum "$ITEM" | cut -d' ' -f1)

	if grep -qxF "$MD5" "$IOCS"; then
	   echo "KNOWN BAD: $ITEM"
	else
	   echo "clean : $ITEM"
	fi
done
