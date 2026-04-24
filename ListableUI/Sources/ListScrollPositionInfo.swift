//
//  ListScrollPositionInfo.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/4/20.
//

import Foundation
import UIKit

/// Information about the current scroll position of a list,
/// including which edges of the list are visible, and which items are visible.
///
/// This is useful within callback APIs where you as a developer may want to
/// perform different behavior based on the position of the list, eg, do you
/// want to allow an auto-scroll action, etc.
public struct ListScrollPositionInfo: Equatable {
    //

    // MARK: Public

    //

    /// Which items within the list are currently visible.
    public var visibleItems: Set<VisibleItem>

    /// The item from `visibleItems` that has the highest percentage of visibility.
    public var mostVisibleItem: VisibleItem? {
        visibleItems.reduce(into: VisibleItem?.none) { mostVisibleItem, next in
            if next.percentageVisible > (mostVisibleItem?.percentageVisible ?? 0) {
                mostVisibleItem = next
            }
        }
    }

    /// If the first item list is partially visible.
    public var isFirstItemVisible: Bool

    /// If the last item list is partially visible.
    public var isLastItemVisible: Bool

    /// Distance required to scroll to the bottom
    public var bottomScrollOffset: CGFloat

    /// `bounds` of the list view
    public var bounds: CGRect

    /// `safeAreaInsests` of the list view
    public var safeAreaInsets: UIEdgeInsets

    /// `contentSize` of the list view
    public var contentSize: CGSize {
        scrollViewState.contentSize
    }

    ///
    /// Used to retrieve the visible content edges for the list's content.
    ///
    /// Eg, for vertical lists:
    /// - If the list is scrolled all the way to the bottom, the visible edges are the left, right, and bottom.
    /// - If the list is scrolled all the way to the top, the visible edges are the left, right, and top.
    ///
    /// You can use this method to determine how and where the list is scrolled if you want to modify
    /// behavior based on the current scroll position.
    ///
    /// Examples
    /// ---------
    /// ```
    /// +---------------+   +---------------+      +-----------------+    +--------------------+
    /// |all            |   |top, left      |      |top, left, right |    |left, right, bottom |
    /// +---------------+   +---------------+      +-----------------+    +--------------------+
    /// List                List                   List
    /// +---------------+   +---------------+      +---------------+      +---------------+
    /// |               |   |               |      |               |      |Content@@@@@@@@|
    /// | +-----------+ |   | +-------------+-+    |               |      |@@@@@@@@@@@@@@@|
    /// | |Content@@@@| |   | |Content@@@@@@|@|    |               |      List@@@@@@@@@@@@|
    /// | |@@@@@@@@@@@| |   | |@@@@@@@@@@@@@|@|    +---------------+      +---------------+
    /// | |@@@@@@@@@@@| |   | |@@@@@@@@@@@@@|@|    |Content@@@@@@@@|      |@@@@@@@@@@@@@@@|
    /// | |@@@@@@@@@@@| |   | |@@@@@@@@@@@@@|@|    |@@@@@@@@@@@@@@@|      |@@@@@@@@@@@@@@@|
    /// | |@@@@@@@@@@@| |   | |@@@@@@@@@@@@@|@|    |@@@@@@@@@@@@@@@|      |@@@@@@@@@@@@@@@|
    /// | |@@@@@@@@@@@| |   | |@@@@@@@@@@@@@|@|    |@@@@@@@@@@@@@@@|      |@@@@@@@@@@@@@@@|
    /// | |@@@@@@@@@@@| |   | |@@@@@@@@@@@@@|@|    |@@@@@@@@@@@@@@@|      |@@@@@@@@@@@@@@@|
    /// | |@@@@@@@@@@@| |   | |@@@@@@@@@@@@@|@|    |@@@@@@@@@@@@@@@|      |@@@@@@@@@@@@@@@|
    /// | +-----------+ |   | |@@@@@@@@@@@@@|@|    |@@@@@@@@@@@@@@@|      |@@@@@@@@@@@@@@@|
    /// +---------------+   +-+-------------+@|    +---------------+      +---------------+
    ///                       |@@@@@@@@@@@@@@@|    |@@@@@@@@@@@@@@@|      |               |
    ///                       +---------------+    |@@@@@@@@@@@@@@@|      |               |
    ///                                            |@@@@@@@@@@@@@@@|      |               |
    ///                                            +---------------+      +---------------+
    /// ```
    /// Safe Area Insets
    /// -----------------
    /// You can control whether `safeAreaInsets` should be taken into account via the `includingSafeAreaEdges` parameter.
    ///
    /// Generally, you want to include the `safeAreaInsets` for the top, left, and right, but may want to exclude the bottom
    /// if you consider the bottom edge visible if it's visible below the home indicator on a home button-less iPhone or iPad.
    ///
    public func visibleContentEdges(includingSafeAreaEdges safeAreaEdges: UIRectEdge = .all) -> UIRectEdge
    {
        let safeArea = scrollViewState.safeAreaInsets.masked(by: safeAreaEdges)

        return UIRectEdge.visibleScrollViewContentEdges(
            bounds: scrollViewState.bounds,
            contentSize: scrollViewState.contentSize,
            safeAreaInsets: safeArea
        )
    }

    /// Controls how close to the bottom edge of a list a user must scroll before the
    /// list is considered to be approaching the bottom.
    public enum BottomThreshold: Equatable {
        /// The list is approaching the bottom once the final rendered item is visible.
        case lastItem

        /// The list is approaching the bottom once the remaining vertical scroll distance
        /// is less than or equal to the provided number of points.
        case offset(CGFloat)

        /// The list is approaching the bottom once the remaining vertical scroll distance
        /// is less than or equal to the provided number of visible viewport heights.
        case screens(CGFloat)
    }

    /// Returns whether the list is approaching the bottom for a given threshold.
    public func isApproachingBottom(within threshold: BottomThreshold) -> Bool {
        switch threshold {
        case .lastItem:
            return isLastItemVisible

        case let .offset(offset):
            return bottomScrollOffset <= max(offset, 0.0)

        case let .screens(screens):
            let visibleHeight = max(bounds.height - safeAreaInsets.top - safeAreaInsets.bottom, 0.0)
            let screenHeight = visibleHeight > 0.0 ? visibleHeight : bounds.height
            return bottomScrollOffset <= screenHeight * max(screens, 0.0)
        }
    }

    //

    // MARK: Private

    //

    private let scrollViewState: ScrollViewState

    /// Creates a `ListScrollPositionInfo` for the provided scroll view.
    public init(
        scrollView: UIScrollView,
        visibleItems: Set<VisibleItem>,
        isFirstItemVisible: Bool,
        isLastItemVisible: Bool
    ) {
        scrollViewState = ScrollViewState(
            bounds: scrollView.bounds,
            contentSize: scrollView.contentSize,
            safeAreaInsets: scrollView.safeAreaInsets
        )

        self.visibleItems = visibleItems

        self.isFirstItemVisible = isFirstItemVisible
        self.isLastItemVisible = isLastItemVisible

        bottomScrollOffset = scrollView.contentSize.height - scrollView.bounds.size.height - scrollView.contentOffset.y + scrollView.adjustedContentInset.bottom

        bounds = scrollView.bounds
        safeAreaInsets = scrollView.safeAreaInsets
    }

    struct ScrollViewState: Equatable {
        var bounds: CGRect
        var contentSize: CGSize
        var safeAreaInsets: UIEdgeInsets
    }

    public struct VisibleItem: Hashable {
        public let identifier: AnyIdentifier

        /// The percentage of this item within the collection view's visible frame.
        public let percentageVisible: CGFloat
    }
}

extension UIEdgeInsets {
    func masked(by edges: UIRectEdge) -> UIEdgeInsets {
        var insets = UIEdgeInsets()

        if edges.contains(.top) {
            insets.top = top
        }

        if edges.contains(.left) {
            insets.left = left
        }

        if edges.contains(.bottom) {
            insets.bottom = bottom
        }

        if edges.contains(.right) {
            insets.right = right
        }

        return insets
    }
}

extension UIRectEdge: CustomDebugStringConvertible {
    static func visibleScrollViewContentEdges(
        bounds: CGRect,
        contentSize: CGSize,
        safeAreaInsets: UIEdgeInsets
    ) -> UIRectEdge {
        let insetBounds = bounds.inset(by: safeAreaInsets)

        var edges = UIRectEdge()

        if insetBounds.minY <= 0.0 {
            edges.formUnion(.top)
        }

        if insetBounds.minX <= 0.0 {
            edges.formUnion(.left)
        }

        if insetBounds.maxY >= contentSize.height {
            edges.formUnion(.bottom)
        }

        if insetBounds.maxX >= contentSize.width {
            edges.formUnion(.right)
        }

        return edges
    }

    public var debugDescription: String {
        var components = [String]()

        if contains(.top) {
            components += [".top"]
        }

        if contains(.left) {
            components += [".left"]
        }

        if contains(.bottom) {
            components += [".bottom"]
        }

        if contains(.right) {
            components += [".right"]
        }

        return "UIRectEdge(\(components.joined(separator: ", ")))"
    }
}
