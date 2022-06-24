#!/usr/bin/env bash

# Usage: install-localized-strings [--allowpartials] [SHA]
#
#   --allowpartials - (Optional) Allow incomplete translations and download all available languages.
#   SHA = (Optional) The SHA to download strings for. Uses HEAD if none is specified.

set -euo pipefail

SHA=$1
PROJECT_NAME="listable"

if [ ! -e "${PWD}/ListableUI" ]; then
  echo "ERROR: This script must be run from the root of the Listable repo!"
  exit 1
fi

URL_ARGUMENTS="?encoding=utf-8"
if [ "$1" == "--allowpartials" ]; then
  URL_ARGUMENTS="${URL_ARGUMENTS}&partial=true"
  SHA=$2
fi

if [ "$SHA" == "" ]; then
  SHA=`git rev-parse HEAD`
  echo "SHA not specified, using current HEAD: $SHA"
fi

STRINGS_PATH=./localized_strings_$SHA.tgz

echo -e "Downloading translations for project '${PROJECT_NAME}' at commit '${SHA}'\n"

# Attempt to download Strings manifest tar. Exit on non-200
URL_STRINGS=https://shuttle.squareup.com/projects/${PROJECT_NAME}/commits/${SHA}/manifest.ios$URL_ARGUMENTS
STATUSCODE_STRINGS=$(curl --output $STRINGS_PATH --write-out "%{http_code}" $URL_STRINGS)
if [[ $STATUSCODE_STRINGS -ne 200 ]]; then
  echo -e "\nDownloading Strings manifest failed!\n"
  echo "  - URL: $URL_STRINGS"
  echo "  - Status code: $STATUSCODE_STRINGS"
  echo -e "\nCheck translation is completed: https://shuttle.squareup.com/projects/${PROJECT_NAME}/commits/${SHA}"

  # Leaving git in a clean state on error
  rm $STRINGS_PATH
  exit 1
fi

# Expand the downloaded strings
tar xvzf $STRINGS_PATH

# Remove the tar file
rm $STRINGS_PATH
