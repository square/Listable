//
//  ListItemScrollPositionInfo.swift
//  ListableUI
//
//  Created by Square on 5/21/26.
//

import Foundation
import UIKit


/// Returns the vertical delta to apply to the list's current content offset.
///
/// When this adjustment is stored on an auto-scroll action, avoid strongly capturing
/// an object that owns or configures the list. Capture that object weakly to prevent
/// retain cycles.
public typealias ListItemScrollPositionAdjustment = (ListItemScrollPositionInfo) -> CGFloat

/// Specifies how to position an item in a list when requesting the list scrolls to it.
public struct ListItemScrollPosition {

    enum Storage {
        case standard(ScrollPosition)
        case verticalContentOffsetAdjustment(ListItemScrollPositionAdjustment)
    }

    let storage: Storage

    /// Positions the item using Listable's standard item scroll positioning.
    public static func standard(_ position: ScrollPosition) -> ListItemScrollPosition {
        ListItemScrollPosition(storage: .standard(position))
    }

    /// Positions the item by applying a custom vertical delta to the current content offset.
    ///
    /// The adjustment may be stored by declarative scrolling APIs. If it captures an object
    /// that owns or configures the list, capture that object weakly to prevent retain cycles.
    public static func verticalContentOffsetAdjustment(
        _ adjustment: @escaping ListItemScrollPositionAdjustment
    ) -> ListItemScrollPosition {
        ListItemScrollPosition(storage: .verticalContentOffsetAdjustment(adjustment))
    }
}

/// Information available when calculating a custom scroll adjustment for an item.
public struct ListItemScrollPositionInfo: Equatable {

    /// The item's frame in the list content coordinate space.
    public let itemFrame: CGRect

    /// The visible content frame in the list content coordinate space.
    public let visibleContentFrame: CGRect

    /// The current scroll position of the list.
    public let positionInfo: ListScrollPositionInfo

    public init(
        itemFrame: CGRect,
        visibleContentFrame: CGRect,
        positionInfo: ListScrollPositionInfo
    ) {
        self.itemFrame = itemFrame
        self.visibleContentFrame = visibleContentFrame
        self.positionInfo = positionInfo
    }
}
