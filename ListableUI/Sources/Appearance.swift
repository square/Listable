//
//  Appearance.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 10/17/19.
//

import UIKit


///
/// Contains all the properties which affect the appearance of all possible kinds of list layouts.
///
/// For properties that are specific to individual layouts, see the `layoutAppearance` property
/// on each layout type.
///
public struct Appearance : Equatable
{
    /// The background color for the list.
    @Color public var backgroundColor : UIColor
    
    /// The tint color of the refresh control.
    public var refreshControlColor : UIColor?
    
    /// If the list should display its scroll indicators.
    public var showsScrollIndicators : Bool
        
    /// Creates a new appearance object with the provided options.
    public init(
        backgroundColor : UIColor = Self.defaultBackgroundColor,
        refreshControlColor : UIColor? = nil,
        showsScrollIndicators : Bool = true,
        configure : (inout Self) -> () = { _ in }
    ) {
        self._backgroundColor = Color(backgroundColor)
        
        self.refreshControlColor = refreshControlColor
        
        self.showsScrollIndicators = showsScrollIndicators
        
        configure(&self)
    }
    
    /// The default background color for the `Appearance`.
    public static var defaultBackgroundColor : UIColor {
        return UIColor { traits in
            switch traits.userInterfaceStyle {
            case .unspecified, .light:
                return .white
            case .dark:
                return .black
            @unknown default:
                return .white
            }
        }
    }
}
