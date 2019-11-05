//
//  ItemScrollPosition.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/5/19.
//


public struct ItemScrollPosition : Equatable
{
    var position : Position
    var ifAlreadyVisible : IfAlreadyVisible
    
    var offset : CGFloat
    
    public init(position : Position = .top, ifAlreadyVisible : IfAlreadyVisible = .doNothing, offset : CGFloat = 0.0)
    {
        self.position = position
        self.ifAlreadyVisible = ifAlreadyVisible
        self.offset = offset
    }
    
    public enum Position : Equatable
    {
        case top
        case centered
        case bottom
        
        var UICollectionViewScrollPosition : UICollectionView.ScrollPosition {
            switch self {
            case .top: return .top
            case .centered: return .centeredVertically
            case .bottom: return .bottom
            }
        }
    }
    
    public enum IfAlreadyVisible : Equatable
    {
        case doNothing
        case scrollToPosition
    }
}
