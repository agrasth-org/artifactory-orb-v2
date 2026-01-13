#!/bin/bash
# Docker operations with Artifactory
# Usage: ./docker.sh <action> [options]
#
# Actions:
#   login   - Login to Docker registry
#   push    - Push image to Artifactory
#   pull    - Pull image from Artifactory
#   promote - Promote image between repositories
#
# Environment:
#   JFROG_USER / JFROG_PASSWORD or JFROG_ACCESS_TOKEN for auth

set -e

ACTION="${1:?Action required: login|push|pull|promote}"
shift

case "$ACTION" in
    login)
        # Usage: ./docker.sh login <registry>
        REGISTRY="${1:?Registry URL required}"
        
        echo "Logging into Docker registry: $REGISTRY"
        
        if [ -n "$JFROG_ACCESS_TOKEN" ]; then
            echo "$JFROG_ACCESS_TOKEN" | docker login -u "${JFROG_USER:-admin}" --password-stdin "$REGISTRY"
        elif [ -n "$JFROG_USER" ] && [ -n "$JFROG_PASSWORD" ]; then
            echo "$JFROG_PASSWORD" | docker login -u "$JFROG_USER" --password-stdin "$REGISTRY"
        else
            echo "Error: No credentials found"
            exit 1
        fi
        
        echo "Docker login successful"
        ;;
        
    push)
        # Usage: ./docker.sh push <image-tag> <repository> [build-name] [build-number] [server-id]
        IMAGE_TAG="${1:?Image tag required}"
        REPOSITORY="${2:?Repository required}"
        BUILD_NAME="${3:-${CI_PROJECT_NAME:-docker-build}}"
        BUILD_NUMBER="${4:-${CI_BUILD_NUMBER:-1}}"
        SERVER_ID="${5:-jfrog-server}"
        
        echo "Pushing Docker image..."
        echo "Image: $IMAGE_TAG"
        echo "Repository: $REPOSITORY"
        
        jf rt docker-push "$IMAGE_TAG" "$REPOSITORY" \
            --build-name="$BUILD_NAME" \
            --build-number="$BUILD_NUMBER" \
            --server-id="$SERVER_ID"
        
        echo "Docker push complete"
        ;;
        
    pull)
        # Usage: ./docker.sh pull <image-tag> <repository> [server-id]
        IMAGE_TAG="${1:?Image tag required}"
        REPOSITORY="${2:?Repository required}"
        SERVER_ID="${3:-jfrog-server}"
        
        echo "Pulling Docker image..."
        
        jf rt docker-pull "$IMAGE_TAG" "$REPOSITORY" \
            --server-id="$SERVER_ID"
        
        echo "Docker pull complete"
        ;;
        
    promote)
        # Usage: ./docker.sh promote <image> <source-repo> <target-repo> [tag] [server-id]
        IMAGE="${1:?Image name required}"
        SOURCE_REPO="${2:?Source repository required}"
        TARGET_REPO="${3:?Target repository required}"
        TAG="${4:-latest}"
        SERVER_ID="${5:-jfrog-server}"
        
        echo "Promoting Docker image..."
        echo "Image: $IMAGE:$TAG"
        echo "From: $SOURCE_REPO"
        echo "To: $TARGET_REPO"
        
        jf rt docker-promote "$IMAGE" "$SOURCE_REPO" "$TARGET_REPO" \
            --source-tag="$TAG" \
            --server-id="$SERVER_ID"
        
        echo "Docker promote complete"
        ;;
        
    *)
        echo "Unknown action: $ACTION"
        echo "Valid actions: login, push, pull, promote"
        exit 1
        ;;
esac

