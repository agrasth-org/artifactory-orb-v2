#!/bin/bash
# Upload artifacts to Artifactory
# Usage: ./upload.sh <source> <target> [build-name] [build-number] [server-id]
#
# Arguments:
#   source       - Source path/pattern (e.g., "target/*.jar")
#   target       - Target repository path (e.g., "libs-release-local/")
#   build-name   - Build name for build info (default: $CI_PROJECT_NAME)
#   build-number - Build number for build info (default: $CI_BUILD_NUMBER)
#   server-id    - Server ID from configure (default: "jfrog-server")

set -e

SOURCE="${1:?Source path is required}"
TARGET="${2:?Target path is required}"
BUILD_NAME="${3:-${CI_PROJECT_NAME:-default-build}}"
BUILD_NUMBER="${4:-${CI_BUILD_NUMBER:-1}}"
SERVER_ID="${5:-jfrog-server}"

echo "Uploading artifacts..."
echo "Source: $SOURCE"
echo "Target: $TARGET"
echo "Build: $BUILD_NAME/$BUILD_NUMBER"
echo "Server: $SERVER_ID"

jf rt upload \
    "$SOURCE" \
    "$TARGET" \
    --build-name="$BUILD_NAME" \
    --build-number="$BUILD_NUMBER" \
    --server-id="$SERVER_ID"

echo "Upload complete"

