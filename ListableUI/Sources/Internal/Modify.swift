//
//  Init.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 10/21/20.
//

import Foundation

func modified<Value>(_ initial: Value, _ modify: (inout Value) -> Void) -> Value {
    var copy = initial
    modify(&copy)
    return copy
}
