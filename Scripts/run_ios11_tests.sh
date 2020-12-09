#!/bin/sh

set -e
set -o pipefail

# Deleting Old Simulators

SIMULATOR_NAME="Listable CI iPhone 7 (iOS 11)"

xcrun simctl delete "$SIMULATOR_NAME" || true

# Create New Simulators

# DEVICE_UUID=$(xcrun simctl create "$SIMULATOR_NAME" "iPhone 7" "com.apple.CoreSimulator.SimRuntime.iOS-11-1")
# echo "Created iOS 11 simulator ($SIMULATOR_NAME): $DEVICE_UUID"

# xcrun simctl boot "$DEVICE_UUID"


# # Run Build

# xcodebuild build-for-testing -workspace "Demo/Demo.xcworkspace" -scheme "Demo" -destination "id=$DEVICE_UUID" -quiet
# xcodebuild test-without-building -workspace "Demo/Demo.xcworkspace" -scheme "Demo" -destination "id=$DEVICE_UUID"
