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


class AutoScrollingViewController3 : UIViewController {
    
    let list = ListView()
    
    lazy var insertButton: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
    }()
    
    lazy var removeButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Remove", style: .plain, target: self, action: #selector(removeItem))
    }()
    
    lazy var toggleAnimationsButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Toggle Animations", style: .plain, target: self, action: #selector(toggleAnimations))
    }()
    
    fileprivate var animateAutoscroll: Bool = false

    private var items: [Item<BottomPinnedItem>] = Array(0...100).map {
        Item(BottomPinnedItem(text: "Item \($0)"))
    }
    
    private var observedItem = Item(BottomPinnedItem(text: "Item 50"))
    
    fileprivate var seekToIdentifier: AnyIdentifier { observedItem.anyIdentifier }
    
    var autoScrollAction: AutoScrollAction {
        assertionFailure("Override \(#function) in subclasses.")
        return .pin(.firstItem, position: .init(position: .top))
    }

    override func loadView() {
        self.view = self.list
        navigationItem.rightBarButtonItems = [insertButton, removeButton, toggleAnimationsButton]
        insertButton.isEnabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateItems()
    }

    private func updateItems() {
        list.configure { list in
            list.appearance = .demoAppearance
            list.layout = .demoLayout
            list.behavior.verticalLayoutGravity = .bottom
            list.animation = .fast
            list.autoScrollAction = autoScrollAction
            
            list += Section("items", items: items)
            list += Section("itemization") {
                BottomPinnedItem(text: "Tax $2.00")
                BottomPinnedItem(text: "Discount $4.00")
                BottomPinnedItem(text: "Total $10.00")
            }
        }
    }
    
    @objc func addItem() {
        items.insert(observedItem, at: 50)
        updateItems()
        insertButton.isEnabled = false
        removeButton.isEnabled = true
    }
    
    @objc func removeItem() {
        items.remove(at: 50)
        updateItems()
        insertButton.isEnabled = true
        removeButton.isEnabled = false
    }
    
    @objc func toggleAnimations() {
        animateAutoscroll.toggle()
        print("autoScrollAction animations are \(animateAutoscroll ? "on" : "off").")
    }
}

final class ScrollToAutoscrollingViewController: AutoScrollingViewController3 {
    override var autoScrollAction: AutoScrollAction {
        .scrollTo(
            .item(seekToIdentifier),
            onInsertOf: seekToIdentifier,
            position: .init(position: .centered, ifAlreadyVisible: .scrollToPosition),
            animated: animateAutoscroll,
            didPerform: { info in
                print("Did scroll: \(info.visibleItems.map(\.identifier))")
            }
        )
    }
}

final class PinAutoscrollingViewController: AutoScrollingViewController3 {
    override var autoScrollAction: AutoScrollAction {
        .pin(
            .item(seekToIdentifier),
            position: .init(position: .centered, ifAlreadyVisible: .scrollToPosition),
            animated: animateAutoscroll,
            didPerform: { info in
                print("Did scroll: \(info.visibleItems.map(\.identifier))")
            }
        )
    }
}
