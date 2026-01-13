#!/bin/bash
# Scan build with Xray
# Usage: ./scan.sh <build-name> <build-number> [server-id] [fail-on-issue]
#
# Arguments:
#   build-name    - Build name
#   build-number  - Build number
#   server-id     - Server ID (default: "jfrog-server")
#   fail-on-issue - Fail if issues found: true/false (default: true)

set -e

BUILD_NAME="${1:?Build name is required}"
BUILD_NUMBER="${2:?Build number is required}"
SERVER_ID="${3:-jfrog-server}"
FAIL_ON_ISSUE="${4:-true}"

echo "Scanning build with Xray..."
echo "Build: $BUILD_NAME/$BUILD_NUMBER"
echo "Server: $SERVER_ID"
echo "Fail on issues: $FAIL_ON_ISSUE"

FAIL_FLAG="--fail=false"
if [ "$FAIL_ON_ISSUE" = "true" ]; then
    FAIL_FLAG="--fail=true"
fi

jf rt build-scan "$BUILD_NAME" "$BUILD_NUMBER" \
    --server-id="$SERVER_ID" \
    $FAIL_FLAG

echo "Scan complete"

