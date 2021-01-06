//
//  Color.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 1/6/21.
//

import UIKit


/// A color wrapper which provides equatability for
/// dynamic `UIColor` instances, by comparing their resolved
/// value to the current `UITraitCollection`.
public struct Color : Equatable {
    
    /// The underlying color value.
    public var value : UIColor
    
    public init(_ value : UIColor) {
        self.value = value
    }
    
    public static func == (lhs : Self, rhs : Self) -> Bool {
        if #available(iOS 13.0, *) {
            return lhs.value.resolvedColor(with: .current) == rhs.value.resolvedColor(with: .current)
        } else {
            return lhs.value == rhs.value
        }
    }
}
