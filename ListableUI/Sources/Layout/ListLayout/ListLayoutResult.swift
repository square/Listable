//
//  ListLayoutResult.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 12/15/21.
//

import Foundation
import UIKit


/// Describes the values which should be calculated and returned from `ListLayout.layout(delegate:in:)`.
public struct ListLayoutResult : Equatable {
    
    /// The size of the content as it has been laid out by your layout.
    public var contentSize : CGSize
    
    /// If available, the natural width of any measured content.
    /// For lists that lay out horizontally, this should be the natural height.
    ///
    /// If your list does not have a natural content width, provide `nil` for this value.
    public var naturalContentWidth : CGFloat?
    
    public init(
        contentSize: CGSize,
        naturalContentWidth: CGFloat?
    ) {
        self.contentSize = contentSize
        self.naturalContentWidth = naturalContentWidth
    }
}
