//
//  TableColumnGroup.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/24/21.
//

import Foundation


public struct TableColumnGroup : AnyItemConvertible {
    
    public var columns : Int
    public var spacing : CGFloat
    public var width : CustomWidth
    
    public var items : [AnyItem]
    
    private static var currentGroupingIdentifier : UInt = 0
    private static var isInTableColumnGroup : Bool = false
    
    public init(
        columns : Int,
        spacing : CGFloat = 0.0,
        width : CustomWidth,
        @ListableBuilder<AnyItemConvertible> items : () -> [AnyItemConvertible]
    ) {
        Self.isInTableColumnGroup = true
        defer { Self.isInTableColumnGroup = false }
        
        precondition(
            Self.isInTableColumnGroup == false,
            "TableColumnGroups cannot be nested."
        )
        
        let groupingIdentifier = Self.currentGroupingIdentifier
        Self.currentGroupingIdentifier += 1
        
        self.columns = columns
        self.spacing = spacing
        self.width = width
        
        self.items = items().flattenToAnyItems()
        
        self.items.mutateEach { item in
            item.layouts.table.width = .default
            item.layouts.table.columnGroupingIdentifier = groupingIdentifier
        }
    }
    
    // MARK: AnyItemConvertible

    public func toAnyItem() -> [AnyItem] {
        items
    }
}
