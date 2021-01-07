//
//  HeaderFooterLayout.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 12/14/20.
//

import Foundation


public struct HeaderFooterLayout : Equatable
{
    public var width : CustomWidth
        
    public init(
        width : CustomWidth = .default
    ) {
        self.width = width
    }
}
