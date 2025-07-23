// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Snapshot",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15),
    ],
    products: [
        .library(
            name: "Snapshot",
            targets: ["Snapshot"]
        ),
    ],
    targets: [
        .target(
            name: "Snapshot",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "SnapshotTests",
            dependencies: ["Snapshot"],
            path: "Tests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
