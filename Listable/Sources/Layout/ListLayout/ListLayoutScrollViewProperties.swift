//
//  ListLayoutScrollViewProperties.swift
//  Listable
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
        contentInsetAdjustmentBehavior: ListLayoutScrollViewProperties.ContentInsetAdjustmentBehavior,
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
        let isPagingEnabled = self.isPagingEnabled || behavior.isPagingEnabled
        
        view.isDirectionalLockEnabled = true
        
        if view.isPagingEnabled != isPagingEnabled {
            view.isPagingEnabled = isPagingEnabled
        }
        
        if #available(iOS 11.0, *), view.contentInsetAdjustmentBehavior != self.contentInsetAdjustmentBehavior.toUIScrollViewValue {
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
    
    public enum ContentInsetAdjustmentBehavior : Equatable {
        case automatic
        case scrollableAxes
        case never
        case always
        
        @available(iOS 11.0, *)
        var toUIScrollViewValue : UIScrollView.ContentInsetAdjustmentBehavior {
            switch self {
            case .automatic: return .automatic
            case .scrollableAxes: return .scrollableAxes
            case .never: return .never
            case .always: return .always
            }
        }
    }
}
