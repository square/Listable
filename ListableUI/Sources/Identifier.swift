//
//  Identifier.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 7/1/19.
//

import Foundation


///
/// An `Identifier` is used to unique items in Listable lists. Sections,
/// and items in those sections have identifiers, which are used to keep track
/// of those items and sections as updates are pushed through the list view.
///
/// Identifiers for content shouldn't change – if it does, the item or section is
/// treated as a new item. This means that for your `ItemContent` or `Section`,
/// you should use a stable identifier like server ID or unique value that does not change.
///
/// Identifiers do _not_ have to be unique, but it certainly helps. When applying updates,
/// Listable will convert duplicate identifiers to unique identifiers by counting upward for
/// each equal identifier it finds (eg, "MyID.1, MyID.2, MyID.3", etc). However, you should do
/// your best to ensure identifiers are unique, as this helps generate a visually correct diff when applying updates.
///
/// Identifiers are strongly typed; alongside their contained value,
/// they also encode their `Represented` type. This means that these two
/// identifiers are different, despite having the same `value`.
/// ```
/// let first = Identifier<MyThing>("value")
/// let second = Identifier<MyOtherThing>("value")
/// ```
/// Even once type-erased to `AnyIdentifier`, these identifiers will still not be
/// equal, because their underlying `Represented` type is different.
///
public final class Identifier<Represented> : AnyIdentifier
{
    /// Identifier which identifies by the type of `Represented` only.
    /// If you have multiple of `Represented` within a list, it is recommended that
    /// you use `init(_ value:)` to provide a unique inner value.
    public convenience init()
    {
        self.init("")
    }
    
    /// Creates an identifier which identifies by both `Represented`, and the `value` passed to init.
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


///
/// A type-erased `Identifier` used to identify content in a listable list.
///
/// Even though type-erased, the original `Represented` type from the `Identifier`
/// is still retained when being type erased, meaning comparing two `AnyIdentifiers`
/// with the same `value` but different `Represented` types will report `false`:
/// ```
/// let first = Identifier<MyThing>("value") as AnyIdentifier
/// let second = Identifier<MyOtherThing>("value") as AnyIdentifier
///
/// let equal = first == second // false
/// ```
/// Note that like Swift `KeyPath`s, `AnyIdentifier` is the base type for
/// `Identifier<Represented>`. This is done purely for performance reasons;
/// it allows free bridging from `Identifier` to `AnyIdentifier`.
///
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
