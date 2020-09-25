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
    var contentFrame: CGRect {
        return self.bounds.inset(by: self.lst_adjustedContentInset)
    }

    /// `adjustedContentInset` on iOS >= 11, `contentInset` otherwise.
    var lst_adjustedContentInset: UIEdgeInsets {
        if #available(iOS 11, *) {
            return self.adjustedContentInset
        } else {
            return self.contentInset
        }
    }
}
