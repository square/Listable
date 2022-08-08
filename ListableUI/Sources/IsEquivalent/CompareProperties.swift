//
//  CompareProperties.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 7/28/22.
//

import Foundation


/// Checks if the `Equatable` properies on two values are equal, even if the value itself
/// is not `Equatable`. If the value is `Equatable`, its `Equatable` implementation is invoked.
///
/// ## Example
/// For the following struct, the `title`, `detail` and `count` properties will be compared. The
/// `closure` will be ignored (since it's not `Equatable)`, and the properties of `nonEquatable`
/// will be recursively traversed to look for `Equatable` sub-properties (and so on).
///
/// ```
/// struct MyStruct {
///
///     var title : String
///     var detail : String?
///     var count : Int
///
///     var nonEquatable: NonEquatableValue
///
///     var closure : () -> ()
/// }
/// ```
///
/// ## Note
/// This method is used to power the default ``EquivalentComparable/isEquivalent(to:)-7meyq`` implementation.
///
/// ## Thank You / Credit
/// Inspired by the folks at objc.io, and in particular thanks to @chriseidhof!
///
/// https://talk.objc.io/episodes/S01E264-comparing-views
/// https://twitter.com/chriseidhof/status/1552612392789499905
/// https://github.com/objcio/S01E264-comparing-views/blob/master/Sources/NotSwiftUIState/IsEquatableType.swift
///
@_spi(ListableInternal)
public func compareEquatableProperties(_ lhs : Any, _ rhs : Any) -> CompareEquatablePropertiesResult {
    
    /// We can't compare values unless they are the same type.
    
    guard type(of: lhs) == type(of: rhs) else {
        return .notEqual
    }
    
    /// Base case: For `Equatable` objects, compare them directly,
    /// no need to create a mirror and enumerate the properties.
    
    if let isEqual = isEqualIfEquatable(lhs, rhs) {
        return .with(isEqual)
    }
    
    /// Base case: For collections, we need to handle them differently, because
    /// some collections like `Set` or `Dictionary` will not
    /// return `Mirror.children` in a stable order.
    
    if let isEqual = compareContentsIfSameTypeCollections(lhs, rhs) {
        return .with(isEqual)
    }
    
    let lhsMirror = Mirror(reflecting: lhs)
    
    guard lhsMirror.children.isEmpty == false else {
        
        /// Values with no fields are technically always equal, but
        /// we mark it with a special value for recursing through value trees
        /// and eventually returning an error.
        
        return .hasNoFields
    }
    
    let rhsMirror = Mirror(reflecting: rhs)
        
    /// Values with different child counts are not equal. This can happen
    /// if the value type is providing its own mirror via `CustomReflectable`,
    /// which Swift collections (like Array, Set, Dictionary) do.
    
    guard lhsMirror.children.count == rhsMirror.children.count else {
        return .notEqual
    }
    
    /// Enumerate each property by enumerating the value's `Mirror`.
    
    var hadEquatableProperty = false
    
    for (prop1, prop2) in zip(lhsMirror.children, rhsMirror.children) {
                
        /// 1) Check if the property is directly `Equatable` itself.
        /// 2) If it's a `Collection`, we'll check the contents.
        /// 3) If neither of those are true, recursively check children.
        
        if let result = isEqualIfEquatable(prop1.value, prop2.value) {
            
            /// If a property is `Equatable`, we can directly check it here.
        
            hadEquatableProperty = true

            if result == false {
                return .notEqual
            }
        } else if let result = compareContentsIfSameTypeCollections(prop1.value, prop2.value) {
            
            /// If the properties were both collections,
            /// and are the same type, they may be Equal.
        
            hadEquatableProperty = true

            if result == false {
                return .notEqual
            }
        } else {
            
            /// Othewise, we will recursively check its child values.
            
            let result = compareEquatableProperties(prop1.value, prop2.value)
            
            switch result {
            case .equal:
                hadEquatableProperty ||= true
                
            case .notEqual:
                hadEquatableProperty ||= true
                return .notEqual
                
            case .hasNoFields:
                hadEquatableProperty ||= false
                
            case .error:
                hadEquatableProperty ||= false
            }
        }
    }
        
    if hadEquatableProperty {
        /// We made it through the entire list of properties, and found at least
        /// one `Equatable` property, so we are equal.
        return .equal
    } else {
        
        let hasChildren = lhsMirror.children.count > 0

        if hasChildren {
            
            /// We found no `Equatable` properties, but we did
            /// have _some_ children, which our display state is likely
            /// derived from (eg, closures or something). Report an error
            /// and make the consumer implement `isEquivalent(to:)` themselves.
            
            return .error(.noEquatableProperties)
        } else {
            
            /// We had no children at all, so we're equal.
            
            return .equal
        }
    }
}


@_spi(ListableInternal)
public enum CompareEquatablePropertiesResult : Equatable {

    case equal
    case notEqual
    case hasNoFields
    case error(Error)
    
    public static func with(_ value: Bool) -> Self {
        value ?.equal : .notEqual
    }
    
    public enum Error {
        case noEquatableProperties
    }
}


/// Checks if the two provided values are the same type and Equatable.
private func isEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    
#if swift(>=5.7)
    if let lhs = lhs as? any Equatable {
        return lhs.isEqual(to: rhs)
    } else {
        return false
    }
#else
    func check<Value>(value: Value) -> Bool {
        if let typeInfo = Wrapped<Value>.self as? IsEquatableType.Type {
            return typeInfo.isEqual(lhs: lhs, rhs: rhs)
        } else {
            return false
        }
    }
    
    /// This is the magic part of the whole process. Through `_openExistential`,
    /// Swift will take the `Any` type (the existential type), and call the provided `body`
    /// with the existential converted to the contained type. Because we have no constraint
    /// on the contained type (just a `Value` generic), we can then check if the contained type
    /// will conform to `IsEquatableType`.
    ///
    /// ```
    /// public func _openExistential<ExistentialType, ContainedType, ResultType>(
    ///   _ existential: ExistentialType,
    ///   do body: (ContainedType) throws -> ResultType
    /// ) rethrows -> ResultType
    /// ```
    ///
    /// https://github.com/apple/swift/blob/main/stdlib/public/core/Builtin.swift#L1005
    
    return _openExistential(lhs, do: check)
#endif
}


/// Checks if the provided `value` is `Equatable`.
private func isEquatableValue(_ value: Any) -> Bool {
    
#if swift(>=5.7)
    return value is any Equatable
#else
    func check<Value>(value: Value) -> Bool {
        Wrapped<Value>.self is IsEquatableType.Type
    }
    
    return _openExistential(value, do: check)
#endif
}


/// Checks if the provided `value` is a `Collection`
private func isACollection(_ value: Any) -> Bool {
    
#if swift(>=5.7)
    return value is any Collection
#else
    func check<Value>(value: Value) -> Bool {
        Wrapped<Value>.self is IsCollectionType.Type
    }
    
    return _openExistential(value, do: check)
#endif
}


/// Checks if the provided `lhs` and `rhs` values are equal if they are `Equatable`.
private func isEqualIfEquatable(_ lhs: Any, _ rhs : Any) -> Bool? {
    
#if swift(>=5.7)
    if let lhs = lhs as? any Equatable {
        return lhs.isEqual(to: rhs)
    } else {
        return nil
    }
#else
    func check<Value>(value: Value) -> Bool? {
        if let typeInfo = Wrapped<Value>.self as? IsEquatableType.Type {
            return typeInfo.isEqual(lhs: lhs, rhs: rhs)
        } else {
            return nil
        }
    }
    
    return _openExistential(lhs, do: check)
#endif
}


/// Checks if the provided `lhs` and `rhs` values are equal if they both the same type of `Collection`.
private func compareContentsIfSameTypeCollections(_ lhs: Any, _ rhs : Any) -> Bool? {
    
    func check<Value>(value: Value) -> Bool? {
        if let typeInfo = Wrapped<Value>.self as? IsCollectionType.Type {
            return typeInfo.compareContents(lhs: lhs, rhs: rhs)
        } else {
            return nil
        }
    }
    
    return _openExistential(lhs, do: check)
}


fileprivate enum Wrapped<Value> {}


#if swift(>=5.7)

extension Equatable {
    
    fileprivate func isEqual(to other: Any) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        
        return self == other
    }
}

#else


private protocol IsEquatableType {
    static func isEqual(lhs: Any, rhs: Any) -> Bool
}


extension Wrapped: IsEquatableType where Value: Equatable {
    
    fileprivate static func isEqual(lhs: Any, rhs: Any) -> Bool {
        
        guard let lhs = lhs as? Value, let rhs = rhs as? Value else {
            return false
        }
        
        return lhs == rhs
    }
}

#endif

private protocol IsCollectionType {
    
    static func compareContents(lhs : Any, rhs : Any) -> Bool
}


extension Wrapped: IsCollectionType where Value: Collection {
    
    static func compareContents(lhs : Any, rhs : Any) -> Bool {
        
        guard let lhs = lhs as? ErasedComparableCollection else {
            return false
        }
        
        return lhs.compareContents(to: rhs)
    }
}

private protocol ErasedComparableCollection {
    
    func compareContents(to other : Any) -> Bool

}


extension Dictionary : ErasedComparableCollection {
    
    fileprivate func compareContents(to other : Any) -> Bool {
        
        guard let other = other as? Self else {
            return false
        }
        
        guard count == other.count else {
            return false
        }
        
        for key in keys {
            let lhs = self[key]
            let rhs = other[key]
            
            guard let lhs = lhs, let rhs = rhs else {
                return false
            }
            
            if compareEquatableProperties(lhs, rhs) != .equal {
                return false
            }
        }
        
        return true
    }
}


extension Set : ErasedComparableCollection {
    
    fileprivate func compareContents(to other : Any) -> Bool {
        
        guard let other = other as? Self else {
            return false
        }
        
        guard count == other.count else {
            return false
        }
        
        for value in self {
            if other.contains(value) == false {
                return false
            }
        }
        
        return true
    }
}

extension Array : ErasedComparableCollection {
    
    fileprivate func compareContents(to other : Any) -> Bool {
        
        guard let other = other as? Self else {
            return false
        }
        
        guard count == other.count else {
            return false
        }
        
        for (index, lhs) in self.enumerated() {
            let rhs = other[index]
            
            if compareEquatableProperties(lhs, rhs) != .equal {
                return false
            }
        }
        
        return true
    }
}


infix operator ||=

fileprivate extension Bool {
    
    static func ||= (lhs : inout Bool, rhs : Bool) {
        lhs = lhs || rhs
    }
}
