#!/bin/bash
# Taras Rychkov C00319481

COUNT=$1

# Fixed: most specific condition first
if [ "$COUNT" -ge 10 ]; then
    echo "At least 10"
elif [ "$COUNT" -ge 0 ]; then
    echo "Non-negative"
else
    echo "Negative"
fi
