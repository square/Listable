//
//  DefaultDecorationProperties.swift
//  ListableUI
//
//  Created by Goose on 7/24/25.
//

import Foundation


/// Allows specifying default properties to apply to a decoration when it is initialized,
/// if those values are not provided to the initializer.
/// Only non-nil values are used – if you do not want to provide a default value,
/// simply leave the property nil.
///
/// The order of precedence used when assigning values is:
/// 1) The value passed to the initializer.
/// 2) The value from `defaultDecorationProperties` on the contained `DecorationContent`, if non-nil.
/// 3) A standard, default value.
public struct DefaultDecorationProperties<ContentType:DecorationContent>
{
    public typealias Decoration = ListableUI.Decoration<ContentType>
    
    public var sizing : Sizing?
    public var layouts : DecorationLayouts?
    public var onTap : Decoration.OnTap?
    public var debuggingIdentifier : String?
    
    public init(
        sizing : Sizing? = nil,
        layouts : DecorationLayouts? = nil,
        onTap : Decoration.OnTap? = nil,
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
