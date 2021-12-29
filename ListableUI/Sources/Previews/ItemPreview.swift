//
//  ItemPreview.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/9/20.
//


#if DEBUG && canImport(SwiftUI) && !arch(i386) && !arch(arm)


import UIKit
import SwiftUI


///
/// A SwiftUI view that you can use to preview your `Item` or `ItemContent`
/// with Xcode's built in preview functionality.
///
/// Place code similar to the below in your source file alongside your `ItemContent`,
/// and then open the Xcode editor's canvas.
///
///```
/// struct ElementPreview : PreviewProvider {
///     static var previews: some View {
///         ItemPreview.withAllItemStates(
///             for: Item(XcodePreviewDemoContent(
///                 text: "Lorem ipsum dolor sit amet (...)"
///             ))
///         )
///     }
/// }
/// ```
@available(iOS 13.0, *)
public struct ItemPreview : View
{
    /// The item being previewed by the preview.
    public var item : AnyItem
    
    /// The properties of the current preview.
    public var properties : Properties
    
    /// The properties of a preview.
    public struct Properties
    {
        /// The width of the preview.
        public var width : CGFloat
        /// The `ItemState` to use in the preview.
        public var state : ItemState
        /// The desired appearance of the preview.
        public var appearance : ItemPreviewAppearance
        
        /// Creates a new preview with the desired options.
        public init(
            with width : CGFloat = UIScreen.main.bounds.width,
            state : ItemState = .init(isSelected: false, isHighlighted: false, isReordering: false),
            appearance : ItemPreviewAppearance = .init()
        ) {
            self.width = width
            self.state = state
            self.appearance = appearance
        }
    }
    
    /// Creates and returns a SwiftUI view that contains individual previews for each of the provided
    /// properties. Use this if you'd like to preview your `Item` across multiple sizes, states, etc.
    public static func previews(for item : AnyItem, with properties : [Properties]) -> some View
    {
        struct PreviewsItem
        {
            var item : AnyItem
            var properties : Properties
    
            var identifierValue : Identifier
            
            struct Identifier : Hashable {
                var index : Int
                var totalCount : Int
            }
        }
        
        let previewsItems = properties.mapWithIndex {
            PreviewsItem(
                item: item,
                properties: $2,
                identifierValue: .init(index: $0, totalCount: properties.count)
            )
        }
        
        return ForEach(previewsItems, id: \.identifierValue) {
            ItemPreview(item, properties: $0.properties)
        }
    }
    
    /// Creates and returns a SwiftUI view that contains individual previews for all the possible
    /// states of `ItemState`. This allows you to see your `Item` across the possible
    /// selected and highlighted states it can appear in:
    ///
    /// ```
    /// isSelected: false, isHighlighted: false
    /// isSelected: false, isHighlighted: true
    /// isSelected: true, isHighlighted: false
    /// isSelected: true, isHighlighted: true
    /// isSelected: false, isHighlighted: true, isReordering: true
    /// ```
    public static func withAllItemStates(
        for item : AnyItem,
        width : CGFloat = UIScreen.main.bounds.width,
        appearance : ItemPreviewAppearance = .init()
    ) -> some View
    {
        let states : [ItemState] = [
            ItemState(isSelected: false, isHighlighted: false, isReordering: false),
            ItemState(isSelected: false, isHighlighted: true, isReordering: false),
            ItemState(isSelected: true, isHighlighted: false, isReordering: false),
            ItemState(isSelected: true, isHighlighted: true, isReordering: false),
            ItemState(isSelected: false, isHighlighted: false, isReordering: true),
        ]
        
        return Self.previews(for: item, with: states.map {
            Properties(with: width, state: $0, appearance: appearance)
        })
    }
    
    //
    // MARK: Initialization
    //
    
    /// Creates a new preview with the provided properties.
    public init(
        _ item : AnyItem,
        width : CGFloat = UIScreen.main.bounds.width,
        state : ItemState = .init(isSelected: false, isHighlighted: false, isReordering: false),
        appearance : ItemPreviewAppearance = .init()
    ) {
        self.init(
            item,
            properties: Properties(
                with: width,
                state: state,
                appearance: appearance
            )
        )
    }
    
    /// Creates a new preview with the provided properties.
    public init(
        _ item : AnyItem,
        properties : Properties
    ) {
        self.item = item
        
        self.properties = properties
    }
    
    //
    // MARK: SwiftUI.View
    //
    
    public var body: some View {
        ItemPreviewWrapper(
            item: self.item,
            properties: self.properties
        )
            .previewLayout(.sizeThatFits)
            .previewDisplayName(self.previewDisplayName)
    }
    
    private var previewDisplayName : String {
        "Highlighted: \(self.properties.state.isHighlighted), Selected: \(self.properties.state.isSelected)"
    }
    
    private struct ItemPreviewWrapper : UIViewRepresentable
    {
        public var item : AnyItem
        public var properties : Properties
        
        public typealias UIViewType = ItemPreviewView
        
        public func makeUIView(context: Context) -> UIViewType {
            return ItemPreviewView()
        }
        
        public func updateUIView(_ view: UIViewType, context: Context) {
            view.update(
                with: self.properties.width,
                state: self.properties.state,
                appearance: self.properties.appearance,
                item: self.item
            )
        }
    }
}

#endif
