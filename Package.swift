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
        .package(url: "https://github.com/square/swift-keyboard-observer", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "ListableUI",
            dependencies: [
                .product(name: "KeyboardObserver", package: "swift-keyboard-observer"),
            ],
            path: "ListableUI",
            exclude: [
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
    ],
    swiftLanguageVersions: [.v5]
)
