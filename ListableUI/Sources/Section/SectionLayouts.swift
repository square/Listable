//
//  SectionLayouts.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 1/22/21.
//

import Foundation


///
/// `SectionLayouts` allows you to provide `ListLayout`-specific layout configuration for
/// individual sections within a list. Eg, customize the layout for a section when it is in a table, a grid, etc.
///
/// For example, if you want to specify a custom layout for table layouts, you
/// would do the following on your section:
///
/// ```
/// mySection.layouts.table = .init(
///     width: .fill
/// )
/// ```
///
/// And then, when the `Section` is used within a `.table` style
/// list layout, the provided layout will be used.
///
/// If you plan on swapping between multiple `ListLayout` types on your list,
/// you can provide multiple layouts. The correct one will be used at the correct time:
///
/// ```
/// mySection.layouts.table = .init(
///     width: .fill
/// )
///
/// mySection.layouts.otherLayout = .init(
///     width: 300,
///     alignment: .left
/// )
/// ```
///
/// Note
/// ----
/// When implementing your own custom layout, you should add an extension to `SectionLayouts`,
/// to provide easier access to your layout-specific `SectionLayoutsValue` type, like so:
///
/// ```
/// extension SectionLayouts {
///     public var table : TableAppearance.Section.Layout {
///         get { self[TableAppearance.Section.Layout.self] }
///         set { self[TableAppearance.Section.Layout.self] = newValue }
///     }
/// }
/// ```
public struct SectionLayouts {
        
    /// Creates a new instance of the layouts, with an optional `configure`
    /// closure, to allow you to set up styling inline.
    public init(
        _ configure : (inout Self) -> () = { _ in }
    ) {
        self.storage = .init()
        
        configure(&self)
    }
    
    private var storage : ContentLayoutsStorage
    
    /// Allows accessing the various `SectionLayoutsValue`s stored within the object.
    /// This method will return the `defaultValue` for a value if none is set.
    ///
    /// Note
    /// ----
    /// When implementing your own custom layout, you should add an extension to `SectionLayouts`,
    /// to provide easier access to your layout-specific `SectionLayoutsValue` type.
    ///
    /// ```
    /// extension SectionLayouts {
    ///     public var table : TableAppearance.Section.Layout {
    ///         get { self[TableAppearance.Section.Layout.self] }
    ///         set { self[TableAppearance.Section.Layout.self] = newValue }
    ///     }
    /// }
    /// ```
    public subscript<ValueType:SectionLayoutsValue>(_ valueType : ValueType.Type) -> ValueType {
        get { self.storage.get(valueType, default: ValueType.defaultValue) }
        set { self.storage.set(valueType, new: newValue) }
    }
}


///
/// The `SectionLayoutsValue` protocol provides a default value for the different layouts stored
/// within `SectionLayouts`. Provide a `defaultValue` with reasonable defaults, as the
/// developer should not need to set these values at all times when using your layout.
///
/// ```
/// public struct Layout : Equatable, SectionLayoutsValue
/// {
///     public var width : CGFloat
///     public var minHeight : CGFloat
///
///     ...
///
///     public static var defaultValue : Self {
///         ...
///     }
/// }
/// ```
public protocol SectionLayoutsValue {

    /// The default value used when accessing the value, if none is set.
    static var defaultValue : Self { get }
    
    /// Indicates if the header for the section will be sticky.
    /// Setting this value explicitly overrides the list-level stickiness for headers.
    var isHeaderSticky : Bool? { get }
}


/// Use this type if you have no `SectionLayout` for your `ListLayout`.
public struct EmptySectionLayoutsValue : SectionLayoutsValue {
    
    public init() {}
    
    public static var defaultValue: EmptySectionLayoutsValue {
        .init()
    }
    
    public var isHeaderSticky : Bool? {
        nil
    }
}


extension SectionLayoutsValue {
    
    func isHeaderSticky(list listValue: Bool, header: Bool?) -> Bool {
        if let sticky = isHeaderSticky {
            return sticky
        } else if let header = header {
            return header
        } else {
            return listValue
        }
    }
}
