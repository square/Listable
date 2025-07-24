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
    private var insets: UIEdgeInsets = .zero

    override func loadView()
    {
        self.view = self.listView
        
        self.listView.layout = .table {
            $0.layout.itemSpacing = 10.0
        }

        self.listView.customScrollViewInsets = { [weak self] in
            if let insets = self?.insets {
                return .init(content: insets, verticalScroll: insets)
            } else {
                return .init()
            }
        }

        self.listView.onKeyboardFrameWillChange = { [weak self] keyboardCurrentFrameProvider, animation in
            guard let self = self else { return }
            switch keyboardCurrentFrameProvider.currentFrame(in: self.listView) {
            case .nonOverlapping, .none:
                self.insets.bottom = 0
            case .overlapping(let frame):
                self.insets.bottom = frame.height - self.view.safeAreaInsets.bottom
            }
            self.listView.updateScrollViewInsets()
        }
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Dismiss Keyboard", style: .plain, target: self, action: #selector(dismissKeyboard)),
            UIBarButtonItem(title: "Toggle Mode", style: .plain, target: self, action: #selector(toggleMode)),
        ]
        
        reload()
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
            self.listView.behavior.keyboardAdjustmentMode = .custom
        case .custom:
            self.listView.behavior.keyboardAdjustmentMode = .none
        }
        reload()
    }

    private func reload() {
        let mode: String = {
            switch self.listView.behavior.keyboardAdjustmentMode {
            case .none:
                return "none"
            case .adjustsWhenVisible:
                return "adjustsWhenVisible"
            case .custom:
                return "custom"
            }
        }()
        
        self.listView.configure { list in
            list.content.overscrollFooter = DemoHeader(title: "Thanks for using Listable!!")
            
            list += Section("section") {
                for index in 1...14 {
                    Item(TextFieldElement(content: "Item \(index) (mode: \(mode))"), sizing: .fixed(height: 100.0))
                }
            }
        }

        self.listView.updateScrollViewInsets()
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
