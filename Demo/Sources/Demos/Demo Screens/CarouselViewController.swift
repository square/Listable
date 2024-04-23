//
//  CarouselViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 6/4/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import BlueprintUILists
import BlueprintUICommonControls


final class CarouselViewController : UIViewController
{
    let blueprintView = BlueprintView()
        
    override func loadView()
    {
        self.view = self.blueprintView
        
        self.update()
    }
    
    func update()
    {
        self.blueprintView.element = List { list in
                        
            list.layout = .carousel()
        } sections: {
            Section("first") {
                DemoElement(color: .red)
                DemoElement(color: .orange)
                DemoElement(color: .yellow)
                DemoElement(color: .green)
                DemoElement(color: .blue)
            }
        }
    }
}

fileprivate struct DemoElement : BlueprintItemContent, Equatable
{
    var identifierValue: UIColor {
        self.color
    }
    
    var color : UIColor
    
    func element(with info: ApplyItemContentInfo) -> Element {
        Box(backgroundColor: self.color)
    }
}

