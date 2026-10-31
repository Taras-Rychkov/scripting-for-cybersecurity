#!/bin/bash
# Taras Rychkov C00319481

LOG="case/logs/auth.log"

if grep -q "Failed password" "$LOG"; then
    if grep -q "Accepted password" "$LOG"; then
        echo "$LOG contains both failed and accepted logins."
    else
        echo "$LOG contains only failed logins."
    fi
else
    echo "$LOG contains no failed login attempts."
fi
