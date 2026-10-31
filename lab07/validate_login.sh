#!/bin/bash
# Taras Rychkov C00319481

USERS="intel/users.csv"
OLD="case/backups/users.old"
LOG="case/logs/auth.log"
PASSWORDS="case/evidence/passwords.txt"

read -p "Enter a username: " USERNAME

if [ -z "$USERNAME" ]; then
    echo "Error: no username entered" >&2
    exit 1
fi

# Where does the account come from?
if grep -q "^$USERNAME," "$USERS"; then
    SOURCE="CURRENT"
    LINE=$(grep "^$USERNAME," "$USERS" | tr -d '\r')
    HEADER=$(head -1 "$USERS" | tr -d '\r')
    ROLE_COL=$(echo "$HEADER" | tr ',' '\n' | grep -n -i '^role$' | cut -d: -f1)
    STATUS_COL=$(echo "$HEADER" | tr ',' '\n' | grep -n -i '^status$' | cut -d: -f1)
    ROLE=$(echo "$LINE" | cut -d',' -f"${ROLE_COL:-3}")
    STATUS=$(echo "$LINE" | cut -d',' -f"${STATUS_COL:-4}")
    echo "$USERNAME: CURRENT account (role: $ROLE, status: $STATUS)"
elif tr -d '\r' < "$OLD" | grep -qx "$USERNAME"; then
    SOURCE="LEGACY"
    echo "$USERNAME: LEGACY account (only in the old backup list)"
else
    SOURCE="UNKNOWN"
    echo "$USERNAME: UNKNOWN account (in neither list)"
fi

# Count logins
FAILED=$(grep -c "Failed password for $USERNAME " "$LOG")
ACCEPTED=$(grep -c "Accepted password for $USERNAME " "$LOG")
echo "Failed logins:   $FAILED"
echo "Accepted logins: $ACCEPTED"

# Risk level (same thresholds as risk_level.sh)
if [ "$FAILED" -eq 0 ]; then
    RISK="NONE"
elif [ "$FAILED" -lt 5 ]; then
    RISK="LOW"
elif [ "$FAILED" -lt 15 ]; then
    RISK="MEDIUM"
elif [ "$FAILED" -lt 30 ]; then
    RISK="HIGH"
else
    RISK="CRITICAL"
fi
echo "Risk: $RISK"

# Warnings
if [ "$SOURCE" = "CURRENT" ] && [ "${STATUS,,}" = "disabled" ] && [ "$ACCEPTED" -gt 0 ]; then
    echo "WARNING: disabled account $USERNAME has $ACCEPTED accepted login(s)"
fi

if [ "$SOURCE" != "CURRENT" ] && [ "$FAILED" -gt 0 ]; then
    echo "WARNING: $SOURCE account $USERNAME was targeted by $FAILED failed login(s) - attacker is guessing account names"
fi

if [ "$SOURCE" = "CURRENT" ] && [ "$ACCEPTED" -gt 0 ] && grep -q "^$USERNAME:" "$PASSWORDS"; then
    echo "WARNING: $USERNAME has accepted logins AND plaintext credentials in passwords.txt"
fi

# Exit code
if [ "$SOURCE" = "CURRENT" ]; then
    exit 0
elif [ "$SOURCE" = "LEGACY" ]; then
    exit 2
else
    exit 3
fi
