//
//  RefreshControl.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/4/19.
//

import Foundation


public struct RefreshControl
{
    public var isRefreshing : Bool
    
    public var title : Title?
    
    public var tintColor : UIColor?
    
    public typealias OnRefresh = () -> ()
    public var onRefresh : OnRefresh
    
    public init(
        isRefreshing: Bool,
        title : Title? = nil,
        tintColor : UIColor? = nil,
        onRefresh : @escaping OnRefresh
        )
    {
        self.isRefreshing = isRefreshing

        self.title = title
        self.tintColor = tintColor
        
        self.onRefresh = onRefresh
    }
}


extension RefreshControl
{
    public enum Title : Equatable
    {
        case string(String)
        case attributed(NSAttributedString)
    }
}
