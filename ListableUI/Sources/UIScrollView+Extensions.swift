//
//  UIScrollView+Extensions.swift
//  ListableUI
//
//  Created by Kyle Bashour on 4/10/20.
//

import UIKit

extension UIScrollView {
    /// The frame of the collection view inset by the adjusted content inset,
    /// i.e., the visible frame of the content.
    var visibleContentFrame: CGRect {
        bounds.inset(by: adjustedContentInset)
    }
}
