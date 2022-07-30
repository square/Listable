//
//  CompareProperties.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 7/28/22.
//

import Foundation


/// Checks if the `Equatable` properies on two objects are equal, even if the object itself is not `Equatable`.
///
/// ## Example
/// For the following struct, the `title`, `detail` and `count` properties will be compared. The
/// `closure` will be ignored, and the properties of `nonEquatable` will be traversed to look
/// for `Equatable` sub-properties (and so on).
///
/// ```
/// fileprivate struct MyStruct {
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
/// Inspired by https://github.com/objcio/S01E264-comparing-views/blob/master/Sources/NotSwiftUIState/AnyEquatable.swift
///
@_spi(ListableInternal)
public func areEquatablePropertiesEqual(_ lhs : Any, _ rhs : Any) -> AreEquatablePropertiesEqualResult {
    
    // We can't compare values unless the objects are the same type.
    
    guard type(of: lhs) == type(of: rhs) else {
        return .notEqual
    }
    
    // Shortcut: For `Equatable` objects, compare them directly,
    // no need to create a mirror and enumerate the properties.
    
    if isEquatableValue(lhs) {
        return .with(isEqual(lhs, rhs))
    }
    
    let lhs = Mirror(reflecting: lhs)
    
    // Values with no fields are technically always equal, but
    // we mark it with a special value for recursing through value trees.
    
    guard lhs.children.isEmpty == false else {
        return .hasNoFields
    }
    
    let rhs = Mirror(reflecting: rhs)
    
    // Enumerate each property by enumerating the value's `Mirror`.
    
    var hadEquatableProperty = false
    
    for (prop1, prop2) in zip(lhs.children, rhs.children) {
                
        if let result = isEqualIfEquatable(prop1.value, prop2.value) {
            
            // If a property is `Equatable`, we can directly check it here.
        
            hadEquatableProperty = true

            if result == false {
                return .notEqual
            }
        } else {
            
            // Othewise, we will recursively check its child values.
            
            let result = areEquatablePropertiesEqual(prop1.value, prop2.value)
            
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
        // We made it through the entire list of properties, and found at least
        // one `Equatable` property, so we are equal.
        return .equal
    } else {
        // We found no `Equatable` properties – behavior is undefined.
        return .error(.noEquatableProperties)
    }
}


@_spi(ListableInternal)
public enum AreEquatablePropertiesEqualResult : Equatable {

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
    
    func check<Value>(value: Value) -> Bool {
        if let typeInfo = Wrapped<Value>.self as? AnyEquatable.Type {
            return typeInfo.isEqual(lhs: lhs, rhs: rhs)
        } else {
            return false
        }
    }
    
    /// This is the magic part of the whole process. Through `_openExistential`,
    /// Swift will take the `Any` type (the existential type), and call the provided `body`
    /// with the existential converted to the contained type. Because we have no constraint
    /// on the contained type (just a `Value` generic), we can then check if the contained type
    /// will conform to `AnyEquatable`.
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
}


/// Checks if the provided `value` is `Equatable`.
private func isEquatableValue(_ value: Any) -> Bool {
    
    func check<Value>(value: Value) -> Bool {
        Wrapped<Value>.self is AnyEquatable.Type
    }
    
    return _openExistential(value, do: check)
}


/// Checks if the provided `lhs` and `rhs` values are equal if they are `Equatable`.
private func isEqualIfEquatable(_ lhs: Any, _ rhs : Any) -> Bool? {
    
    func check<Value>(value: Value) -> Bool? {
        if let typeInfo = Wrapped<Value>.self as? AnyEquatable.Type {
            return typeInfo.isEqual(lhs: lhs, rhs: rhs)
        } else {
            return nil
        }
    }
    
    return _openExistential(lhs, do: check)
}


fileprivate enum Wrapped<Value> {}


extension Wrapped: AnyEquatable where Value: Equatable {
    
    fileprivate static func isEqual(lhs: Any, rhs: Any) -> Bool {
        
        guard let lhs = lhs as? Value, let rhs = rhs as? Value else {
            return false
        }
        
        return lhs == rhs
    }
}


private protocol AnyEquatable {
    static func isEqual(lhs: Any, rhs: Any) -> Bool
}



infix operator ||=

extension Bool {
    
    fileprivate static func ||= (lhs : inout Bool, rhs : Bool) {
        lhs = lhs || rhs
    }
}
