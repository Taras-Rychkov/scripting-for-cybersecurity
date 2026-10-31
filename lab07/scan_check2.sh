#!/bin/bash
# Taras Rychkov C00319481

grep -q "sqlmap" case/logs/access.log
if [ $? -eq 0 ]; then
    echo "Scanning tool activity detected"
else
    echo "No scanning tool activity"
fi
