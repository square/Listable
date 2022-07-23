//
//  IsContentEquivalent.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/28/21.
//

import Foundation


public struct KeyPathEquivalent<Value> {
    
    private var comparisons : [(Value, Value) -> Bool]
    
    public init(
        _ configure : (inout Self) -> ()
    ) {
        self.comparisons = []
        
        configure(&self)
    }
    
    public mutating func add<Property:Equatable>(
        _ keyPath : KeyPath<Value, Property>
    ) {
        self.add(keyPath) { $0 == $1 }
    }
    
    public mutating func add<Property:AnyObject>(
        _ keyPath : KeyPath<Value, Property>
    ) {
        self.add(keyPath) { $0 === $1 }
    }
    
    public mutating func add<Property:AnyObject & Equatable>(
        _ keyPath : KeyPath<Value, Property>
    ) {
        self.add(keyPath) { $0 == $1 }
    }
    
    public mutating func add<Property>(
        _ keyPath : KeyPath<Value, Property>,
        with compare : @escaping (Property, Property) -> Bool
    ) {
        self.comparisons.append({ lhs, rhs in
            compare(lhs[keyPath: keyPath], rhs[keyPath: keyPath])
        })
    }
    
    public func isEquivalent(_ lhs : Value, _ rhs : Value) -> Bool {
        for comparison in comparisons {
            if comparison(lhs, rhs) == false {
                return false
            }
        }
        
        return true
    }
}
