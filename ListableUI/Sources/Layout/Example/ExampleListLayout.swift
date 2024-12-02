//
//  ExampleListLayout.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 10/31/24.
//

#if DEBUG

import Foundation


extension LayoutDescription {
    
    /// Makes it easier for consumers to use your layout type when applying to a list:
    ///
    /// ```swift
    /// list.layout = .example {
    ///     ...
    /// }
    /// ```
    ///
    static func example(_ configure : (inout ExampleLayoutAppearance) -> () = { _ in }) -> Self
    {
        ExampleListLayout.describe(appearance: configure)
    }
}


extension ItemLayouts {
    
    /// Creates a new `ItemLayouts` value that allows configuring the example values for the item.
    static func example(_ configure : (inout ExampleItemLayout) -> ()) -> Self {
        .init {
            configure(&$0.example)
        }
    }
    
    /// Allows customization of an `Item`'s layout when it is presented within a `.example` style layout.
    var example : ExampleItemLayout {
        get { self[ExampleItemLayout.self] }
        set { self[ExampleItemLayout.self] = newValue }
    }
}


extension HeaderFooterLayouts {
    
    /// Creates a new `HeaderFooterLayouts` value that allows configuring the example header footer values for the item.
    static func example(_ configure : (inout ExampleHeaderFooterLayout) -> ()) -> Self {
        .init {
            configure(&$0.example)
        }
    }
    
    /// Allows customization of a `HeaderFooter`'s layout when it is presented within a `.example` style layout.
    var example : ExampleHeaderFooterLayout {
        get { self[ExampleHeaderFooterLayout.self] }
        set { self[ExampleHeaderFooterLayout.self] = newValue }
    }
}


extension SectionLayouts {
    
    /// Creates a new `SectionLayouts` value that allows configuring the example values for the section.
    static func example(_ configure : (inout ExampleSectionLayout) -> ()) -> Self {
        .init {
            configure(&$0.example)
        }
    }
    
    /// Allows customization of a `Section`'s layout when it is presented within a `.example` style layout.
    var example : ExampleSectionLayout {
        get { self[ExampleSectionLayout.self] }
        set { self[ExampleSectionLayout.self] = newValue }
    }
}


final class ExampleListLayout : ListLayout {
    
    /// The appearance type is what you should use to provide control to consumers
    /// for configurable properties on the layout. Eg, space between items, size of items, etc.
    ///
    /// When the layout is configured via `list.layout = .example { ... }`, this
    /// object is what is passed to the closure.
    typealias LayoutAppearance = ExampleLayoutAppearance
    
    /// Allows customizing the layout for a given single `Item` in a list. You set this
    /// on individual items via the `item.layouts.example { ... }` API, which
    /// is added above in the `extension ItemLayouts {` example.
    ///
    /// If you don't need to provide per-item properties, assign this `typealias`
    /// to `EmptyItemLayoutsValue`, which is an empty type that implements the required protocols.
    /// You do not need to add the `extension ItemLayouts {` in this case, either.
    typealias ItemLayout = ExampleItemLayout
    
    /// Allows customizing the layout for a given single `HeaderFooter` in a list. You set this
    /// on individual items via the `headerFooter.layouts.example { ... }` API, which
    /// is added above in the `extension HeaderFooterLayouts {` example.
    ///
    /// If you don't need to provide per-header/footer properties, assign this `typealias`
    /// to `EmptyHeaderFooterLayoutsValue`, which is an empty type that implements the required protocols.
    /// You do not need to add the `extension HeaderFooterLayouts {` in this case, either.
    typealias HeaderFooterLayout = ExampleHeaderFooterLayout
    
    /// Allows customizing the layout for a given single `Section` in a list. You set this
    /// on individual items via the `section.layouts.example { ... }` API, which
    /// is added above in the `extension SectionLayouts {` example.
    ///
    /// If you don't need to provide per-section properties, assign this `typealias`
    /// to `EmptySectionLayoutsValue`, which is an empty type that implements the required protocols.
    /// You do not need to add the `extension SectionLayouts {` in this case, either.
    typealias SectionLayout = ExampleSectionLayout
    
    /// Provides the layout defaults.
    ///
    /// In terms of which animations to use here, do what looks best for your given layout type.
    /// Figuring this out may take some experimentation. If an existing value does not meet your
    /// needs, you can define a new `static var` on `ItemInsertAndRemoveAnimations`.
    static var defaults: ListLayoutDefaults {
        .init(itemInsertAndRemoveAnimations: .fade)
    }
    
    /// The layout appearance type associated with this layout.
    ///
    ///
    /// > This is a type you define yourself, and then it's passed in in the `init` method.
    var layoutAppearance: ExampleLayoutAppearance
    
    /// The appearance type associated with the containing list.
    ///
    /// > This is not a value you define yourself. It's passed in in the `init` method.
    var appearance: Appearance
    
    /// The behavior values associated with the containing list.
    ///
    /// > This is not a value you define yourself. It's passed in in the `init` method.
    var behavior: Behavior
    
    /// The content associated with the containing list.
    ///
    /// > This is not a value you define yourself. It's passed in in the `init` method.
    var content: ListLayoutContent
    
    /// Creates a new layout – this`init` is required by the `ListLayout` protocol.
    init(
        layoutAppearance: ExampleLayoutAppearance,
        appearance: Appearance,
        behavior: Behavior,
        content: ListLayoutContent
    ) {
        self.layoutAppearance = layoutAppearance
        self.appearance = appearance
        self.behavior = behavior
        self.content = content
    }
    
    /// This is involved on each layout pass, which occurs on every frame.
    ///
    /// You rarely need to implement this method yourself unless you want to do more
    /// beyond standard pinned header behavior. Eg, if you want to change layout of a subset
    /// of items on a frame by frame basis, do it here.
    ///
    /// Note that this must be an entirely "functional" method – it must update the values
    /// of content based on the passed in context, not in any other aggregate way.
    func updateLayout(in context: ListLayoutLayoutContext) {
    
    }
    
    /// This is the method you perform your layouts in. It is called on invalidations of the layout,
    /// which occur during content updates and other invalidations such as safe area changes.
    ///
    /// This method should run quickly, as blocking more than a frame will cause visual glitches.
    func layout(
        delegate: (any CollectionViewLayoutDelegate)?,
        in context: ListLayoutLayoutContext
    ) -> ListLayoutResult {
        fatalError("TODO")
    }
}


struct ExampleItemLayout : ItemLayoutsValue {
    static var defaultValue: Self {
        fatalError()
    }
}


struct ExampleHeaderFooterLayout : HeaderFooterLayoutsValue {
    static var defaultValue: Self {
        fatalError()
    }
}


struct ExampleSectionLayout : SectionLayoutsValue {
    
    static var defaultValue: Self {
        fatalError()
    }
    
    var isHeaderSticky: Bool? {
        nil
    }
}


struct ExampleLayoutAppearance : ListLayoutAppearance {
    
    static var `default`: ExampleLayoutAppearance {
        fatalError()
    }
    
    var direction: LayoutDirection
    
    var bounds: ListContentBounds?
    
    var listHeaderPosition: ListHeaderPosition
    
    var stickySectionHeaders: Bool
    
    var pagingBehavior: ListPagingBehavior
    
    var scrollViewProperties: ListLayoutScrollViewProperties
    
    func toLayoutDescription() -> LayoutDescription {
        LayoutDescription(layoutType: ExampleListLayout.self, appearance: self)
    }
}


#endif
