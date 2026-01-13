#!/bin/bash
# Download artifacts from Artifactory
# Usage: ./download.sh <source> <target> [build-name] [build-number] [server-id]
#
# Arguments:
#   source       - Source path/pattern in Artifactory
#   target       - Local target directory
#   build-name   - Build name for build info (optional)
#   build-number - Build number for build info (optional)
#   server-id    - Server ID from configure (default: "jfrog-server")

set -e

SOURCE="${1:?Source path is required}"
TARGET="${2:-.}"
BUILD_NAME="${3:-}"
BUILD_NUMBER="${4:-}"
SERVER_ID="${5:-jfrog-server}"

echo "Downloading artifacts..."
echo "Source: $SOURCE"
echo "Target: $TARGET"
echo "Server: $SERVER_ID"

BUILD_FLAGS=""
if [ -n "$BUILD_NAME" ] && [ -n "$BUILD_NUMBER" ]; then
    BUILD_FLAGS="--build-name=$BUILD_NAME --build-number=$BUILD_NUMBER"
fi

jf rt download \
    "$SOURCE" \
    "$TARGET" \
    --server-id="$SERVER_ID" \
    $BUILD_FLAGS

echo "Download complete"

