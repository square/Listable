//
//  SupplementaryTestingViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 8/23/22.
//  Copyright © 2022 Kyle Van Essen. All rights reserved.
//

import ListableUI


final class SupplementaryTestingViewController : ListViewController
{
    var count : Int = 1
    
    override func configure(list: inout ListProperties) {
        
        list.header = DemoHeader(title: "Count: \(count)")
        
        list.overscrollFooter = DemoFooter(text: "This is an overscroll footer")
        
        list.add {
            Section("id \(count)") {
                for _ in 1...10 {
                    DemoItem(text: "Count: \(count)")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Increment", style: .plain, target: self, action: #selector(increment))
    }
    
    @objc func increment() {
        self.count += 1
        
        self.reload(animated: true)
    }
}
