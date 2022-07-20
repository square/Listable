//
//  DefaultHeaderFooterProperties.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/27/21.
//

import Foundation


/// Allows specifying default properties to apply to a header / footer when it is initialized,
/// if those values are not provided to the initializer.
/// Only non-nil values are used – if you do not want to provide a default value,
/// simply leave the property nil.
///
/// The order of precedence used when assigning values is:
/// 1) The value passed to the initializer.
/// 2) The value from `defaultHeaderFooterProperties` on the contained `HeaderFooterContent`, if non-nil.
/// 3) A standard, default value.
public struct DefaultHeaderFooterProperties<ContentType:HeaderFooterContent>
{
    public typealias HeaderFooter = ListableUI.HeaderFooter<ContentType>
    
    public var sizing : Sizing?
    public var layouts : HeaderFooterLayouts?
    public var onTap : HeaderFooter.OnTap?
    public var debuggingIdentifier : String?
    
    public init(
        sizing : Sizing? = nil,
        layouts : HeaderFooterLayouts? = nil,
        onTap : HeaderFooter.OnTap? = nil,
        debuggingIdentifier : String? = nil,
        
        configure : (inout Self) -> () = { _ in }
    ) {
        self.sizing = sizing
        self.layouts = layouts
        self.onTap = onTap
        self.debuggingIdentifier = debuggingIdentifier
        
        configure(&self)
    }
    
    public static func defaults(with configure : (inout Self) -> () = { _ in }) -> Self {
        .init(configure: configure)
    }
}
