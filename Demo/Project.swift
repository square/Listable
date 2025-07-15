import Foundation
import ProjectDescription

let project = Project(
    name: "Demo",
    settings: .settings(base: ["ENABLE_MODULE_VERIFIER": "YES"]),
    targets: [
         .app(
            name: "Listable_TestHost",
            productName: "Listable_TestHost",
            bundleId: "com.listable.ListableTestHost",
            sources: ["../ListableUI/Tests/UITestHost/**"]
        ),
        .target(
            name: "ListableDevelopment",
            destinations: .iOS,
            product: .app,
            bundleId: "com.listable.development",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .file(path: "Demo/Info.plist"),
            sources: ["Sources/**"],
            resources: [
                "Resources/**",
                "Demo/Assets.xcassets",
                "Demo/Base.lproj/**"
            ],
            dependencies: [
                .external(name: "ListableUI"),
                .external(name: "BlueprintUILists"),
                .external(name: "BlueprintUI"),
                .external(name: "BlueprintUICommonControls"),
                .target(name: "EnglishDictionary")
            ]
        ),
         .target(
            name: "ListableTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.listable.ListableTests",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .default,
            sources: [
                .glob("../ListableUI/Tests/**/*.swift", excluding: ["../ListableUI/Tests/**/Snapshot Results/**"])
            ],
            resources: ["../ListableUI/Tests/Resources/**"],
            dependencies: [
                .external(name: "ListableUI"),
                .target(name: "EnglishDictionary"),
                .target(name: "Snapshot"),
                .target(name: "Listable_TestHost")
            ]
        ),
        .target(
            name: "BlueprintUIListsTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.listable.BlueprintUIListsTests",
            deploymentTargets: .iOS("15.0"),
            sources: ["../BlueprintUILists/Tests/**/*.swift"],
            resources: [],
            dependencies: [
                .external(name: "BlueprintUILists"),
                .external(name: "BlueprintUICommonControls"),
            ]
        ),
        .target(
            name: "Snapshot",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.listable.snapshot",
            deploymentTargets: .iOS("15.0"),
            sources: ["../Internal/Snapshot/Sources/**"],
            resources: [],
            dependencies: [.xctest]
        ),
        .target(
            name: "Snapshot-Unit-Tests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.listable.SnapshotUnitTests",
            deploymentTargets: .iOS("15.0"),
            sources: [
                .glob("../Internal/Snapshot/Tests/**/*.swift", excluding: ["../Internal/Snapshot/Tests/**/Snapshot Results/**"])
            ],
            resources: [],
            dependencies: [
                .target(name: "Snapshot"),
                .xctest
            ]
        ),
        .target(
            name: "EnglishDictionary",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.listable.englishdictionary",
            deploymentTargets: .iOS("15.0"),
            sources: ["../Internal/EnglishDictionary/Sources/**"],
            resources: ["../Internal/EnglishDictionary/Resources/**"]
        ),
    ]
)

extension Target {

    public static func app(
        name: String,
        destinations: ProjectDescription.Destinations = .iOS,
        productName: String,
        bundleId: String,
        deploymentTargets: DeploymentTargets = .iOS("15.0"),
        sources: ProjectDescription.SourceFilesList,
        resources: ProjectDescription.ResourceFileElements? = nil,
        dependencies: [TargetDependency] = []
    ) -> Self {
        .target(
            name: name,
            destinations: destinations,
            product: .app,
            productName: productName,
            bundleId: bundleId,
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": ["UIColorName": ""],
                ]
            ),
            sources: sources,
            resources: resources,
            dependencies: dependencies
        )
    }
}