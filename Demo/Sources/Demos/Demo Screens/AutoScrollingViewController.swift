//
//  BottomPinnedViewController.swift
//  Demo
//
//  Created by Kyle Bashour on 3/5/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import UIKit

import BlueprintUI
import BlueprintUICommonControls
import BlueprintUILists
import ListableUI

final class AutoScrollingViewController: UIViewController {
    let list = ListView()

    private var items: [Item<BottomPinnedItem>] = []

    override func loadView() {
        view = list
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for _ in 0 ..< 7 {
            addItem()
        }

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem)),
            UIBarButtonItem(title: "Remove", style: .plain, target: self, action: #selector(removeItem)),
        ]
    }

    @objc private func addItem() {
        let last = items.last

        items.append(Item(BottomPinnedItem(text: "Item \(items.count)")))

        updateItems(autoScrollIfVisible: last?.identifier)
    }

    @objc private func removeItem() {
        if !items.isEmpty {
            items.removeLast()
            updateItems()
        }
    }

    private func updateItems(autoScrollIfVisible lastItem: AnyIdentifier? = nil) {
        list.configure { list in
            list.appearance = .demoAppearance
            list.layout = .demoLayout

            list += Section("items", items: self.items)

            if let last = self.items.last {
                list.autoScrollAction = .scrollTo(
                    .lastItem,
                    onInsertOf: last.identifier,
                    position: .init(position: .bottom),
                    animation: .default,
                    shouldPerform: { info in
                        // Only scroll to the bottom if the bottom item is already visible.
                        if let identifier = lastItem {
                            return info.visibleItems.contains(identifier)
                        } else {
                            return false
                        }
                    },
                    didPerform: { info in
                        print("Did scroll: \(info)")
                    }
                )
            }

            list += Section("itemization") {
                BottomPinnedItem(text: "Tax $2.00")
                BottomPinnedItem(text: "Discount $4.00")
                BottomPinnedItem(text: "Total $10.00")
            }
        }
    }
}

struct BottomPinnedItem: BlueprintItemContent, Equatable {
    var text: String

    var identifierValue: String {
        text
    }

    func element(with _: ApplyItemContentInfo) -> Element {
        var box = Box(
            backgroundColor: .white,
            cornerStyle: .rounded(radius: 6.0),
            wrapping: Inset(
                uniformInset: 10.0,
                wrapping: Label(text: text)
            )
        )

        box.borderStyle = .solid(color: .white(0.9), width: 2.0)
        return box
    }
}
