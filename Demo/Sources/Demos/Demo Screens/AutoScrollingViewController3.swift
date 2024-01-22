//
//  AutoScrollingViewController3.swift
//  Demo
//
//  Created by Gil Birman on 1/22/24.
//  Copyright © 2024 Kyle Van Essen. All rights reserved.
//

import UIKit

import ListableUI
import BlueprintUILists
import BlueprintUI
import BlueprintUICommonControls


final class AutoScrollingViewController3 : UIViewController
{
    let list = ListView()
    var scrollToIdentifier: AnyIdentifier? = nil
    var scrollToText: String? = nil

    private var items: [Item<BottomPinnedItem>] = []

    override func loadView()
    {
        self.view = self.list
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItems)),
            UIBarButtonItem(title: "Remove", style: .plain, target: self, action: #selector(removeItem)),
        ]
    }

    @objc private func addItems()
    {
        let last = items.last

        for i in 1...20 {
            let text = "Item \(items.count)"
            let item = Item(BottomPinnedItem(text: text))
            items.append(item)
            if i == 12 {
                print("Attempting to scroll to \(text)...")
                scrollToIdentifier = item.anyIdentifier
                scrollToText = text
            }
        }

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

            if let scrollToIdentifier, let scrollToText {
                list.autoScrollAction = .scrollTo(
                    onInsertOf: scrollToIdentifier,
                    position: .init(position: .centered),
                    animation: ViewAnimation.inherited,
                    didPerform: { _ in print("Scrolled to (and centered) \(scrollToText)") }
                )
            }
        }
    }
}
