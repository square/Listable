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
@propertyWrapper
public struct Color: Equatable {
    /// The underlying color value.
    public var wrappedValue: UIColor

    public init(_ wrappedValue: UIColor) {
        self.wrappedValue = wrappedValue
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        if #available(iOS 13.0, *) {
            return lhs.wrappedValue.resolvedColor(with: .current) == rhs.wrappedValue.resolvedColor(with: .current)
        } else {
            return lhs.wrappedValue == rhs.wrappedValue
        }
    }
}
