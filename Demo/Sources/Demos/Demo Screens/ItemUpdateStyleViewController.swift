//
//  ItemUpdateStyleViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 7/21/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import UIKit
import Listable


final class ItemUpdateStyleViewController : ListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(performUpdate))
    }
    
    var count : Int = 1
    
    override func configure(list: inout ListProperties) {
        
        list.appearance = .demoAppearance
        list.layout = .demoLayout
        
        list("section") { section in
            section += Item(DemoItem(text: "\(count)", identifier: "row"), updateStyle: .transition(0.2, .crossDissolve))
        }
    }
    
    @objc private func performUpdate()
    {
        self.count += 1
        
        self.reload(animated: true)
    }
}
