// swift-tools-version: 5.9

import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "BlueprintUI": .framework,
        "BlueprintUICommonControls": .framework,
        "BlueprintUILists": .framework,
        "ListableUI": .framework,
    ],
    targetSettings: [
        "BlueprintUILists": unsuppressedWarningsSettings,
        "ListableUI": unsuppressedWarningsSettings,
    ]
)

var unsuppressedWarningsSettings: SettingsDictionary {
    [
        "GCC_WARN_INHIBIT_ALL_WARNINGS": "NO",
        "SWIFT_SUPPRESS_WARNINGS": "NO",
    ]
}

#endif

let package = Package(
    name: "Development",
    dependencies: [
        .package(path: "../../"),
    ]
)