//
//  ListLayoutScrollViewProperties.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/7/20.
//

import UIKit


public struct ListLayoutScrollViewProperties
{
    public var isPagingEnabled : Bool
    
    public var contentInsetAdjustmentBehavior : ContentInsetAdjustmentBehavior
    
    public var allowsBounceVertical : Bool
    public var allowsBounceHorizontal : Bool
    
    public var allowsHorizontalScrollIndicator : Bool
    public var allowsVerticalScrollIndicator : Bool
    
    public init(
        isPagingEnabled: Bool,
        contentInsetAdjustmentBehavior: ContentInsetAdjustmentBehavior,
        allowsBounceVertical : Bool,
        allowsBounceHorizontal : Bool,
        allowsVerticalScrollIndicator : Bool,
        allowsHorizontalScrollIndicator : Bool
    ) {
        self.isPagingEnabled = isPagingEnabled
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
        
        let isPagingEnabled = self.isPagingEnabled || behavior.isPagingEnabled
                
        if view.isPagingEnabled != isPagingEnabled {
            view.isPagingEnabled = isPagingEnabled
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


public enum ContentInsetAdjustmentBehavior : Equatable {
    
    case automatic
    case scrollableAxes
    case never
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
