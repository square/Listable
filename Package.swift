// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Listable",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12),
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
        .package(url: "https://github.com/square/Blueprint", from: "0.19.0"),
    ],
    targets: [
        .target(
            name: "ListableUI",
            path: "ListableUI/Sources",
            exclude: [
                "Internal/KeyboardObserver/SetupKeyboardObserverOnAppStartup.m",
                "Layout/Paged/PagedAppearance.monopic",
                "ContentBounds/ListContentBounds.monopic",
                "Layout/Table/TableAppearance.monopic",
            ]
        ),
        .target(
            name: "BlueprintUILists",
            dependencies: [
                "ListableUI",
                .product(name: "BlueprintUI", package: "Blueprint")
            ],
            path: "BlueprintUILists/Sources"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
