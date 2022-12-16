// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Listable",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "ListableUI",
            targets: ["ListableUI"]
        ),
        .library(
            name: "BlueprintUILists",
            targets: ["BlueprintUILists"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/square/Blueprint", from: "0.48.0"),
    ],
    targets: [
        .target(
            name: "ListableUI",
            path: "ListableUI",
            exclude: [
                "Sources/Internal/KeyboardObserver/SetupKeyboardObserverOnAppStartup.m",
                "Sources/Layout/Paged/PagedAppearance.monopic",
                "Sources/ContentBounds/ListContentBounds.monopic",
                "Sources/Layout/Table/TableAppearance.monopic",
                "Tests",
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "EnglishDictionary",
            path: "Internal Pods/EnglishDictionary",
            exclude: ["EnglishDictionary.podspec"],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "Snapshot",
            path: "Internal Pods/Snapshot/Sources"
        ),
        .testTarget(
            name: "SnapshotTests",
            dependencies: ["Snapshot"],
            path: "Internal Pods/Snapshot/Tests",
            exclude: ["Snapshot Results"]
        ),
        .testTarget(
            name: "ListableUITests",
            dependencies: ["ListableUI", "EnglishDictionary", "Snapshot"],
            path: "ListableUI/Tests",
            exclude: [
                "Layout/Flow/Snapshot Results",
                "Layout/Paged/Snapshot Results",
                "Layout/Table/Snapshot Results",
                "Previews/Snapshot Results",
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "BlueprintUILists",
            dependencies: [
                "ListableUI",
                .product(name: "BlueprintUI", package: "Blueprint")
            ],
            path: "BlueprintUILists",
            exclude: [
                "Tests",
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "BlueprintUIListsTests",
            dependencies: ["BlueprintUILists"],
            path: "BlueprintUILists/Tests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
