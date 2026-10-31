#!/bin/bash
# Taras Rychkov C00319481

CONF=$1
DEBUG=$(grep '^debug=' "$CONF" | cut -d'=' -f2 | tr -d '\r')
DEBUG_LOWER="${DEBUG,,}"

if [ -z "$DEBUG" ]; then
    echo "$CONF: no debug setting"
elif [ "$DEBUG_LOWER" = "true" ] || [ "$DEBUG_LOWER" = "yes" ]; then
    echo "$CONF: WARNING - debug mode is ON"
elif [ "$DEBUG_LOWER" = "false" ] || [ "$DEBUG_LOWER" = "no" ]; then
    echo "$CONF: debug mode is off"
else
    echo "$CONF: unexpected debug value '$DEBUG'"
fi
