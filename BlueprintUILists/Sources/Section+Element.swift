//
//  Section+Element.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 7/24/22.
//

import BlueprintUI
import ListableUI


extension Section {
    
    /// Adds `Element` support when building a `Section`:
    ///
    /// ```swift
    /// Section("id") { section in
    ///     section.add(Element1())
    ///     section.add(Element2())
    /// }
    /// ```
    public mutating func add(_ item : Element)
    {
        self.items.append(item.toAnyItemConvertible().toAnyItem())
    }
    
    /// ```swift
    /// Section("id") { section in
    ///     section += Element1()
    ///     section += Element2()
    /// }
    /// ```
    public static func += (lhs : inout Section, rhs : Element)
    {
        lhs.add(rhs)
    }
    
    /// Adds `Element` support when building a `Section`:
    ///
    /// ```swift
    /// Section("3") { section in
    ///     section.add {
    ///         TestContent1() // An ItemContent
    ///
    ///         Element1() // A Element
    ///         Element2() // A Element
    ///     }
    /// }
    /// ```
    public mutating func add(
        @ListableBuilder<Element> items : () -> [Element]
    ) {
        self.items += items().map { $0.toAnyItemConvertible().toAnyItem() }
    }
}
