//
//  Behavior.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/13/19.
//

import Foundation


public struct Behavior : Equatable
{
    public var dismissesKeyboardOnScroll : Bool
    
    public init(dismissesKeyboardOnScroll : Bool = false)
    {
        self.dismissesKeyboardOnScroll = dismissesKeyboardOnScroll
    }
}
