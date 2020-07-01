//
//  Identifier.swift
//  Listable
//
//  Created by Kyle Van Essen on 7/1/19.
//

import Foundation


public class AnyIdentifier : Hashable, CustomDebugStringConvertible
{
    private let representedType : ObjectIdentifier
    
    fileprivate let value : AnyHashable
    
    private let hash : Int
    
    fileprivate init(type : ObjectIdentifier, value : AnyHashable)
    {
        self.representedType = type
        self.value = value
        
        var hasher = Hasher()
        hasher.combine(self.representedType)
        hasher.combine(self.value)
        self.hash = hasher.finalize()
    }
    
    // MARK: Equatable
    
    public static func == (lhs: AnyIdentifier, rhs: AnyIdentifier) -> Bool
    {
        return lhs.hash == rhs.hash && lhs.representedType == rhs.representedType && lhs.value == rhs.value
    }
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(self.hash)
    }
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription : String {
        fatalError()
    }
}


public final class Identifier<Represented> : AnyIdentifier
{
    /// Identifier which identifies by the type of `Represented` only.
    /// If you have multiple of `Represented` within a list, it is recommended that
    /// you use `init(_ value:)` to provide a unique inner value.
    public convenience init()
    {
        self.init("")
    }
    
    public init<Value:Hashable>(_ value : Value)
    {
        super.init(
            type: ObjectIdentifier(Represented.self),
            value: AnyHashable(value)
        )
    }
    
    // MARK: CustomDebugStringConvertible
    
    public override var debugDescription : String {
        "Identifier<\(String(describing: Represented.self))>: \(self.value.identifierContentString)"
    }
}


fileprivate extension AnyHashable
{
    var identifierContentString : String {
        if let base = self.base as? CustomDebugStringConvertible {
            return base.debugDescription
        } else if let base = self.base as? CustomStringConvertible {
            return base.description
        } else {
            return self.debugDescription
        }
    }
}
