#!/bin/bash
# Collect and publish build info
# Usage: ./build-info.sh <build-name> <build-number> [server-id] [collect-git] [collect-env]
#
# Arguments:
#   build-name   - Build name
#   build-number - Build number
#   server-id    - Server ID (default: "jfrog-server")
#   collect-git  - Collect git info: true/false (default: true)
#   collect-env  - Collect env vars: true/false (default: true)

set -e

BUILD_NAME="${1:?Build name is required}"
BUILD_NUMBER="${2:?Build number is required}"
SERVER_ID="${3:-jfrog-server}"
COLLECT_GIT="${4:-true}"
COLLECT_ENV="${5:-true}"

echo "Publishing build info..."
echo "Build: $BUILD_NAME/$BUILD_NUMBER"
echo "Server: $SERVER_ID"

# Collect Git info
if [ "$COLLECT_GIT" = "true" ]; then
    if [ -d ".git" ]; then
        echo "Collecting Git information..."
        jf rt build-add-git "$BUILD_NAME" "$BUILD_NUMBER" --server-id="$SERVER_ID"
    else
        echo "Skipping Git collection (not a git repository)"
    fi
fi

# Collect environment variables
if [ "$COLLECT_ENV" = "true" ]; then
    echo "Collecting environment variables..."
    jf rt build-collect-env "$BUILD_NAME" "$BUILD_NUMBER" --server-id="$SERVER_ID"
fi

# Publish build info
echo "Publishing build info..."
jf rt build-publish "$BUILD_NAME" "$BUILD_NUMBER" --server-id="$SERVER_ID"

echo "Build info published successfully"

