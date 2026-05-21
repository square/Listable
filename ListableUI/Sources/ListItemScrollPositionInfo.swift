//
//  ListItemScrollPositionInfo.swift
//  ListableUI
//
//  Created by Square on 5/21/26.
//

import Foundation
import UIKit


/// Returns the vertical delta to apply to the list's current content offset.
public typealias ListItemScrollPositionAdjustment = (ListItemScrollPositionInfo) -> CGFloat

/// Information available when calculating a custom scroll adjustment for an item.
public struct ListItemScrollPositionInfo: Equatable {

    /// The item's frame in the list content coordinate space.
    public let itemFrame: CGRect

    /// The visible content frame in the list content coordinate space.
    public let visibleContentFrame: CGRect

    /// The current scroll position of the list.
    public let positionInfo: ListScrollPositionInfo
}
