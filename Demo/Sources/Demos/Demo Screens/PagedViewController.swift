//
//  PagedViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 6/4/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import BlueprintUICommonControls
import BlueprintUILists

final class PagedViewController: UIViewController {
    let blueprintView = BlueprintView()

    override func loadView() {
        view = blueprintView

        update()
    }

    func update() {
        blueprintView.element = List { list in

            list.layout = .paged {
                $0.direction = .vertical
            }
        } sections: {
            Section("first") {
                DemoElement(color: .black)
                DemoElement(color: .white)
                DemoElement(color: .black)
                DemoElement(color: .white)
                DemoElement(color: .black)
            }
        }
    }
}

private struct DemoElement: BlueprintItemContent, Equatable {
    var identifierValue: UIColor {
        color
    }

    var color: UIColor

    func element(with _: ApplyItemContentInfo) -> Element {
        Box(backgroundColor: color)
    }
}
