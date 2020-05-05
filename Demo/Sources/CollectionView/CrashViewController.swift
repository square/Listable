//
//  DemoTableViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 3/24/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//
import Listable
import BlueprintLists
import BlueprintUI
import BlueprintUICommonControls
import UIKit

final class CrashViewController: UIViewController  {
    private let blueprintView = BlueprintView()

    private var items = [
        Item(isSaved: true, identifier: 0),
        Item(isSaved: true, identifier: 1),
        Item(isSaved: true, identifier: 2),
    ]

    override func loadView() {
        self.title = "Swipe Actions"

        self.view = self.blueprintView
        self.reloadData()
    }

    func reloadData(animated: Bool = false) {
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.blueprintView.element = List { list in
                list += Section(identifier: "items") { section in
                    section += self.items.map { item in
                        DemoItem(item: item)
                    }
                }
            }
        }
    }

    struct DemoItem: BlueprintItemElement, Equatable {
        var item: Item

        var identifier: Identifier<DemoItem> {
            return .init(item.identifier)
        }

        func element(with info : ApplyItemElementInfo) -> Element {
            return Column { column in

                column.horizontalAlignment = .fill

                let row = Row { row in

                    row.minimumHorizontalSpacing = 8
                    row.horizontalUnderflow = .spaceEvenly
                    row.verticalAlignment = .center
                    row.add(child: Label(text: self.item.title))

                    let bookmark = UIImage(named: "are-we-there-yet")!

                    if item.isSaved {
                        let image = Image(image: bookmark)
                        row.add(child: image)
                    }
                }

                let inset = Inset(uniformInset: 16, wrapping: row)
                column.add(child: inset)

                let separator = Inset(left: 16, wrapping: Rule(orientation: .horizontal, color: .lightGray))
                column.add(growPriority: 0, shrinkPriority: 0, child: separator)
            }
        }
    }

    struct Item: Equatable, Hashable {
        var isSaved: Bool
        var identifier: Int
        var title: String { "Item #\(identifier)" }
    }
}
