// swift-tools-version: 5.9

import PackageDescription

#if TUIST
import ProjectDescription

let unsuppressedWarningsSettings: SettingsDictionary = {
    [
        "GCC_WARN_INHIBIT_ALL_WARNINGS": "NO",
        "SWIFT_SUPPRESS_WARNINGS": "NO",
    ]
}()

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

#endif

let package = Package(
    name: "Development",
    dependencies: [
        .package(path: "../../"),
    ]
)