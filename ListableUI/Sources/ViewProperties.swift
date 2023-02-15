//
//  ViewProperties.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 2/14/23.
//

import Foundation


/// Describes the properties to apply to a view for an `ItemContent` or `HeaderFooterContent`
///
/// Properties are all optional. If a property is optional, it is not applied, and the default value is preserved.
public struct ViewProperties {

    /// If the view should clip its contents or not.
    public var clipsToBounds : Bool?
    
    public var cornerRadius : CGFloat?
    
    public init(
        clipsToBounds: Bool? = nil,
        cornerRadius : CGFloat? = nil
    ) {
        self.clipsToBounds = clipsToBounds
        self.cornerRadius = cornerRadius
    }
    
    public func apply(to view : UIView) {
        if let clipsToBounds {
            view.clipsToBounds = clipsToBounds
        }
        
        if let cornerRadius {
            view.layer.cornerRadius = cornerRadius
            
            /// Required for clipping to have an effect.
            view.clipsToBounds = true
        }
    }
}
