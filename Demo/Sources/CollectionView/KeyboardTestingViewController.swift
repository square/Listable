//
//  KeyboardTestingViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 11/6/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import UIKit
import Listable


final class KeyboardTestingViewController : UIViewController
{
    let listView = ListView()
    
    override func loadView()
    {
        self.view = self.listView
        
        self.listView.appearance.layout.itemSpacing = 10.0
        
        self.listView.setContent { list in
            list += Section(identifier: "section") { section in
                section += Item(with: TextField(content: "Item 1"), appearance: TextFieldAppearance(), sizing: .fixed(100.0))
                section += Item(with: TextField(content: "Item 2"), appearance: TextFieldAppearance(), sizing: .fixed(100.0))
                section += Item(with: TextField(content: "Item 3"), appearance: TextFieldAppearance(), sizing: .fixed(100.0))
                section += Item(with: TextField(content: "Item 4"), appearance: TextFieldAppearance(), sizing: .fixed(100.0))
                section += Item(with: TextField(content: "Item 5"), appearance: TextFieldAppearance(), sizing: .fixed(100.0))
                section += Item(with: TextField(content: "Item 6"), appearance: TextFieldAppearance(), sizing: .fixed(100.0))
                section += Item(with: TextField(content: "Item 7"), appearance: TextFieldAppearance(), sizing: .fixed(100.0))
                section += Item(with: TextField(content: "Item 8"), appearance: TextFieldAppearance(), sizing: .fixed(100.0))
                section += Item(with: TextField(content: "Item 9"), appearance: TextFieldAppearance(), sizing: .fixed(100.0))
                section += Item(with: TextField(content: "Item 10"), appearance: TextFieldAppearance(), sizing: .fixed(100.0))
                section += Item(with: TextField(content: "Item 11"), appearance: TextFieldAppearance(), sizing: .fixed(100.0))
                section += Item(with: TextField(content: "Item 12"), appearance: TextFieldAppearance(), sizing: .fixed(100.0))
                section += Item(with: TextField(content: "Item 13"), appearance: TextFieldAppearance(), sizing: .fixed(100.0))
                section += Item(with: TextField(content: "Item 14"), appearance: TextFieldAppearance(), sizing: .fixed(100.0))
            }
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Dismiss Keyboard", style: .plain, target: self, action: #selector(dismissKeyboard))
    }
    
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
}

struct TextField : ItemElement
{
    var content : String
    
    // MARK: ItemElement
    
    typealias Appearance = TextFieldAppearance
    
    var identifier: Identifier<TextField> {
        return .init(self.content)
    }
    
    func wasUpdated(comparedTo other: TextField) -> Bool
    {
        return self.content != other.content
    }
    
    func apply(to view: ItemElementView<UITextField, UIView, UIView>, with state: ItemState, reason: ApplyReason)
    {
        view.content.text = self.content
    }
}

struct TextFieldAppearance : ItemElementAppearance
{
    // MARK: ItemElementAppearance
    
    typealias ContentView = UITextField
    typealias BackgroundView = UIView
    typealias SelectedBackgroundView = UIView
    
    static func createReusableItemView(frame: CGRect) -> ItemElementView<UITextField, UIView, UIView>
    {
        return ItemElementView(content: UITextField(frame: frame), background: UIView(), selectedBackground: UIView())
    }
    
    func update(view: ItemElementView<UITextField, UIView, UIView>, with position: ItemPosition)
    {
        
    }
    
    func apply(to view: ItemElementView<UITextField, UIView, UIView>, with state: ItemState, previous: TextFieldAppearance?)
    {
        view.contentInset = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        view.backgroundColor = .init(white: 0.97, alpha: 1.0)
        
        view.content.font = .systemFont(ofSize: 24.0, weight: .semibold)
    }
}
