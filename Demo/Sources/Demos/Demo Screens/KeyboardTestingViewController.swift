//
//  KeyboardTestingViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 11/6/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import BlueprintUI
import BlueprintUICommonControls
import BlueprintUILists
import ListableUI
import UIKit

final class KeyboardTestingViewController: UIViewController {
    let listView = ListView()

    override func loadView() {
        view = listView

        listView.layout = .table {
            $0.layout.itemSpacing = 10.0
        }

        listView.configure { list in
            list.content.overscrollFooter = DemoHeader(title: "Thanks for using Listable!!")

            list += Section("section") {
                for index in 1 ... 14 {
                    Item(TextFieldElement(content: "Item \(index)"), sizing: .fixed(height: 100.0))
                }
            }
        }

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Dismiss Keyboard", style: .plain, target: self, action: #selector(dismissKeyboard)),
            UIBarButtonItem(title: "Toggle Mode", style: .plain, target: self, action: #selector(toggleMode)),
        ]
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func toggleMode() {
        switch listView.behavior.keyboardAdjustmentMode {
        case .none:
            listView.behavior.keyboardAdjustmentMode = .adjustsWhenVisible
        case .adjustsWhenVisible:
            listView.behavior.keyboardAdjustmentMode = .none
        }
    }
}

struct TextFieldElement: BlueprintItemContent, Equatable {
    var content: String

    // MARK: BlueprintItemElement

    var identifierValue: String {
        content
    }

    func element(with _: ApplyItemContentInfo) -> Element {
        let textField = TextField(text: content)

        return Box(
            backgroundColor: .init(white: 0.97, alpha: 1.0),
            cornerStyle: .square,
            wrapping: Inset(uniformInset: 20.0, wrapping: textField)
        )
    }
}
