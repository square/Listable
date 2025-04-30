//
//  AutoScrollingViewController3.swift
//  Demo
//
//  Created by Gil Birman on 4/30/25.
//  Copyright © 2025 Kyle Van Essen. All rights reserved.
//

import UIKit

import ListableUI
import BlueprintUILists
import BlueprintUI
import BlueprintUICommonControls


final class AutoScrollingViewController3 : UIViewController
{
    let list = ListView()

    private let items: [Item<BottomPinnedItem>] = Array(0...100).map {
        Item(BottomPinnedItem(text: "Item \($0)"))
    }

    override func loadView() {
        self.view = self.list
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateItems()
    }

    private func updateItems() {
        
        self.list.configure { list in
            list.appearance = .demoAppearance
            list.layout = .demoLayout

            // THIS WORKS ONLY IF YOU CHANGE THIS TO .top:
            list.behavior.verticalLayoutGravity = .bottom

            list.animation = .fast
            
            list += Section("items", items: self.items)

            let seekToIdentifier = items[Int(items.count / 2)].anyIdentifier
            list.autoScrollAction = .scrollTo(
                .item(seekToIdentifier),
                onInsertOf: seekToIdentifier,
                position: .init(position: .centered, ifAlreadyVisible: .scrollToPosition),
                animated: false,
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
