import Foundation
import ProjectDescription

public let listableDestinations: ProjectDescription.Destinations = .iOS
public let listableDeploymentTargets: DeploymentTargets = .iOS("15.0")

let project = Project(
    name: "ListableDevelopment",
    settings: .settings(base: [
        "ENABLE_MODULE_VERIFIER": "YES",
        "DEVELOPMENT_TEAM": SettingValue(stringLiteral: Environment.developmentTeam.getString(default: "")),
    ]),
    targets: [
         .app(
            name: "Listable_TestHost",
            productName: "Listable_TestHost",
            bundleId: "com.listable.ListableTestHost",
            sources: ["../ListableUI/Tests/UITestHost/**"]
        ),
        .target(
            name: "Listable",
            destinations: listableDestinations,
            product: .app,
            bundleId: "com.squareup.listable",
            deploymentTargets: listableDeploymentTargets,
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
            destinations: listableDestinations,
            product: .unitTests,
            bundleId: "com.squareup.listable.tests",
            deploymentTargets: listableDeploymentTargets,
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
            destinations: listableDestinations,
            product: .unitTests,
            bundleId: "com.squareup.listable.BlueprintUILists.tests",
            deploymentTargets: listableDeploymentTargets,
            sources: ["../BlueprintUILists/Tests/**/*.swift"],
            resources: [],
            dependencies: [
                .external(name: "BlueprintUILists"),
                .external(name: "BlueprintUICommonControls"),
            ]
        ),
        .target(
            name: "Snapshot",
            destinations: listableDestinations,
            product: .framework,
            bundleId: "com.squareup.listable.snapshot",
            deploymentTargets: listableDeploymentTargets,
            sources: ["../Internal/Snapshot/Sources/**"],
            resources: [],
            dependencies: [.xctest]
        ),
        .target(
            name: "Snapshot-Unit-Tests",
            destinations: listableDestinations,
            product: .unitTests,
            bundleId: "com.squareup.listable.snapshot.tests",
            deploymentTargets: listableDeploymentTargets,
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
            destinations: listableDestinations,
            product: .framework,
            bundleId: "com.listable.englishdictionary",
            deploymentTargets: listableDeploymentTargets,
            sources: ["../Internal/EnglishDictionary/Sources/**"],
            resources: ["../Internal/EnglishDictionary/Resources/**"]
        ),
    ]
)

extension Target {

    public static func app(
        name: String,
        destinations: ProjectDescription.Destinations = listableDestinations,
        productName: String,
        bundleId: String,
        deploymentTargets: DeploymentTargets = listableDeploymentTargets,
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