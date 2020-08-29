//
//  RootViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 8/28/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import UIKit
import Listable


public final class RootViewController : ListViewController
{
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Listable"
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        }
    }
    
    func push(_ viewController : UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    public override func configure(list: inout ListProperties) {
        
        list.appearance = .demoAppearance
        list.layout = .demoLayout
        
        list.content.overscrollFooter = HeaderFooter(
            DemoHeader(title: "Thanks for using Listable!!")
        )
        
        list("list-view") { section in
            
            section += Item(
                DemoTitleDetailItem(
                    title: "Developer Demos",
                    detail: "Are you a developer builing something with Listable? This is what you should check out! This screen contains real world usage demos and examples of how to build lists with Listable."
                ),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(InternalDemosViewController())
                }
            )
            
            section += Item(
                DemoTitleDetailItem(
                    title: "Internal Demos",
                    detail: "Are you a developer working on Listable? Check on this screen. It has specific technical demos and examples for how specific features in the framework work, as well as screens that exist to reproduce and test the existence of various bugs and behaviours."
                ),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(InternalDemosViewController())
                }
            )
        }
    }
}
