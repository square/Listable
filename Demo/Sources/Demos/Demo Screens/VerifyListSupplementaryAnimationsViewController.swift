//
//  VerifyListSupplementaryAnimationsViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 11/9/21.
//  Copyright © 2021 Kyle Van Essen. All rights reserved.
//

import Foundation
import BlueprintUILists


final class VerifyListSupplementaryAnimationsViewController : ListViewController {
    
    private var isToggled : Bool = false {
        didSet {
            self.reload(animated: true)
        }
    }
    
    override func configure(list: inout ListProperties) {
        
        list.appearance = .demoAppearance
        list.layout = .demoLayout
        
        list.content.header = DemoHeader(title: "A Header")
        list.content.footer = DemoHeader(title: "A Footer")
        
        if isToggled {
            list("toggled") { section in
                section += DemoItem(text: "Toggled Row 1")
                section += DemoItem(text: "Toggled Row 2")
                section += DemoItem(text: "Toggled Row 3")
            }
        } else {
            list("main") { section in
                section += DemoItem(text: "Main Row 1")
                section += DemoItem(text: "Main Row 2")
                section += DemoItem(text: "Main Row 3")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Toggle",
            style: .plain,
            target: self,
            action: #selector(toggleSections)
        )
    }
    
    @objc private func toggleSections() {
        
        self.isToggled.toggle()
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            self.isToggled.toggle()
        }
    }
}
