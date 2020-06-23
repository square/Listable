//
//  WidthCustomizationViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 11/10/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//


import UIKit
import Listable
import BlueprintUI
import BlueprintUICommonControls
import BlueprintLists


final class WidthCustomizationViewController : UIViewController
{
    let listView = ListView()
    
    override func loadView()
    {
        self.view = self.listView
        
        self.listView.setProperties { list in
            
            list.layout = .list {
                $0.layout.set {
                    $0.padding = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
                    $0.itemSpacing = 20.0
                    $0.interSectionSpacingWithFooter = 20.0
                    $0.interSectionSpacingWithNoFooter = 20.0
                }
            }
            
            list += Section(identifier: "default") { section in
                
                section.layout = Section.Layout(width: .default)
                
                section += Item(
                    CardElement(title: "Default Row In Default Section", color: .white(0.95)),
                    sizing: .thatFits
                )
            }
            
            list += Section(identifier: "fill") { section in
                
                section.layout = Section.Layout(width: .fill)
                
                section += Item(
                    CardElement(title: "Default Row In Fill Section", color: .white(0.95)),
                    sizing: .thatFits
                )
            }
            
            list += Section(identifier: "custom-1") { section in

                section.layout = Section.Layout(width: .custom(.init(
                        padding: HorizontalPadding(uniform: 10.0),
                        width: .atMost(200.0),
                        alignment: .left
                        )
                    )
                )
                
                section += Item(
                    CardElement(title: "Default Row In Left Section", color: .white(0.95)),
                    sizing: .thatFits,
                    layout: .init(width: .default)
                )
                
                section += Item(
                    CardElement(title: "Left Aligned In Left Section", color: .white(0.95)),
                    sizing: .thatFits,
                    layout: .init(width: .custom(.init(
                        padding: HorizontalPadding(uniform: 10.0),
                        width: .atMost(200.0),
                        alignment: .left
                        ))
                    )
                )
                
                section += Item(
                    CardElement(title: "Center Aligned In Left Section", color: .white(0.95)),
                    sizing: .thatFits,
                    layout: .init(width: .custom(.init(
                        padding: HorizontalPadding(uniform: 10.0),
                        width: .atMost(200.0),
                        alignment: .center
                        ))
                    )
                )
                
                section += Item(
                    CardElement(title: "Right Aligned In Left Section", color: .white(0.95)),
                    sizing: .thatFits,
                    layout: .init(width: .custom(.init(
                        padding: HorizontalPadding(uniform: 10.0),
                        width: .atMost(200.0),
                        alignment: .right
                        ))
                    )
                )
            }
        }
    }
}


fileprivate struct CardElement : BlueprintItemContent, Equatable
{
    var title : String
    var color : UIColor
    
    //
    // MARK: BlueprintItemElement
    //
    
    var identifier: Identifier<CardElement> {
        return .init(self.title)
    }
    
    func element(with info : ApplyItemContentInfo) -> Element
    {
        return Box(
            backgroundColor: self.color,
            cornerStyle: .rounded(radius: 5.0),
            wrapping: Inset(uniformInset: 10.0, wrapping: Label(text: self.title) {
                $0.font = .systemFont(ofSize: 16.0, weight: .bold)
            })
        )
    }
}
