//
//  SizingSharingCacheDemoViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 4/5/25.
//  Copyright © 2025 Kyle Van Essen. All rights reserved.
//

import Foundation
import UIKit
import BlueprintUILists
import ListableUI


final class SizingSharingCacheDemoViewController: ListViewController {
    
    override func configure(list: inout ListProperties) {
    
    
        
    }
    
    fileprivate struct Demoitem: BlueprintItemContent, Equatable {
        
        var identifierValue: AnyHashable
        
        func element(with info: ApplyItemContentInfo) -> any Element {
            Empty()
        }
    }
}
