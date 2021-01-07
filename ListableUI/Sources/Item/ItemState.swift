//
//  ItemState.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 12/14/20.
//

import Foundation


public struct ItemState : Hashable
{
    public init(isSelected : Bool, isHighlighted : Bool)
    {
        self.isSelected = isSelected
        self.isHighlighted = isHighlighted
    }
    
    public init(cell : UICollectionViewCell)
    {
        self.isSelected = cell.isSelected
        self.isHighlighted = cell.isHighlighted
    }
    
    /// If the item is currently selected.
    public var isSelected : Bool
    
    /// If the item is currently highlighted.
    public var isHighlighted : Bool
    
    /// If the item is either selected or highlighted.
    public var isActive : Bool {
        self.isSelected || self.isHighlighted
    }
}
