#!/bin/bash
# Print a short summary of one log file.

if [ "$#" -ne 1 ]; then
	echo "usage: $0 <logfile>" >$2
	exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
	echo "Error: '$FILE' does not exist " >$2
	exit 2
fi

if [ ! -s "$FILE" ]; then
	echo "Error: '$FILE' is empty" >$2
	exit 3
fi

TOTAL=$(wc -l < "$FILE")
FAILED=$(grep -c "Failed password" "$FILE")
ACCEPTED=$(grep -c "Accepted password" "$FILE")
FIRST=$(head -n 1 "$FILE" | cut -d' ' -f1-3)
LAST=$(tail -n 1 "$FILE" | cut -d' ' -f1-3)

echo "File     : $FILE"
echo "Lines    : $TOTAL"
echo "Failed   : $FAILED"
echo "Accepted : $ACCEPTED"
echo "First    : $FIRST"
echo "Last     : $LAST"

exit 0
