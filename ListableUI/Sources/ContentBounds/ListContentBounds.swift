//
//  ListContentBounds.swift
//  ListContentBounds
//
//  Created by Kyle Van Essen on 8/14/21.
//

import Foundation
import UIKit


/// For participating layouts; allows controlling the padding around and width of content when it is laid out.
///
/// ```
/// ┌──────────────────────────┐    ┌───────────────────────────────────────────┐
/// │       padding.top        │    │               padding.top                 │
/// │ p ┌──────────────────┐ p │    │           ┌──────────────────┐            │
/// │ a │                  │ a │    │           │                  │            │
/// │ d │                  │ d │    │           │                  │            │
/// │ d │                  │ d │    │           │                  │            │
/// │ i │                  │ i │    │           │                  │            │
/// │ n │                  │ n │    │           │                  │            │
/// │ g │                  │ g │    │           │      width       │            │
/// │ . │                  │ . │    │           │◀────────────────▶│            │
/// │ l │                  │ r │    │           │                  │            │
/// │ e │                  │ i │    │           │                  │            │
/// │ f │                  │ g │    │           │                  │            │
/// │ t │                  │ h │    │           │                  │            │
/// │   └──────────────────┘ t │    │           └──────────────────┘            │
/// │      padding.bottom      │    │              padding.bottom               │
/// └──────────────────────────┘    └───────────────────────────────────────────┘
/// ```
public struct ListContentBounds : Equatable {

    /// The padding to place around the outside of the content of the list.
    public var padding : UIEdgeInsets
    
    /// An optional constraint on the width of the content.
    public var width : WidthConstraint
    
    /// Creates a new bounds with the provided options.
    public init(
        padding: UIEdgeInsets = .zero,
        width: WidthConstraint = .noConstraint
    ) {
        self.padding = padding
        self.width = width
    }
}


//
// MARK: Controlling Bounds Via The Environment
//


extension ListEnvironment {
    
    /// The provider for the `ListContentBounds` of the list. You may want to use the `Context`
    /// passed to the provider in order to vary your bounds based on, eg, the width of
    /// the list view:
    ///
    /// ```swift
    ///  env.listContentBounds = { context in
    ///     switch context.viewSize.width {
    ///     case 0...600: return ... // Small
    ///     case 600...900: return ... // Medium
    ///     case 900...: return ... // Large
    ///     }
    ///  }
    /// ```
    public var listContentBounds : ListContentBoundsKey.Provider? {
        get { self[ListContentBoundsKey.self] }
        set { self[ListContentBoundsKey.self] = newValue }
    }
    
    /// Calculates the bounds in the provided context.
    public func listContentBounds(in context : ListContentBounds.Context) -> ListContentBounds {
        self.listContentBounds?(context) ?? .init()
    }
}


extension ListContentBounds {
    
    /// View and layout information passed to `environment.listContentBounds` to determine
    /// the correct `ListContentBounds` for the list.
    public struct Context {
        
        /// The size of the view in question.
        public var viewSize : CGSize
        
        /// The layout direction.
        public var direction : LayoutDirection
        
        /// Creates a new context to use in the `ListEnvironment`'s `listContentBounds`.
        public init(
            viewSize: CGSize,
            direction: LayoutDirection
        ) {
            self.viewSize = viewSize
            self.direction = direction
        }
    }
}


/// A key used to store default / provided bounds into the list's environment.
/// Useful if a parent screen would like to provide default width constraints
/// to be applied to participating layouts.
public enum ListContentBoundsKey : ListEnvironmentKey {
    
    public typealias Provider = (ListContentBounds.Context) -> ListContentBounds
    public typealias Value = Provider?
    
    public static var defaultValue: Value {
        nil
    }
}
