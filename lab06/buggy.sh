#!/bin/bash
# Taras Rychkov C00319481

if [ ! -f "$1" ]; then
    echo "Error: file not found" >&2
    exit 1
fi

echo "Continuing anyway..."
exit 0
