//
//  CompareEquatableProperties.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 7/28/22.
//

import Foundation


/// Compares if the `Equatable` properies on two objects are equal, even if the object itself is not `Equatable`.
///
/// ## Example
/// For the following struct, the `title`, `detail` and `count` properties will be compared. The
/// `nonEquatable` and `closure` parameters will be ignored.
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
public func areEquatablePropertiesEqual(_ lhs : Any, _ rhs : Any) -> Bool {
    
    // 1) We can't compare values unless the objects are the same type.
    
    guard type(of: lhs) == type(of: rhs) else {
        return false
    }
    
    let lhs = Mirror(reflecting: lhs)
    
    // 2) Values with no fields are always Equal.
    
    guard lhs.children.isEmpty == false else {
        return true
    }
    
    let rhs = Mirror(reflecting: rhs)
    
    // 3) Enumerate each property, by enumerating the `Mirrors`.
    
    for (prop1, prop2) in zip(lhs.children, rhs.children) {
        
        // 3a) Skip any values which are not themselves `Equatable`.
        
        guard isEquatableValue(prop1.value) else {
            continue
        }
        
        // 3b) Finally, compare the underlying values.
        
        guard isEqual(prop1.value, prop2.value) else {
            return false
        }
    }
    
    // 4) All `Equatable` properties were equal, so we're equal.
    
    return true
}


/// Checks if the two provided values are the same type and Equatable.
private func isEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    
    func check<Value>(value: Value) -> Bool {
        
        if let typeInfo = Wrapped<Value>.self as? AnyEquatable.Type {
            return typeInfo.isEqual(lhs: lhs, rhs: rhs)
        }
        
        return false
    }
    
    /// This is the magic part of the whole process. Through `_openExistential`,
    /// Swift will take the `Any` type (the existential type), and call the provided `body`
    /// with the existential converted to the contained type. Because we have no constraint
    /// on the contained type (just a `LHS` generic), we can then check if the contained type
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


private protocol AnyEquatable {
    static func isEqual(lhs: Any, rhs: Any) -> Bool
}


private enum Wrapped<Value> {}


extension Wrapped: AnyEquatable where Value: Equatable {
    
    static func isEqual(lhs: Any, rhs: Any) -> Bool {
        
        guard let lhs = lhs as? Value, let rhs = rhs as? Value else {
            return false
        }
        
        return lhs == rhs
    }
}
