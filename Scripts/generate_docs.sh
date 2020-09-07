
#!/bin/bash

set -euxo pipefail

# Find the sourcekitten binary embedded in jazzy
sourcekitten=`gem contents jazzy | grep 'bin/sourcekitten$' | head -1`

platform="iOS Simulator"
device=`instruments -s -devices | grep -oE 'iPhone.*?[^\(]+' | head -1 | awk '{$1=$1;print}'`
destination="platform=$platform,name=$device"

$sourcekitten doc -- -workspace Demo/Demo.xcworkspace -scheme Listable -destination "$destination" > Listable.json

$sourcekitten doc -- -workspace Demo/Demo.xcworkspace -scheme BlueprintLists -destination "$destination" > BlueprintLists.json

jazzy --sourcekitten-sourcefile Listable.json --output docs/listable
jazzy --sourcekitten-sourcefile BlueprintLists.json --output docs/blueprintlists
