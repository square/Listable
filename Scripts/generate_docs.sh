
#!/bin/bash

set -euxo pipefail

# Find the sourcekitten binary embedded in jazzy
sourcekitten=`gem contents jazzy | grep 'bin/sourcekitten$' | head -1`

destination="platform=iOS Simulator,name=iPhone 11"

$sourcekitten doc -- -workspace Demo/Demo.xcworkspace -scheme Listable -destination "$destination" > docs/json/Listable.json
$sourcekitten doc -- -workspace Demo/Demo.xcworkspace -scheme BlueprintLists -destination "$destination" > docs/json/BlueprintLists.json

jazzy \
	--clean \
	--config docs/listable.yml \
	--sourcekitten-sourcefile docs/json/Listable.json \
	--output docs/Listable

jazzy \
	--clean \
	--config docs/blueprintlists.yml \
	--sourcekitten-sourcefile docs/json/BlueprintLists.json \
	--output docs/BlueprintLists
