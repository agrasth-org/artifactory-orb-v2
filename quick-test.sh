#!/bin/bash
# Quick test script for artifactory-orb-v2

set -e

echo "=================================="
echo "CircleCI Orb Testing Quick Start"
echo "=================================="
echo ""

# Check if CircleCI CLI is installed
if ! command -v circleci &> /dev/null; then
    echo "❌ CircleCI CLI not found!"
    echo ""
    echo "Install it with:"
    echo "  macOS: brew install circleci"
    echo "  Linux: curl -fLSs https://raw.githubusercontent.com/CircleCI-Public/circleci-cli/master/install.sh | bash"
    echo ""
    exit 1
fi

echo "✓ CircleCI CLI found: $(circleci version)"
echo ""

# Step 1: Validate the orb structure
echo "Step 1: Validating orb syntax..."
if circleci orb validate src/@orb.yml; then
    echo "✓ Orb syntax is valid"
else
    echo "❌ Orb validation failed"
    exit 1
fi
echo ""

# Step 2: Pack the orb
echo "Step 2: Packing orb..."
if circleci orb pack src > orb.yml; then
    echo "✓ Orb packed successfully -> orb.yml"
else
    echo "❌ Failed to pack orb"
    exit 1
fi
echo ""

# Step 3: Validate packed orb
echo "Step 3: Validating packed orb..."
if circleci orb validate orb.yml; then
    echo "✓ Packed orb is valid"
else
    echo "❌ Packed orb validation failed"
    exit 1
fi
echo ""

echo "=================================="
echo "✓ All validations passed!"
echo "=================================="
echo ""
echo "Next steps:"
echo ""
echo "Option A - Publish as dev version (requires CircleCI auth):"
echo "  1. Setup auth: circleci setup"
echo "  2. Create namespace (if needed): circleci namespace create <name> github <org>"
echo "  3. Create orb: circleci orb create <namespace>/artifactory-orb-v2"
echo "  4. Publish: circleci orb publish orb.yml <namespace>/artifactory-orb-v2@dev:test"
echo ""
echo "Option B - Test CLI scripts locally:"
echo "  1. ./cli-wrapper/install.sh"
echo "  2. Export env vars: JFROG_URL, JFROG_USER, JFROG_API_KEY"
echo "  3. ./cli-wrapper/configure.sh test-server"
echo "  4. ./cli-wrapper/upload.sh 'test.txt' 'test-repo/'"
echo ""
echo "Option C - Use in CircleCI project:"
echo "  1. Publish as dev version (see Option A)"
echo "  2. Create a CircleCI project"
echo "  3. Copy test-config.yml to .circleci/config.yml"
echo "  4. Update the orb reference with your namespace"
echo "  5. Set ARTIFACTORY_URL, ARTIFACTORY_USER, ARTIFACTORY_API_KEY in project settings"
echo "  6. Trigger a build"
echo ""

