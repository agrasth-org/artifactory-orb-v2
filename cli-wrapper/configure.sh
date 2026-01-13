#!/bin/bash
# Configure JFrog server connection
# Usage: ./configure.sh <server-id> <url>
#
# Arguments:
#   server-id - Unique identifier for this server config
#   url       - Artifactory URL
#
# Authentication via environment variables:
#   JFROG_ACCESS_TOKEN (preferred)
#   JFROG_USER + JFROG_PASSWORD

set -e

SERVER_ID="${1:-jfrog-server}"
URL="${2:?Artifactory URL is required}"

# Validate URL
if [ -z "$URL" ]; then
    echo "Error: Artifactory URL is required"
    echo "Usage: ./configure.sh <server-id> <url>"
    exit 1
fi

echo "Configuring JFrog CLI..."
echo "Server ID: $SERVER_ID"
echo "URL: $URL"

# Determine authentication method
if [ -n "$JFROG_ACCESS_TOKEN" ]; then
    echo "Using access token authentication"
    jf config add "$SERVER_ID" \
        --artifactory-url="$URL" \
        --access-token="$JFROG_ACCESS_TOKEN" \
        --interactive=false \
        --overwrite

elif [ -n "$JFROG_USER" ] && [ -n "$JFROG_PASSWORD" ]; then
    echo "Using username/password authentication"
    jf config add "$SERVER_ID" \
        --artifactory-url="$URL" \
        --user="$JFROG_USER" \
        --password="$JFROG_PASSWORD" \
        --interactive=false \
        --overwrite

else
    echo "Error: No authentication credentials found"
    echo "Set JFROG_ACCESS_TOKEN or (JFROG_USER + JFROG_PASSWORD)"
    exit 1
fi

# Verify connection
echo "Verifying connection..."
if jf rt ping --server-id="$SERVER_ID"; then
    echo "Connection verified successfully"
else
    echo "Warning: Could not verify connection to Artifactory"
fi

echo "Configuration complete"

