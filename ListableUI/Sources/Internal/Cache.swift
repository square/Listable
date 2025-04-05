//
//  Cache.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 4/5/25.
//

import Foundation


final class Cache<Key:Hashable, Value> {
    
    private var values : [Key:Value] = [:]
    
    func clear() {
        values.removeAll()
    }
    
    func get(_ key:Key, create : () -> Value) -> Value {
        
        if let value = values[key] {
            return value
        } else {
            let value = create()
            values[key] = value
            return value
        }
    }
}
