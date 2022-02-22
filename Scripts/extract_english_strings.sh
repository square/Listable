#!/usr/bin/env bash

# Generate a Localizable.strings file from the LocalizedStrings.swift file in MarketUI
# Usage: extract_english_strings

set -euo pipefail

# We want this to be runnable from Xcode or the root of the repo,
# so we cd to the script dir is and use paths relative to that.
cd "$(dirname "${BASH_SOURCE[0]}")"

genstrings -o ../BlueprintUILists/Resources/en.lproj \
../BlueprintUILists/Sources/LocalizedStrings.swift \

# genstrings encodes its file in UTF-16, but UTF-8 is also supported and will show in diffs,
# so we'll convert the file to UTF-8
iconv -f UTF-16 -t UTF-8 ../BlueprintUILists/Resources/en.lproj/Localizable.strings > temp && mv temp ../BlueprintUILists/Resources/en.lproj/Localizable.strings
