//
//  KeyboardTestingViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 11/6/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import BlueprintLists
import BlueprintUI
import BlueprintUICommonControls
import Listable
import UIKit

final class KeyboardTestingViewController: UIViewController {
  let listView = ListView()

  override func loadView() {
    self.view = self.listView

    self.listView.appearance.layout.itemSpacing = 10.0

    self.listView.setContent { list in
      list.content.overscrollFooter = HeaderFooter(
        with: DemoHeader(title: "Thanks for using Listable!!")
      )

      list += Section(identifier: "section") { section in
        section += Item(with: TextFieldElement(content: "Item 1"), sizing: .fixed(100.0))
        section += Item(with: TextFieldElement(content: "Item 2"), sizing: .fixed(100.0))
        section += Item(with: TextFieldElement(content: "Item 3"), sizing: .fixed(100.0))
        section += Item(with: TextFieldElement(content: "Item 4"), sizing: .fixed(100.0))
        section += Item(with: TextFieldElement(content: "Item 5"), sizing: .fixed(100.0))
        section += Item(with: TextFieldElement(content: "Item 6"), sizing: .fixed(100.0))
        section += Item(with: TextFieldElement(content: "Item 7"), sizing: .fixed(100.0))
        section += Item(with: TextFieldElement(content: "Item 8"), sizing: .fixed(100.0))
        section += Item(with: TextFieldElement(content: "Item 9"), sizing: .fixed(100.0))
        section += Item(with: TextFieldElement(content: "Item 10"), sizing: .fixed(100.0))
        section += Item(with: TextFieldElement(content: "Item 11"), sizing: .fixed(100.0))
        section += Item(with: TextFieldElement(content: "Item 12"), sizing: .fixed(100.0))
        section += Item(with: TextFieldElement(content: "Item 13"), sizing: .fixed(100.0))
        section += Item(with: TextFieldElement(content: "Item 14"), sizing: .fixed(100.0))
      }
    }

    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Dismiss Keyboard", style: .plain, target: self, action: #selector(dismissKeyboard))
  }

  @objc func dismissKeyboard() {
    self.view.endEditing(true)
  }
}

struct TextFieldElement: BlueprintItemElement, Equatable {
  var content: String

  // MARK: BlueprintItemElement

  var identifier: Identifier<TextFieldElement> {
    return .init(self.content)
  }

  func element(with info: ApplyItemElementInfo) -> Element {
    let textField = TextField(text: self.content)

    return Box(
      backgroundColor: .init(white: 0.97, alpha: 1.0),
      cornerStyle: .square,
      wrapping: Inset(uniformInset: 20.0, wrapping: textField)
    )
  }
}
