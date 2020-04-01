//
//  AutoScrollingBehavior.swift
//  Listable
//
//  Created by Kyle Bashour on 3/30/20.
//

import Foundation


public enum AutoScrollingBehavior
{
    /// The list never automatically scrolls.
    case none

    /// Scrolls to the specified item when the list is updated.
    case scrollToItemOnInsert(_ item: AnyItem, position: ItemScrollPosition)
}
