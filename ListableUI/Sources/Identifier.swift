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
/// treated as new. This means that for your `ItemContent` or `Section`,
/// you should use a stable identifier like server ID or other
/// unique value that does not change across updates to the list.
///
/// Identifiers do _not_ have to be unique, but it certainly helps.
/// When applying updates, Listable will convert duplicate identifiers to
/// unique identifiers by counting upward for each equal identifier it finds: (eg, "myID".1, "myID".2, "myID".3", etc).
/// However, you should do your best to ensure identifiers are unique,
/// as this helps generate a visually correct diff when applying updates.
///
/// Identifiers are strongly typed; alongside their contained value,
/// they also encode their `Represented` type. This means that these two
/// identifiers are different, despite having the same `value`.
/// ```swift
/// let first = Identifier<MyThing, String>("value")
/// let second = Identifier<MyOtherThing, String>("value")
/// ```
/// Even once type-erased to `AnyIdentifier`, these identifiers will still not be
/// equal, because their underlying `Represented` type is different.
///
public final class Identifier<Represented, Value:Hashable> : AnyIdentifier
{
    // MARK: Reading Values
    
    ///
    /// The underlying value that backs the identifier.
    /// For example, if you create an identifier using:
    /// ```swift
    /// Identifier<MyThing, String>("1")
    /// ```
    /// Then the value of `value` will be `"1"`.
    ///
    public var value : Value {
        self.anyValue.base as! Value
    }
    
    // MARK: Initialization
    
    ///
    /// Creates an identifier which identifies by both `Represented`, and the `value` passed to init.
    ///
    /// **Note** – It is intentional that this method is internal. You should not directly create identifiers
    /// by calling this method. Instead, use the extensions on `Section` and `ItemContent` to create
    /// strongly typed identifiers with the correct `Value` type:
    /// ```swift
    /// MyItem.identifier(with: "my-id")  // ✅ OK
    /// MyItem.identifier(with: 1)        // 🚫 Error: MyItem's IdentifierType is String.
    /// ```
    ///
    /// You can also read  ``Item.identifier-swift.property`` or ``AnyItem.anyIdentifier-swift.property``
    /// to get the identifier of an item that has been created in a type safe manner.
    ///
    init(_ value : Value)
    {
        super.init(
            type: ObjectIdentifier(Represented.self),
            value: AnyHashable(value)
        )
    }
    
    // MARK: CustomDebugStringConvertible
    
    public override var debugDescription : String {
        "Identifier<\(String(describing: Represented.self)), \(String(describing: Value.self))>: \(self.anyValue.identifierContentString)"
    }
}


///
/// A type-erased `Identifier` used to identify content in a list.
///
/// Even though type-erased, the original `Represented` type from the `Identifier`
/// is still retained when being type erased, meaning comparing two `AnyIdentifiers`
/// with the same `value` but different `Represented` types will report `false`:
/// ```swift
/// let first = Identifier<MyThing, String>("value") as AnyIdentifier
/// let second = Identifier<MyOtherThing, String>("value") as AnyIdentifier
///
/// let equal = first == second // false
/// ```
///
/// **Note** – Like Swift's`KeyPath`, `AnyIdentifier` is the base type for
/// `Identifier<Represented, Value>`. This is done  for performance reasons;
/// it allows free bridging from `Identifier` to `AnyIdentifier`.
///
public class AnyIdentifier : Hashable, CustomDebugStringConvertible
{
    ///
    /// The underlying value that backs the identifier.
    /// For example, if you create an identifier using:
    /// ```swift
    /// Identifier<MyThing, String>("1")
    /// ```
    /// Then the value of `anyValue` will be `AnyHashable("1")`.
    ///
    /// To directly read the value, access `anyValue.base`.
    ///
    public let anyValue : AnyHashable
    
    ///
    /// The underlying type that backs the identifier.
    /// For example, if you create an identifier using:
    /// ```swift
    /// Identifier<MyThing, String>("1")
    /// ```
    /// Then the value of `representedType` will be `ObjectIdentifier(MyThing.self)`.
    ///
    public let representedType : ObjectIdentifier
    
    private let hash : Int
    
    fileprivate init(type : ObjectIdentifier, value : AnyHashable)
    {
        self.representedType = type
        self.anyValue = value
        
        var hasher = Hasher()
        hasher.combine(self.representedType)
        hasher.combine(self.anyValue)
        self.hash = hasher.finalize()
    }
    
    // MARK: Equatable
    
    public static func == (lhs: AnyIdentifier, rhs: AnyIdentifier) -> Bool
    {
        return lhs.hash == rhs.hash && lhs.representedType == rhs.representedType && lhs.anyValue == rhs.anyValue
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

