//
//  ListPagingBehavior.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/29/21.
//

/// Controls how to align / adjust the `contentOffset` of the list when
/// the user finishes a drag action, allowing you to align the end of the
/// scroll event to the first visible item if desired.
public enum ListPagingBehavior: Equatable {
    /// When the user stops scrolling, no paging adjusts will be made, the
    /// scroll event will stop where it regularly would.
    case none

    /// When the user stops scrolling, the final offset of the scroll event
    /// will be adjusted so that the first visible item is fully visible.
    case firstVisibleItemEdge
}
