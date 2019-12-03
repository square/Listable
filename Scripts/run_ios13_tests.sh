#!/bin/sh

set -e
set -o pipefail

# Deleting Old Simulators

SIMULATOR_NAME="Listable CI iPhone X (iOS 13)"

xcrun simctl delete "$SIMULATOR_NAME" || true

# Create New Simulators

DEVICE_UUID=$(xcrun simctl create "$SIMULATOR_NAME" "iPhone X" "com.apple.CoreSimulator.SimRuntime.iOS-13-2")
echo "Created iOS 13 simulator ($SIMULATOR_NAME): $DEVICE_UUID"

xcrun simctl boot "$DEVICE_UUID"


# Run Build

xcodebuild build-for-testing -workspace "Demo/Demo.xcworkspace" -scheme "Demo" -destination "id=$DEVICE_UUID" -quiet
xcodebuild test-without-building -workspace "Demo/Demo.xcworkspace" -scheme "Demo" -destination "id=$DEVICE_UUID"