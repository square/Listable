//
//  ItemLayout.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 12/14/20.
//

import Foundation


public struct ItemLayout : Equatable
{
    public var itemSpacing : CGFloat?
    public var itemToSectionFooterSpacing : CGFloat?
    
    public var width : CustomWidth
        
    public init(
        itemSpacing : CGFloat? = nil,
        itemToSectionFooterSpacing : CGFloat? = nil,
        width : CustomWidth = .default
    ) {
        self.itemSpacing = itemSpacing
        self.itemSpacing = itemSpacing
        
        self.width = width
    }
}
