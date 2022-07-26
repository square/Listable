//
//  Section+Element.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 7/24/22.
//

import BlueprintUI
import ListableUI


extension Section {
    
    /// Adds `Element` support when building a `Section`.
    ///
    /// ```swift
    /// Section("id") { section in
    ///     section.add(Element1())
    ///     section.add(Element2())
    /// }
    /// ```
    public mutating func add<ElementType:Element>(_ element : ElementType)
    {
        self.items.append(element.item())
    }
    
    public mutating func add<ElementType:Element>(_ element : ElementType) where ElementType:Equatable
    {
        self.items.append(element.item())
    }
    
    public mutating func add<ElementType:Element>(_ element : ElementType) where ElementType:IsEquivalentContent
    {
        self.items.append(element.item())
    }
    
    /// Adds `Element` support when building a `Section`.
    ///
    /// ```swift
    /// Section("id") { section in
    ///     section += Element1()
    ///     section += Element2()
    /// }
    /// ```
    public static func += <ElementType:Element>(lhs : inout Section, rhs : ElementType)
    {
        lhs.add(rhs)
    }
    
    public static func += <ElementType:Element>(lhs : inout Section, rhs : ElementType) where ElementType:Equatable
    {
        lhs.add(rhs)
    }
    
    public static func += <ElementType:Element>(lhs : inout Section, rhs : ElementType) where ElementType:IsEquivalentContent
    {
        lhs.add(rhs)
    }
}
