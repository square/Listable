
#!/bin/bash

set -euxo pipefail

# Find the sourcekitten binary embedded in jazzy
sourcekitten=`gem contents jazzy | grep 'bin/sourcekitten$' | head -1`

platform="iOS Simulator"
device=`instruments -s -devices | grep -oE 'iPhone.*?[^\(]+' | head -1 | awk '{$1=$1;print}'`
destination="platform=$platform,name=$device"

$sourcekitten doc \
  --module-name Listable \
  -- \
  -scheme "Demo" -destination "$destination" \
  > Listable.json

$sourcekitten doc \
  --module-name BlueprintLists \
  -- \
  -scheme "Demo" -destination "$destination" \
  > BlueprintLists.json

jazzy --sourcekitten-sourcefile Listable.json,BlueprintLists.json
