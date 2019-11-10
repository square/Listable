//
//  ListDescription.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/9/19.
//

import Foundation


public struct ListDescription
{
    public var appearance : Appearance
    public var content : Content

    public typealias Build = (inout ListDescription) -> ()
    
    public init(appearance : Appearance = Appearance(), build : Build)
    {
        self.appearance = appearance
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
