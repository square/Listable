//
//  ItemState.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 12/14/20.
//

import Foundation


public struct ItemState : Hashable
{
    public init(isSelected : Bool, isHighlighted : Bool, isReordering : Bool)
    {
        self.isSelected = isSelected
        self.isHighlighted = isHighlighted
        self.isReordering = isReordering
    }
    
    public init(cell : UICollectionViewCell, isReordering : Bool)
    {
        self.isSelected = cell.isSelected
        self.isHighlighted = cell.isHighlighted
        self.isReordering = isReordering
    }
    
    /// If the item is currently selected.
    public var isSelected : Bool
    
    /// If the item is currently highlighted.
    public var isHighlighted : Bool
    
    /// If the item is currently being moved by the user
    public var isReordering : Bool
    
    /// If the item is either selected or highlighted.
    public var isActive : Bool {
        self.isSelected || self.isHighlighted
    }
}
