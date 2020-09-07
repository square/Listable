
#!/bin/bash

set -euxo pipefail

# Find the sourcekitten binary embedded in jazzy
sourcekitten=`gem contents jazzy | grep 'bin/sourcekitten$' | head -1`

destination="platform=iOS Simulator,name=iPhone 11"

$sourcekitten doc -- -workspace Demo/Demo.xcworkspace -scheme Listable -destination "$destination" > Listable.json

$sourcekitten doc -- -workspace Demo/Demo.xcworkspace -scheme BlueprintLists -destination "$destination" > BlueprintLists.json

jazzy --sourcekitten-sourcefile Listable.json --output docs/Listable --module "Listable"
jazzy --sourcekitten-sourcefile BlueprintLists.json --output docs/BlueprintLists --module "BlueprintLists"
