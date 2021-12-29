//
//  ItemInsertAndRemoveAnimationsViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 6/21/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import Foundation
import BlueprintUILists


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
        
        list += Section("animations") {
            
            for animation in self.animations {
                if deleted != animation {
                    Item(
                        DemoItem(text: animation.id),
                        selectionStyle: .tappable,
                        insertAndRemoveAnimations: animation.animations,
                        onSelect: { _ in
                            self.view.isUserInteractionEnabled = false
                            
                            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                                self.deleted = animation
                                self.reload(animated: true)
                                
                                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                    self.view.isUserInteractionEnabled = true
                                    
                                    self.deleted = nil
                                    self.reload(animated: true)
                                }
                            }
                        }
                    )
                }
            }
            
            DemoItem(text: "Extra Row 1")
            DemoItem(text: "Extra Row 2")
            DemoItem(text: "Extra Row 3")
        } header: {
            DemoHeader(title: "Item Animations")
        }
    }
}
