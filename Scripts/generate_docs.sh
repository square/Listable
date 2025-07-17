
#!/bin/bash

set -euxo pipefail

# Find the sourcekitten binary embedded in jazzy
sourcekitten=`gem contents jazzy | grep 'bin/sourcekitten$' | head -1`

destination="generic/platform=iOS Simulator"

tuist install --path Development/
tuist generate --no-open --path Development/

$sourcekitten doc -- -workspace Development/ListableDevelopment.xcworkspace -scheme ListableUI -destination "$destination" > docs/JSON/ListableUI.json
$sourcekitten doc -- -workspace Development/ListableDevelopment.xcworkspace -scheme BlueprintUILists -destination "$destination" > docs/JSON/BlueprintUILists.json

jazzy \
	--clean \
	--config docs/ListableUI.yml \
	--sourcekitten-sourcefile docs/JSON/ListableUI.json \
	--output docs/Listable \
	--copyright "&copy; Square, Inc. All rights reserved."

jazzy \
	--clean \
	--config docs/BlueprintUILists.yml \
	--sourcekitten-sourcefile docs/JSON/BlueprintUILists.json \
	--output docs/BlueprintLists \
	--copyright "&copy; Square, Inc. All rights reserved."
