//
//  AnimatedReuseViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 8/9/24.
//  Copyright © 2024 Kyle Van Essen. All rights reserved.
//

import BlueprintUILists
import BlueprintUICommonControls


final class AnimatedReuseViewController : ListViewController {
    
    
    override func configure(list: inout ListProperties) {
        
        list.add {
            Section("items") {
                for row in 1...1000 {
                    ToggleRow(isOn: .random(), identifierValue: row)
                }
            }
        }
    }
    
    private struct ToggleRow : BlueprintItemContent, Equatable {
        
        var isOn: Bool
        var identifierValue: AnyHashable
        
        func element(with info: ApplyItemContentInfo) -> any Element {
            Toggle(isOn: isOn) { _ in }
                .centered()
                .inset(uniform: 10)
        }
        
    }
}
