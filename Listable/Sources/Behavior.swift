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
    public var pinItemsToBottom : Bool
    
    public init(
        dismissesKeyboardOnScroll : Bool = false,
        pinItemsToBottom : Bool = false
    )
    {
        self.dismissesKeyboardOnScroll = dismissesKeyboardOnScroll
        self.pinItemsToBottom = pinItemsToBottom
    }
}
