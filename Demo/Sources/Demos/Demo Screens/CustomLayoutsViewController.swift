//
//  CustomLayoutsViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 5/3/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import UIKit

import ListableUI
import BlueprintUILists
import BlueprintUI
import BlueprintUICommonControls


final class CustomLayoutsViewController : UIViewController
{
    let listView = ListView()
    
    override func loadView()
    {
        self.view = self.listView
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Swap Layout", style: .plain, target: self, action: #selector(swapLayout))
        
        self.listView.configure { list in
            
            list.appearance = .demoAppearance
            list.layout = .demoLayout

            list += Section("default") {
                DemoItem(text: "Row 1")
                DemoItem(text: "Row 2")
                DemoItem(text: "Row 3")
                DemoItem(text: "Row 4")
                DemoItem(text: "Row 5")
                DemoItem(text: "Row 6")
            } header: {
                DemoHeader(title: "Some Rows")
            }
        }
    }
    
    private var gridOn : Bool = false
    
    @objc func swapLayout()
    {
        self.gridOn.toggle()
        
        if self.gridOn {
            self.listView.set(layout: .experimental_grid(), animated: true)
        } else {
            self.listView.set(layout: .demoLayout, animated: true)
        }
    }
    
}
