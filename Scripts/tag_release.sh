#!/bin/bash
set -e

# Tag release script for Listable
# This script completes the release process after the PR has been merged

# Function to display usage information
usage() {
  echo "Usage: $0 <version> <merge_commit_sha>"
  echo "Example: $0 16.0.4 abc1234"
  exit 1
}

# Check if required arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Error: Version number and merge commit SHA are required"
  usage
fi

VERSION="$1"
MERGE_COMMIT="$2"

echo "Tagging release version ${VERSION} at commit ${MERGE_COMMIT}"

# Fetch latest changes
echo "Fetching latest changes..."
git fetch

# Create and push the tag
echo "Creating tag ${VERSION}..."
git tag "$VERSION" "$MERGE_COMMIT"
git push origin "$VERSION"

echo "Release ${VERSION} has been tagged and pushed successfully!"