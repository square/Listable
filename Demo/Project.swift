import Foundation
import ProjectDescription

let project = Project(
    name: "Demo",
    settings: .settings(base: ["ENABLE_MODULE_VERIFIER": "YES"]),
    targets: [
        .target(
            name: "Demo",
            destinations: .iOS,
            product: .app,
            bundleId: "com.listable.demo",
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
            name: "DemoTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.listable.demo.tests",
            deploymentTargets: .iOS("15.0"),
            sources: ["Test Targets/**"],
            dependencies: [
                .target(name: "Demo")
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
