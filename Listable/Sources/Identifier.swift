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
    
    private let hash : Int
    
    public init<Represented>(_ value : Identifier<Represented>)
    {
        self.value = AnyHashable(value)
        
        var hasher = Hasher()
        hasher.combine(self.value)
        self.hash = hasher.finalize()
    }
    
    // MARK: Equatable
    
    public static func == (lhs: AnyIdentifier, rhs: AnyIdentifier) -> Bool
    {
        return lhs.hash == rhs.hash && lhs.value == rhs.value
    }
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(self.hash)
    }
}


public final class Identifier<Represented> : Hashable
{
    private let type : ObjectIdentifier
    private let value : AnyHashable?
    
    private let hash : Int
    
    /// Identifier which identifies by the type of `Represented` only.
    /// If you have multiple of `Represented` within a list, it is recommended that
    /// you use `init(_ value:)` to provide a unique inner value.
    public convenience init()
    {
        self.init("")
    }
    
    public init<Value:Hashable>(_ value : Value)
    {
        self.value = AnyHashable(value)
        self.type = ObjectIdentifier(Represented.self)
        
        var hasher = Hasher()
        hasher.combine(self.type)
        hasher.combine(self.value)
        self.hash = hasher.finalize()
    }
    
    public var toAny : AnyIdentifier {
        AnyIdentifier(self)
    }
    
    // MARK: Equatable
    
    public static func == (lhs: Identifier<Represented>, rhs: Identifier<Represented>) -> Bool
    {
        return lhs.hash == rhs.hash && lhs.type == rhs.type && lhs.value == rhs.value
    }
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(self.hash)
    }
}
