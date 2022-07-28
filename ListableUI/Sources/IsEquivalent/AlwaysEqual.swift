//
//  AlwaysEqual.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 7/27/22.
//

import Foundation


@propertyWrapper public struct AlwaysEqual<Value> : Equatable {
    
    public var wrappedValue : Value
    
    public init(wrappedValue : Value) {
        self.wrappedValue = wrappedValue
    }
    
    public static func == (lhs : Self, rhs : Self) -> Bool {
        true
    }
}
