//
//  ListDescription.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/9/19.
//

import Foundation


public struct ListDescription
{
    public var animatesChanges : Bool

    public var layoutType : ListLayoutType
    public var appearance : Appearance
    
    public var behavior : Behavior
    public var autoScrollAction : AutoScrollAction
    public var scrollInsets : ScrollInsets
    
    public var accessibilityIdentifier: String?
    
    public var content : Content

    public typealias Build = (inout ListDescription) -> ()
    
    public init(
        animatesChanges: Bool,
        layoutType : ListLayoutType,
        appearance : Appearance,
        behavior : Behavior,
        autoScrollAction : AutoScrollAction,
        scrollInsets : ScrollInsets,
        accessibilityIdentifier: String?,
        build : Build
    )
    {
        self.animatesChanges = animatesChanges
        
        self.layoutType = layoutType
        self.appearance = appearance
        self.behavior = behavior
        self.autoScrollAction = autoScrollAction
        self.scrollInsets = scrollInsets
        self.accessibilityIdentifier = accessibilityIdentifier
        
        self.content = Content()

        build(&self)
    }
    
    public mutating func add(_ section : Section)
    {
        self.content.sections.append(section)
    }
    
    public static func += (lhs : inout ListDescription, rhs : Section)
    {
        lhs.add(rhs)
    }
    
    public static func += (lhs : inout ListDescription, rhs : [Section])
    {
        lhs.content.sections += rhs
    }
}

