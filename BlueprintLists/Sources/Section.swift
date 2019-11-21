//
//  Section.swift
//  BlueprintLists
//
//  Created by Kyle Van Essen on 11/20/19.
//

import Listable


//
// MARK: Building Content
//


public extension Section
{
    //
    // MARK: Adding Items
    //
    
    static func += <Element:BlueprintItemElement>(lhs : inout Section, rhs : Element)
    {
        lhs += Item(with: rhs)
    }
    
    static func += <Element:BlueprintItemElement>(lhs : inout Section, rhs : [Element])
    {
        lhs.items += rhs.map { Item(with: $0) }
    }
}
