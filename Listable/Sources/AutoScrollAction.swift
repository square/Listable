//
//  AutoScrollAction.swift
//  Listable
//
//  Created by Kyle Bashour on 3/30/20.
//

import Foundation


public enum AutoScrollAction
{
    /// The list never automatically scrolls.
    case none

    /// Scrolls to the specified item when the list is updated if the item was inserted in this update.
    case scrollToItemOnInsert(_ item: AnyItem, position: ItemScrollPosition, animated: Bool)
}
