import ProjectDescription

let workspace = Workspace(
    name: "Demo",
    projects: ["."],
    schemes: [
        .scheme(
            name: "ListableUI",
            buildAction: .buildAction(targets: [.project(path: "..", target: "ListableUI")])
        ),
        .scheme(
            name: "BlueprintUILists",
            buildAction: .buildAction(targets: [.project(path: "..", target: "BlueprintUILists")])
        ),
    ]
)
