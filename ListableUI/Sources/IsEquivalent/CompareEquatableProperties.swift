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
public func isEqualComparingEquatableProperties(_ lhs : Any, _ rhs : Any) -> Bool {
    
    guard type(of: lhs) == type(of: rhs) else {
        return false
    }
    
    let lhs = Mirror(reflecting: lhs)
    
    guard lhs.children.isEmpty == false else {
        return true
    }
    
    let rhs = Mirror(reflecting: rhs)
    
    for (prop1, prop2) in zip(lhs.children, rhs.children) {
        
        guard isEquatableValue(prop1.value) else {
            continue
        }
        
        guard isEqual(prop1.value, prop2.value) else {
            return false
        }
    }
    
    
    
    return true
}


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
