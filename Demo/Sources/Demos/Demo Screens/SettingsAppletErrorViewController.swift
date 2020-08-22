//
//  SettingsAppletErrorViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 8/21/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import UIKit
import Listable
import BlueprintLists


final class SettingsAppletErrorViewController : ListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Swap", style: .plain, target: self, action: #selector(performSwap))
    }
    
    override func configure(list: inout ListProperties) {
        
        
        
        if self.isSwapped {
            list.content
        } else {
            list.content
        }
        
    }
    
    var isSwapped : Bool = false
    
    @objc private func performSwap() {
        self.isSwapped = true
        self.reload(animated: true)
    }
}
