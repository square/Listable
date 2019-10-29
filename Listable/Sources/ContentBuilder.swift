//
//  Builders.swift
//  Listable
//
//  Created by Kyle Van Essen on 6/21/19.
//

import ListableCore


public struct ContentBuilder
{
    public typealias Build = (inout ContentBuilder) -> ()
    
    public static func build(with block : Build) -> Content
    {
        var builder = ContentBuilder()
        block(&builder)
        return builder.content
    }
    
    public var content : Content {
        return Content(
            selectionMode: self.selectionMode,
            refreshControl: self.refreshControl,
            header: self.header,
            footer: self.footer,
            sections: self.sections
        )
    }
    
    public var selectionMode : Content.SelectionMode = .single
        
    public var refreshControl : RefreshControl?
    
    public var header : AnyHeaderFooter?
    public var footer : AnyHeaderFooter?
    
    public var sections : [Section] = []
    
    public var isEmpty : Bool {
        return self.sections.firstIndex { $0.items.isEmpty == false } == nil
    }
    
    public mutating func removeEmpty()
    {
        self.sections.removeAll {
            $0.items.isEmpty
        }
    }
    
    public static func += (lhs : inout ContentBuilder, rhs : Section)
    {
        lhs.sections.append(rhs)
    }
    
    public static func += (lhs : inout ContentBuilder, rhs : [Section])
    {
        lhs.sections += rhs
    }
}

public struct SectionBuilder
{
    public var items : [AnyItem] = []
    
    public var isEmpty : Bool {
        return self.items.isEmpty
    }
    
    // Adds the given item to the builder.
    public static func += <Element:ItemElement>(lhs : inout SectionBuilder, rhs : Item<Element>)
    {
        lhs.items.append(rhs)
    }
    
    // Allows mixed arrays of different types of items.
    public static func += (lhs : inout SectionBuilder, rhs : [AnyItem])
    {
        lhs.items += rhs
    }
    
    // Arrays of the same type of items – allows `[.init(...)]` syntax within the array.
    public static func += <Element:ItemElement>(lhs : inout SectionBuilder, rhs : [Item<Element>])
    {
        lhs.items += rhs
    }
}
