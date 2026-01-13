#!/bin/bash
# Install JFrog CLI v2
# Usage: ./install.sh [version]
#
# Arguments:
#   version - CLI version to install (default: "2" for latest v2)

set -e

VERSION="${1:-2}"

# Check if already installed
if command -v jf &> /dev/null; then
    echo "JFrog CLI already installed: $(jf --version)"
    exit 0
fi

echo "Installing JFrog CLI v${VERSION}..."

# Download and install
curl -fL https://install-cli.jfrog.io | sh -s "${VERSION}"

# Make executable and move to PATH
chmod +x jf
sudo mv jf /usr/local/bin/jf

# Verify installation
jf --version
echo "JFrog CLI installed successfully"

