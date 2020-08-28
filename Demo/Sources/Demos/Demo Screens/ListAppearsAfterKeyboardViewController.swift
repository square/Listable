//
//  ListAppearsAfterKeyboardViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 8/26/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import UIKit
import BlueprintLists
import BlueprintUICommonControls


final class ListAppearsAfterKeyboardViewController : UIViewController {
    
    let blueprintView = BlueprintView()
    
    override func loadView() {
        self.view = self.blueprintView
        
        self.blueprintView.element = self.element
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Toggle List", style: .plain, target: self, action: #selector(toggleList)),
            UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(dismissKeyboard))
        ]
    }
    
    var showingList : Bool = false
    
    var element : Element {
        EnvironmentReader { env in
            Column { column in
                column.horizontalAlignment = .fill
                column.verticalUnderflow = .growProportionally
                                
                column.add(growPriority: 0, shrinkPriority: 0, child: TextField(text: "") {
                    $0.placeholder = "Tap Into This Field To Show The Keyboard"
                    $0.textAlignment = .center
                })
                
                if self.showingList {
                    column.add(child: List { list in
                        
                        list.behavior.keyboardDismissMode = .none
                        
                        list("section") { section in
                            section += (1...20).map { index in
                                DemoItem(text: "Item \(index)")
                            }
                        }
                    })
                }
            }.inset(by: env.safeAreaInsets)
        }
    }
    
    @objc func toggleList() {
        self.showingList.toggle()
        
        self.blueprintView.element = self.element
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
