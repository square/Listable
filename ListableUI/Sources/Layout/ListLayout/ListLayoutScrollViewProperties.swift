//
//  ListLayoutScrollViewProperties.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/7/20.
//

import UIKit


public struct ListLayoutScrollViewProperties : Equatable
{
    public var pagingStyle : PagingStyle?
    
    public var contentInsetAdjustmentBehavior : ContentInsetAdjustmentBehavior
    
    public var allowsBounceVertical : Bool
    public var allowsBounceHorizontal : Bool
    
    public var allowsHorizontalScrollIndicator : Bool
    public var allowsVerticalScrollIndicator : Bool
    
    public init(
        pagingStyle: PagingStyle?,
        contentInsetAdjustmentBehavior: ContentInsetAdjustmentBehavior,
        allowsBounceVertical : Bool,
        allowsBounceHorizontal : Bool,
        allowsVerticalScrollIndicator : Bool,
        allowsHorizontalScrollIndicator : Bool
    ) {
        self.pagingStyle = pagingStyle
        self.contentInsetAdjustmentBehavior = contentInsetAdjustmentBehavior
        
        self.allowsBounceVertical = allowsBounceVertical
        self.allowsBounceHorizontal = allowsBounceHorizontal

        self.allowsVerticalScrollIndicator = allowsVerticalScrollIndicator
        self.allowsHorizontalScrollIndicator = allowsHorizontalScrollIndicator
    }
        
    func apply(
        to view : UIScrollView,
        behavior : Behavior,
        direction : LayoutDirection,
        showsScrollIndicators : Bool
    ) {
        /// **Note**: Properties are only set if they are different (hence all the `if` statements below)
        /// because some UIScrollView properties, even when set to the same value, can affect or stop scrolling if it
        /// is in progress. Hard to tell which across iOS versions, so just always be defensive.
        
        if view.isScrollEnabled != behavior.isScrollEnabled {
            view.isScrollEnabled = behavior.isScrollEnabled
        }

        let isNativePagingEnabled = self.pagingStyle == .native || behavior.pagingStyle == .native

        if view.isPagingEnabled != isNativePagingEnabled {
            view.isPagingEnabled = isNativePagingEnabled
        }
        
        if view.contentInsetAdjustmentBehavior != self.contentInsetAdjustmentBehavior.toUIScrollViewValue {
            view.contentInsetAdjustmentBehavior = self.contentInsetAdjustmentBehavior.toUIScrollViewValue
        }
        
        let alwaysBounceVertical = self.allowsBounceVertical && behavior.underflow.alwaysBounce && direction == .vertical
        let alwaysBounceHorizontal = self.allowsBounceHorizontal && behavior.underflow.alwaysBounce && direction == .horizontal
        
        if view.alwaysBounceVertical != alwaysBounceVertical {
            view.alwaysBounceVertical = alwaysBounceVertical
        }
        
        if view.alwaysBounceHorizontal != alwaysBounceHorizontal {
            view.alwaysBounceHorizontal = alwaysBounceHorizontal
        }
        
        let showsVerticalScrollIndicator = self.allowsVerticalScrollIndicator && showsScrollIndicators
        let showsHorizontalScrollIndicator = self.allowsHorizontalScrollIndicator && showsScrollIndicators
        
        if view.showsVerticalScrollIndicator != showsVerticalScrollIndicator {
            view.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        }
        
        if view.showsHorizontalScrollIndicator != showsHorizontalScrollIndicator {
            view.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        }
    }
}


/// Constants indicating how safe area insets are added to the adjusted content inset.
/// Mirrors `UIScrollView.ContentInsetAdjustmentBehavior`.
public enum ContentInsetAdjustmentBehavior : Equatable {
    
    /// Applies the inset from a UIKit navigation bar or tab bar.
    case automatic
    
    /// Applies the safe area inset for the scrollable axes.
    case scrollableAxes
    
    /// Applies no safe area inset.
    case never
    
    /// Applies all safe area insets.
    case always
    
    var toUIScrollViewValue : UIScrollView.ContentInsetAdjustmentBehavior {
        switch self {
        case .automatic: return .automatic
        case .scrollableAxes: return .scrollableAxes
        case .never: return .never
        case .always: return .always
        }
    }
}


/// The paging style of the scroll view.
public enum PagingStyle {
    
    /// Applies native `UIScrollView` paging, where each page is the full width of the
    /// scroll view's bounds.
    case native
    
    /// Applies custom paging logic, used when the page isn't the full width of the scroll
    /// view's bounds.
    case custom
}
