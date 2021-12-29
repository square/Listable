//
//  Validations.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 12/15/20.
//

import Foundation


/// Validates that the provided object is not a class type.
func assertIsValueType<Value>(_ valueType : Value.Type) {
        
    #if DEBUG
    
    precondition(
        valueType is AnyClass == false,
        {
            let typeName = String(describing: Value.self)
            
            return """
            `\(typeName)` must be a value type to work properly with Listable and value semantics. Instead, it was a class.

            Please convert your `\(typeName)` class from a `class` to a `struct` type.
            """
        }()
    )
    
    #endif
}
