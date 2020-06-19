//
//  ListDescription.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/9/19.
//

import Foundation


public struct ListProperties
{
    public var animatesChanges : Bool

    public var layout : LayoutDescription
    public var appearance : Appearance
    
    public var behavior : Behavior
    public var autoScrollAction : AutoScrollAction
    public var scrollInsets : ScrollInsets
    
    public var accessibilityIdentifier: String?
    
    public var debuggingIdentifier: String?
    
    public var content : Content

    public typealias Build = (inout ListProperties) -> ()
    
    public init(
        animatesChanges: Bool,
        layout : LayoutDescription,
        appearance : Appearance,
        behavior : Behavior,
        autoScrollAction : AutoScrollAction,
        scrollInsets : ScrollInsets,
        accessibilityIdentifier: String?,
        debuggingIdentifier: String?,
        build : Build
    )
    {
        self.animatesChanges = animatesChanges
        
        self.layout = layout
        self.appearance = appearance
        
        self.behavior = behavior
        
        self.autoScrollAction = autoScrollAction
        self.scrollInsets = scrollInsets
        self.accessibilityIdentifier = accessibilityIdentifier
        self.debuggingIdentifier = debuggingIdentifier
        
        self.content = Content()

        build(&self)
    }
    
    public mutating func add(_ section : Section)
    {
        self.content.sections.append(section)
    }
    
    public static func += (lhs : inout ListProperties, rhs : Section)
    {
        lhs.add(rhs)
    }
    
    public static func += (lhs : inout ListProperties, rhs : [Section])
    {
        lhs.content.sections += rhs
    }
}

