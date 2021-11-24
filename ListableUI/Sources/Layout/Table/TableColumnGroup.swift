//
//  TableColumnGroup.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/24/21.
//

import Foundation


public struct TableColumnGroup : AnyItemConvertible {
    
    public var items : [AnyItem]
    
    public init(
        @ListableBuilder<AnyItemConvertible> items : () -> [AnyItemConvertible]
    ) {
        self.items = items().flattenToAnyItems()
    }
    
    // MARK: AnyItemConvertible

    public func toAnyItem() -> [AnyItem] {
        items
    }
}
