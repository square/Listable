//
//  ListDescription.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/9/19.
//

import Foundation


public struct ListDescription
{
    public var animated : Bool
    
    public var appearance : Appearance
    public var content : Content
    public var scrollInsets : ScrollInsets

    public typealias Build = (inout ListDescription) -> ()
    
    public init(build : Build)
    {
        self.animated = true
        
        self.appearance = Appearance()
        self.content = Content()
        self.scrollInsets = ScrollInsets(top: nil, bottom: nil)

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


public struct ScrollInsets : Equatable
{
    public var top: CGFloat?
    public var bottom: CGFloat?

    public init(top: CGFloat? = nil, bottom: CGFloat? = nil)
    {
        self.top = top
        self.bottom = bottom
    }
    
    func insets(with insets : UIEdgeInsets, layoutDirection : LayoutDirection) -> UIEdgeInsets
    {
        var insets = insets
        
        switch layoutDirection {
        case .vertical:
            insets.top = self.top ?? insets.top
            insets.bottom = self.bottom ?? insets.bottom
            
        case .horizontal:
            insets.left = self.top ?? insets.left
            insets.right = self.bottom ?? insets.right
        }
        
        return insets
    }
}
