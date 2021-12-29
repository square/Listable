//
//  ListEnvironmentKey.swift
//  ListEnvironmentKey
//
//  Created by Kyle Van Essen on 8/14/21.
//

import Foundation


/// Defines a value stored in the `ListEnvironment` of a list.
///
/// See `ListEnvironment` for more info and examples.
public protocol ListEnvironmentKey {
    
    /// The type of value stored by this key.
    associatedtype Value

    /// The default value that will be vended by an `Environment` for this key if no other value has been set.
    static var defaultValue: Self.Value { get }
}
