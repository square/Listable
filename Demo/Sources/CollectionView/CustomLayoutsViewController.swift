//
//  CustomLayoutsViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 5/3/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import UIKit

import Listable
import BlueprintLists
import BlueprintUI
import BlueprintUICommonControls


final class CustomLayoutsViewController : UIViewController
{
    let listView = ListView()
    
    override func loadView()
    {
        self.view = self.listView
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Swap Layout", style: .plain, target: self, action: #selector(swapLayout))
        
        self.listView.setContent { list in
            
            list.appearance = demoAppearance
            
            list.appearance.grid.sizing.itemSize = .fixed(CGSize(width: 80.0, height: 80.0))

            list += Section(identifier: "default") { section in
                
                section.header = HeaderFooter(DemoHeader(title: "Some Rows"))
                
                section += Item(
                    DemoItem(text: "Row 1"),
                    sizing: .thatFits
                )
                
                section += Item(
                    DemoItem(text: "Row 2"),
                    sizing: .thatFits
                )
                
                section += Item(
                    DemoItem(text: "Row 3"),
                    sizing: .thatFits
                )
                
                section += Item(
                    DemoItem(text: "Row 4"),
                    sizing: .thatFits
                )
                
                section += Item(
                    DemoItem(text: "Row 5"),
                    sizing: .thatFits
                )
                
                section += Item(
                    DemoItem(text: "Row 6"),
                    sizing: .thatFits
                )
            }
        }
    }
    
    private var gridOn : Bool = false
    
    @objc func swapLayout()
    {
        self.gridOn.toggle()
        
        if self.gridOn {
            self.listView.set(layoutType: .grid, animated: true)
        } else {
            self.listView.set(layoutType: .list, animated: true)
        }
    }
    
}
