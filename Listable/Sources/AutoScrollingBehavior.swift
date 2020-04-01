//
//  AutoScrollingBehavior.swift
//  Listable
//
//  Created by Kyle Bashour on 3/30/20.
//

import Foundation


public enum AutoScrollingBehavior : Equatable
{
    /// The list never automatically scrolls.
    case none

    /// Scrolls to the bottom when a new item is inserted at the bottom of the list.
    case scrollToBottomForNewItems
}
