//
//  ItemInsertAndRemoveAnimationsViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 6/21/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import Foundation
import BlueprintLists


final class ItemInsertAndRemoveAnimationsViewController : ListViewController
{
    struct Animations : Equatable
    {
        let id : String
        let animations : ItemInsertAndRemoveAnimations
        
        static func == (lhs: Self, rhs: Self) -> Bool
        {
            lhs.id == rhs.id
        }
    }

    var deleted : Animations? = nil
    
    let animations : [Animations] = [
        Animations(
            id: "Fade",
            animations: .fade
        ),
        Animations(
            id: "Right",
            animations: .right
        ),
        Animations(
            id: "Left",
            animations: .left
        ),
        Animations(
            id: "Top",
            animations: .top
        ),
        Animations(
            id: "Bottom",
            animations: .bottom
        ),
        Animations(
            id: "Scale Up",
            animations: .scaleUp
        ),
        Animations(
            id: "Scale Down",
            animations: .scaleDown
        ),
    ]
    
    override func configure(list: inout ListProperties)
    {
        list.appearance = .demoAppearance
        list.layout = .demoLayout
        
        list += Section(identifier: "animations") { section in
            
            section.header = HeaderFooter(DemoHeader(title: "Item Animations"))
            
            for animations in self.animations {
                
                guard self.deleted != animations else {
                    continue
                }
                
                section += Item(
                    DemoItem(text: animations.id),
                    selectionStyle: .tappable,
                    insertAndRemoveAnimations: animations.animations,
                    onSelect: { _ in
                        self.view.isUserInteractionEnabled = false
                        
                        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                            self.deleted = animations
                            self.reload(animated: true)
                            
                            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                self.view.isUserInteractionEnabled = true
                                
                                self.deleted = nil
                                self.reload(animated: true)
                            }
                        }
                })
            }
            
            section += DemoItem(text: "Extra Row 1")
            section += DemoItem(text: "Extra Row 2")
            section += DemoItem(text: "Extra Row 3")
        }
    }
}
