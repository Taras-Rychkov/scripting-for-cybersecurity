#!/bin/bash
# Taras Rychkov C00319481

LOGFILE=$1
KEYWORD=$2

echo "Searching for '$KEYWORD' in $LOGFILE..."
grep "$KEYWORD" "$LOGFILE"
