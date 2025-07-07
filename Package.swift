// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Listable",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15),
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
        .package(url: "https://github.com/square/Blueprint", from: "6.0.0"),
    ],
    targets: [
        .target(
            name: "ListableUI",
            path: "ListableUI",
            exclude: [
                "Sources/KeyboardObserver/SetupKeyboardObserverOnAppStartup.m",
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
            path: "Internal/EnglishDictionary",
            exclude: ["EnglishDictionary.podspec"],
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "Snapshot",
            path: "Internal/Snapshot/Sources"
        ),
        .testTarget(
            name: "SnapshotTests",
            dependencies: ["Snapshot"],
            path: "Internal/Snapshot/Tests",
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
            dependencies: [
                "BlueprintUILists",
                .product(name: "BlueprintUICommonControls", package: "Blueprint")
            ],
            path: "BlueprintUILists/Tests"
        ),
        .target(
            name: "Demo",
            dependencies: [
                "ListableUI",
                "EnglishDictionary",
                "BlueprintUILists",
                .product(name: "BlueprintUI", package: "Blueprint"),
                .product(name: "BlueprintUICommonControls", package: "Blueprint")
            ],
            path: "Demo/Sources",
            resources: [
                .process("../Resources"),
            ]
        ),
        .testTarget(
            name: "DemoTests",
            dependencies: ["Demo"],
            path: "Demo/Test Targets"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
