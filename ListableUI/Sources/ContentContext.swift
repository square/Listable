//
//  ContentContext.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/10/22.
//

import Foundation


public struct ContentContext : Equatable {
    
    private let value : Any
    private let isEqual : (Any) -> Bool
    
    public init<Value:Equatable>(_ value : Value) {
        self.value = value
        self.isEqual = { other in
            guard let other = other as? Value else { return false}
            
            return value == other
        }
    }
    
    public static func == (lhs : ContentContext, rhs : ContentContext) -> Bool {
        lhs.isEqual(rhs.value)
    }
}
