//
//  Identifier.swift
//  Listable
//
//  Created by Kyle Van Essen on 7/1/19.
//

import Foundation


public final class AnyIdentifier : Hashable
{
    private let value : AnyHashable
    
    public init<Element>(_ value : Identifier<Element>)
    {
        self.value = AnyHashable(value)
    }
    
    // Equatable
    
    public static func == (lhs: AnyIdentifier, rhs: AnyIdentifier) -> Bool
    {
        return lhs.value == rhs.value
    }
    
    // Hashable
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(self.value)
    }
}

public final class Identifier<Element> : Hashable
{
    private let type : ObjectIdentifier
    private let value : AnyHashable
    
    public init<Value:Hashable>(_ value : Value)
    {
        self.value = AnyHashable(value)
        self.type = ObjectIdentifier(Element.self)
    }
    
    // Equatable
    
    public static func == (lhs: Identifier<Element>, rhs: Identifier<Element>) -> Bool
    {
        return lhs.type == rhs.type && lhs.value == rhs.value
    }
    
    // Hashable
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(self.type)
        hasher.combine(self.value)
    }
}

public protocol Identifiable
{
    var identifier : Identifier<Self> { get }
}
