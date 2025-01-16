//
//  AutoScrollingViewController2.swift
//  Demo
//
//  Created by Gil Birman on 5/31/22.
//  Copyright © 2022 Kyle Van Essen. All rights reserved.//

import UIKit

import ListableUI
import BlueprintUILists
import BlueprintUI
import BlueprintUICommonControls


final class AutoScrollingViewController2 : UIViewController
{
    let list = ListView()

    private var items: [Item<BottomPinnedItem>] = []

    override func loadView()
    {
        self.view = self.list
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        for _ in 0..<7 {
            addItem()
        }

        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem)),
            UIBarButtonItem(title: "Remove", style: .plain, target: self, action: #selector(removeItem)),
        ]
    }

    @objc private func addItem()
    {
        let last = items.last
        
        items.append(Item(BottomPinnedItem(text: "Item \(items.count)")))
        
        updateItems(autoScrollIfVisible: last?.identifier)
    }

    @objc private func removeItem()
    {
        if !items.isEmpty {
            items.removeLast()
            updateItems()
        }
    }

    private func updateItems(autoScrollIfVisible lastItem : AnyIdentifier? = nil) {
        
        self.list.configure { list in
            list.appearance = .demoAppearance
            list.layout = .demoLayout

            list += Section("items", items: self.items)

            list.autoScrollAction = .pin(
                .lastItem,
                position: .init(position: .bottom),
                animated: true,
                shouldPerform: { info in
                    // Only auto-scroll if we're currently scrolled less than a
                    // screen's-height from the bottom
                    return info.bottomScrollOffset < info.bounds.height - info.safeAreaInsets.top
                },
                didPerform: { info in
                    print("Did scroll: \(info)")
                }
            )

            list += Section("itemization") {
                BottomPinnedItem(text: "Tax $2.00")
                BottomPinnedItem(text: "Discount $4.00")
                BottomPinnedItem(text: "Total $10.00")
            }
        }
    }
}
