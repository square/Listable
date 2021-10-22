//
//  RefreshControl.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/4/19.
//

import Foundation
import UIKit


public struct RefreshControl
{

    public var isRefreshing : Bool

    public var offsetAdjustmentBehavior: OffsetAdjustmentBehavior

    public var title : Title?
    
    public var tintColor : UIColor?
    
    public typealias OnRefresh = () -> ()
    public var onRefresh : OnRefresh
    
    public init(
        isRefreshing: Bool,
        offsetAdjustmentBehavior: OffsetAdjustmentBehavior = .none,
        title : Title? = nil,
        tintColor : UIColor? = nil,
        onRefresh : @escaping OnRefresh
        )
    {
        self.isRefreshing = isRefreshing
        self.offsetAdjustmentBehavior = offsetAdjustmentBehavior

        self.title = title
        self.tintColor = tintColor
        
        self.onRefresh = onRefresh
    }
}


extension RefreshControl
{
    public enum OffsetAdjustmentBehavior : Equatable
    {
        case none
        case displayWhenRefreshing(animate: Bool, scrollToTop: Bool)
    }

    public enum Title : Equatable
    {
        case string(String)
        case attributed(NSAttributedString)
    }
}
