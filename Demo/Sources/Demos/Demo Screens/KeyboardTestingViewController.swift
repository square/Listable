//
//  KeyboardTestingViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 11/6/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import UIKit
import ListableUI
import BlueprintUILists
import BlueprintUI
import BlueprintUICommonControls


final class KeyboardTestingViewController : UIViewController
{
    let listView = ListView()
    
    override func loadView()
    {
        self.view = self.listView
        
        self.listView.layout = .table {
            $0.layout.itemSpacing = 10.0
        }
        
        self.listView.configure { list in
            list.content.overscrollFooter = DemoHeader(title: "Thanks for using Listable!!")
            
            list += Section("section") {
                for index in 1...14 {
                    Item(TextFieldElement(content: "Item \(index)"), sizing: .fixed(height: 100.0))
                }
            }
        }
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Dismiss Keyboard", style: .plain, target: self, action: #selector(dismissKeyboard)),
            UIBarButtonItem(title: "Toggle Mode", style: .plain, target: self, action: #selector(toggleMode)),
        ]
    }
    
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
    @objc func toggleMode()
    {
        switch self.listView.behavior.keyboardAdjustmentMode {
        case .none:
            self.listView.behavior.keyboardAdjustmentMode = .adjustsWhenVisible
        case .adjustsWhenVisible:
            self.listView.behavior.keyboardAdjustmentMode = .none
        case .custom:
            self.listView.behavior.keyboardAdjustmentMode = .custom
        }
    }
}

struct TextFieldElement : BlueprintItemContent, Equatable
{
    var content : String
    
    // MARK: BlueprintItemElement
    
    var identifierValue: String {
        self.content
    }
    
    func element(with info : ApplyItemContentInfo) -> Element
    {
        let textField = TextField(text: self.content)
        
        return Box(
            backgroundColor: .init(white: 0.97, alpha: 1.0),
            cornerStyle: .square,
            wrapping: Inset(uniformInset: 20.0, wrapping: textField)
        )
    }
}
