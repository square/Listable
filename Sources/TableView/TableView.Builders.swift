//
//  Builders.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/21/19.
//

import Foundation


public extension TableView
{    
    struct ContentBuilder
    {
        public typealias Build = (inout ContentBuilder) -> ()
        
        public static func build(with block : Build) -> Content
        {
            var builder = ContentBuilder()
            block(&builder)
            return builder.content
        }
        
        public var content : TableView.Content {
            return TableView.Content(
                refreshControl: self.refreshControl,
                header: self.header,
                footer: self.footer,
                sections: self.sections
            )
        }
        
        public var refreshControl : RefreshControl?
        
        public var header : TableViewHeaderFooter?
        public var footer : TableViewHeaderFooter?
        
        public var sections : [TableView.Section] = []
        
        public var isEmpty : Bool {
            return self.sections.firstIndex { $0.rows.isEmpty == false } == nil
        }
        
        public mutating func removeEmpty()
        {
            self.sections.removeAll {
                $0.rows.isEmpty
            }
        }

        public static func += (lhs : inout ContentBuilder, rhs : TableView.Section)
        {
            lhs.sections.append(rhs)
        }
        
        public static func += (lhs : inout ContentBuilder, rhs : [TableView.Section])
        {
            lhs.sections += rhs
        }
    }
    
    struct SectionBuilder
    {
        public var rows : [TableViewRow] = []
        
        public var isEmpty : Bool {
            return self.rows.isEmpty
        }
        
        // Adds the given row to the builder.
        public static func += <Element:TableViewRowElement>(lhs : inout SectionBuilder, rhs : TableView.Row<Element>)
        {
            lhs.rows.append(rhs)
        }
        
        // Converts `Element` which conforms to `TableViewElement` into Rows.
        public static func += <Element:TableViewRowElement>(lhs : inout SectionBuilder, rhs : Element)
        {
            let row = TableView.Row(rhs)
            
            lhs.rows.append(row)
        }
        
        // Allows mixed arrays of different types of rows.
        public static func += (lhs : inout SectionBuilder, rhs : [TableViewRow])
        {
            lhs.rows += rhs
        }
        
        // Arrays of the same type of rows – allows `[.init(...)]` syntax within the array.
        public static func += <Element:TableViewRowElement>(lhs : inout SectionBuilder, rhs : [TableView.Row<Element>])
        {
            lhs.rows += rhs
        }
        
        // Converts `Element` which conforms to `TableViewRowValue` into Rows.
        public static func += <Element:TableViewRowElement>(lhs : inout SectionBuilder, rhs : [Element])
        {
            let rows = rhs.map {
                TableView.Row($0)
            }
            
            lhs.rows += rows
        }
    }
}
