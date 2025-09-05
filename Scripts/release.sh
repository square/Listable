#!/bin/bash
set -e

# Release script for Listable
# This script automates the steps in RELEASING.md

# Function to display usage information
usage() {
  echo "Usage: $0 <new_version>"
  echo "Example: $0 16.0.4"
  exit 1
}

# Check if version argument is provided
if [ -z "$1" ]; then
  echo "Error: Version number is required"
  usage
fi

NEW_VERSION="$1"
USERNAME=$(whoami | tr -d ' ' | tr '[:upper:]' '[:lower:]')
BRANCH_NAME="${USERNAME}/release-${NEW_VERSION}"

echo "Starting release process for version ${NEW_VERSION}"

# Step 1: Make sure we're on main branch and pull latest
echo "Step 1: Checking branch and pulling latest changes..."
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "Error: You must be on the main branch to start a release."
  echo "Current branch: $CURRENT_BRANCH"
  exit 1
fi

git pull origin main

# Step 2: Create a branch for the release
echo "Step 2: Creating release branch ${BRANCH_NAME}..."
git checkout -b "$BRANCH_NAME"

# Step 3: Update localized strings
echo "Step 3: Updating localized strings..."
LATEST_COMMIT=$(git log -1 --pretty=%H)
./Scripts/install_localized_strings.sh "$LATEST_COMMIT"

# Step 4: Update the library version in version.rb
echo "Step 4: Updating version.rb to ${NEW_VERSION}..."
sed -i '' "s/LISTABLE_VERSION ||= '.*'/LISTABLE_VERSION ||= '${NEW_VERSION}'/" version.rb

# Step 5: Update CHANGELOG.md
echo "Step 5: Updating CHANGELOG.md..."
echo "Please update CHANGELOG.md manually with the following steps:"
echo "  1. Move changes from the 'Main' section to a new section for version ${NEW_VERSION}"
echo "  2. Add a section for the new release: # ${NEW_VERSION} - $(date +%Y-%m-%d)"
echo "  3. Reset the 'Main' section with empty categories"
echo "Press Enter when done..."
read -r

# Step 6: Re-generate documentation
echo "Step 6: Re-generating documentation..."
bundle exec Scripts/generate_docs.sh

# Step 7: Commit changes
echo "Step 7: Committing version changes..."
git add -A
git commit -m "Bumping versions to ${NEW_VERSION}."

# Step 8: Push branch and open PR
echo "Step 8: Pushing branch ${BRANCH_NAME}..."
git push origin "$BRANCH_NAME"
echo "Now open a PR from ${BRANCH_NAME} into main."
echo "Visit: https://github.com/square/Listable/compare/main...${BRANCH_NAME}"

echo ""
echo "After the PR is merged, run the following command to tag the release:"
echo "./Scripts/tag_release.sh ${NEW_VERSION} <merge commit SHA>"
echo ""

echo ""
echo "Release preparation completed successfully!"