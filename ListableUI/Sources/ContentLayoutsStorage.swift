//
//  ContentLayoutsStorage.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 1/22/21.
//

import Foundation

///
/// Underlying storage used in `ItemLayouts`, `HeaderFooterLayouts`, and `SectionLayouts`.
/// See those types for more information.
///
struct ContentLayoutsStorage {
    private var storage: [ObjectIdentifier: Any] = [:]

    func get<ValueType>(
        _ valueType: ValueType.Type,
        default defaultValue: @autoclosure () -> ValueType
    ) -> ValueType {
        let ID = ObjectIdentifier(valueType)

        if let anyValue = storage[ID] {
            return anyValue as! ValueType
        } else {
            return defaultValue()
        }
    }

    mutating func set<ValueType>(
        _ valueType: ValueType.Type,
        new newValue: ValueType
    ) {
        storage[ObjectIdentifier(valueType)] = newValue
    }
}
