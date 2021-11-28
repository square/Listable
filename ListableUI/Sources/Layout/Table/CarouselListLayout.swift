//
//  CarouselListLayout.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/27/21.
//

import Foundation


extension LayoutDescription
{
    public static func carousel(_ configure : (inout CarouselAppearance) -> () = { _ in }) -> Self
    {
        var carousel = CarouselAppearance()
        configure(&carousel)
        
        return TableListLayout.describe { table in
            table.direction = .horizontal
            table.bounds = .init(padding: carousel.padding)
            
            table.onDidEndDragging = .adjustsScrollToShowFullTargetItem
        }
    }
}


public struct CarouselAppearance : Equatable {
    
    public var padding : UIEdgeInsets
    
    public var itemWidth : Width
    
    public init(
        padding: UIEdgeInsets = .zero,
        itemWidth : Width = .ofView
    ) {
        self.padding = padding
        self.itemWidth = itemWidth
    }
    
    public enum Width : Equatable {
        case ofView
        case fixed(CGFloat)
    }
}
