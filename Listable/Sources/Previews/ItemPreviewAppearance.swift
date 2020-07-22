//
//  ItemPreviewAppearance.swift
//  Listable
//
//  Created by Kyle Van Essen on 6/12/20.
//

import UIKit


/// The appearance options for a preview item.
public struct ItemPreviewAppearance : Equatable
{
    /// The padding to show around an item.
    var padding : CGFloat
    
    /// The background color to show behind an item.
    /// Defaults to white.
    var backgroundColor : UIColor
    
    /// Creates a new preview appearance.
    public init(
        padding : CGFloat = 20.0,
        backgroundColor : UIColor = .white
    ) {
        self.padding = padding
        self.backgroundColor = backgroundColor
    }
    
    func configure(list description : inout ListProperties)
    {
        description.appearance.backgroundColor = self.backgroundColor
        
        description.layout = .list {
            $0.layout.padding = UIEdgeInsets(top: self.padding, left: self.padding, bottom: self.padding, right: self.padding)
        }
    }
}
