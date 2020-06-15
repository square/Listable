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
    
    func configure(listAppearance appearance : inout Appearance)
    {
        appearance.list.layout.padding = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        
        appearance.backgroundColor = self.backgroundColor
    }
}
