//
//  UIEdgeInsets.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/28/21.
//

import Foundation
import UIKit


extension UIEdgeInsets {
    
    static func + (lhs : UIEdgeInsets, rhs : UIEdgeInsets) -> UIEdgeInsets {
        UIEdgeInsets(
            top: lhs.top + rhs.top,
            left: lhs.left + rhs.left,
            bottom: lhs.bottom + rhs.bottom,
            right: lhs.right + rhs.right
        )
    }
}
