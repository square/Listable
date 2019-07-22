//
//  Identifier.swift
//  Listable
//
//  Created by Kyle Van Essen on 7/1/19.
//

import Foundation


public struct AnyIdentifier : Hashable
{
    private let value : AnyHashable
    
    public init<Element>(_ value : Identifier<Element>)
    {
        self.value = AnyHashable(value)
    }
}

public struct Identifier<Element> : Hashable
{
    private let value : AnyHashable
    private let type : ObjectIdentifier
    
    public init<Value:Hashable>(_ value : Value)
    {
        self.value = AnyHashable(value)
        self.type = ObjectIdentifier(Element.self)
    }
}

public protocol Identifiable
{
    var identifier : Identifier<Self> { get }
}
