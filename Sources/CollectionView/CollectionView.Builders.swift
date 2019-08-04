//
//  CollectionView.Builders.swift
//  Listable
//
//  Created by Kyle Van Essen on 7/8/19.
//

import Foundation

public extension CollectionView
{
    struct ContentBuilder<Layout:CollectionViewLayout>
    {
        public let layout : Layout
        
        public var sections : [CollectionView.Section]
        
        public var isEmpty : Bool {
            for section in self.sections {
                if section.items.count > 0 {
                    return false
                }
            }
            
            return true
        }
        
        public init(layout : Layout)
        {
            self.layout = layout
            
            self.sections = []
        }

        public var content : CollectionView.Content {
            return CollectionView.Content(sections: self.sections)
        }
        
        public mutating func removeEmpty()
        {
            self.sections.removeAll {
                $0.items.count == 0
            }
        }
        
        //
        // Single Sections
        //
        
        // Adds the given section to the builder.
        public static func += (lhs : inout ContentBuilder, rhs : CollectionView.Section)
        {
            lhs.sections.append(rhs)
        }
        
        //
        // Arrays of Sections
        //
        
        public static func += (lhs : inout ContentBuilder, rhs : [CollectionView.Section])
        {
            lhs.sections += rhs
        }
    }
    
    struct SectionBuilder<Layout:CollectionViewLayout>
    {
        public let layout : Layout
        
        public var items : [CollectionViewItem]
    
        public var isEmpty : Bool {
            return self.items.count == 0
        }
        
        public init(layout : Layout)
        {
            self.layout = layout
            
            self.items = []
        }
        
        //
        // Single Rows
        //
        
        // Adds the given row to the builder.
        public static func += <Element:CollectionViewCellElement>(lhs : inout SectionBuilder, rhs : CollectionView.Item<Element, Layout.ItemSizing>)
        {
            lhs.items.append(rhs)
        }
        
        // Converts `Element` which conforms to `TableViewElement` into Rows.
        public static func += <Element:CollectionViewCellElement>(lhs : inout SectionBuilder, rhs : Element)
        {
            let item = CollectionView.Item(rhs, sizing: Layout.ItemSizing.defaultSize)
            
            lhs.items.append(item)
        }
        
        //
        // Arrays of Rows
        //
        
        // Allows mixed arrays of different types of rows.
        public static func += (lhs : inout SectionBuilder, rhs : [CollectionViewItem])
        {
            lhs.items += rhs
        }
        
        // Arrays of the same type of rows – allows `[.init(...)]` syntax within the array.
        public static func += <Element:CollectionViewCellElement>(lhs : inout SectionBuilder, rhs : [CollectionView.Item<Element, Layout.ItemSizing>])
        {
            lhs.items += rhs
        }
        
        // Converts `Element` which conforms to `TableViewRowValue` into Rows.
        public static func += <Element:CollectionViewCellElement>(lhs : inout SectionBuilder, rhs : [Element])
        {
            let items = rhs.map {
                CollectionView.Item($0, sizing: Layout.ItemSizing.defaultSize)
            }
            
            lhs.items += items
        }
    }
}
