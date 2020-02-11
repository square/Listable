//
//  RefreshControlViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 2/10/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import UIKit
import Listable
import BlueprintLists


final class RefreshControlViewController : UIViewController
{
    let listView : ListView = ListView()
    
    override func loadView()
    {
        self.view = self.listView
        
        //self.listView.appearance = demoAppearance
        
        self.reloadContent(animated: false, state: .present(false))
    }
    
    func reloadContent(animated : Bool, state : RefreshControlState)
    {
        self.listView.setContent { list in
            list.animatesChanges = animated
            
            switch state {
            case .none: break
            case .present(let isRefreshing):
                list.content.refreshControl = RefreshControl(isRefreshing: isRefreshing, onRefresh: {
                    self.reloadContent(animated: true, state: .present(false))
                })
            }
            
            list += Section(identifier: "list") { section in
                
                section.header = HeaderFooter(
                    with: DemoHeader(title: "Section Header")
                )
                
                section += DemoItem(text: "Row 1")
                section += DemoItem(text: "Row 2")
                section += DemoItem(text: "Row 3")
                section += DemoItem(text: "Row 4")
                section += DemoItem(text: "Row 5")
                section += DemoItem(text: "Row 6")
                section += DemoItem(text: "Row 7")
                section += DemoItem(text: "Row 8")
                section += DemoItem(text: "Row 9")
            }
        }
    }
    
    enum RefreshControlState : Equatable
    {
        case none
        case present(Bool)
    }
}
