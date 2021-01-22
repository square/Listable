//
//  Item+Callbacks.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 12/14/20.
//

import Foundation


public extension Item
{
    /// Value passed to the `onDisplay` callback for `Item`.
    struct OnDisplay
    {
        public typealias Callback = (OnDisplay) -> ()

        public var item : Item
        
        public var isFirstDisplay : Bool
    }
    
    /// Value passed to the `onEndDisplay` callback for `Item`.
    struct OnEndDisplay
    {
        public typealias Callback = (OnEndDisplay) -> ()

        public var item : Item
        
        public var isFirstEndDisplay : Bool
    }
    
    /// Value passed to the `onSelect` callback for `Item`.
    struct OnSelect
    {
        public typealias Callback = (OnSelect) -> ()
        
        public var item : Item
    }
    
    /// Value passed to the `onDeselect` callback for `Item`.
    struct OnDeselect
    {
        public typealias Callback = (OnDeselect) -> ()

        public var item : Item
    }
    
    struct OnInsert
    {
        public typealias Callback = (OnInsert) -> ()
        
        public var item : Item
    }
    
    struct OnRemove
    {
        public typealias Callback = (OnRemove) -> ()
        
        public var item : Item
    }
    
    struct OnMove
    {
        public typealias Callback = (OnMove) -> ()
        
        public var old : Item
        public var new : Item
    }
    
    struct OnUpdate
    {
        public typealias Callback = (OnUpdate) -> ()
        
        public var old : Item
        public var new : Item
    }
}
