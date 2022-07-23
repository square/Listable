//
//  Item.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/10/19.
//

///
/// An `Item` is one of the core types deployed by Listable, allowing you to specify
/// and control many of the behaviors, appearance options, and callbacks for interacting
/// with rows within a list.
///
/// `Item` wraps an `ItemContent` struct (a protocol you implement to provide content),
/// which drives the primary content of the row the `Item` displays.
///
/// If you are used to working with a collection view or table view, you can think of `ItemContent`
/// as what you put in the `contentView` of your cell, and you can think of `Item` as all of the additional
/// options of a row/cell: sizing, swipe to delete actions, reordering controls, callbacks, etc.
///
/// Once added to a section, `Item` is type erased to`AnyItem`,
/// to allow for mixed collections of content within a section.
public struct Item<Content:ItemContent> : AnyItem, AnyItemConvertible
{
    public var identifier : Content.Identifier
    
    public var content : Content
    
    public var sizing : Sizing
    public var layouts : ItemLayouts
    
    public var selectionStyle : ItemSelectionStyle
    
    public var insertAndRemoveAnimations : ItemInsertAndRemoveAnimations?
    public var sectionInsertAndRemoveAnimations : ItemInsertAndRemoveAnimations?
    
    public var swipeActions : SwipeActionsConfiguration?

    public typealias OnWasReordered = (Self, ItemReordering.Result) -> ()
    
    public var reordering : ItemReordering?
    public var onWasReordered : OnWasReordered?
        
    public var onDisplay : OnDisplay.Callback?
    public var onEndDisplay : OnEndDisplay.Callback?
    
    public var onSelect : OnSelect.Callback?
    public var onDeselect : OnDeselect.Callback?
    
    public var onInsert : OnInsert.Callback?
    public var onRemove : OnRemove.Callback?
    public var onMove : OnMove.Callback?
    public var onUpdate : OnUpdate.Callback?
        
    public var debuggingIdentifier : String? = nil
    
    internal let reuseIdentifier : ReuseIdentifier<Content>
    
    //
    // MARK: Initialization
    //
    
    public typealias Configure = (inout Item) -> ()
    
    public init(
        _ content : Content,
        configure : Configure
    ) {
        self.init(content)
        
        configure(&self)
    }
    
    public init(
        _ content : Content,
        sizing : Sizing? = nil,
        layouts : ItemLayouts? = nil,
        selectionStyle : ItemSelectionStyle? = nil,
        insertAndRemoveAnimations : ItemInsertAndRemoveAnimations? = nil,
        swipeActions : SwipeActionsConfiguration? = nil,
        reordering : ItemReordering? = nil,
        onWasReordered : OnWasReordered? = nil,
        onDisplay : OnDisplay.Callback? = nil,
        onEndDisplay : OnEndDisplay.Callback? = nil,
        onSelect : OnSelect.Callback? = nil,
        onDeselect : OnDeselect.Callback? = nil,
        onInsert : OnInsert.Callback? = nil,
        onRemove : OnRemove.Callback? = nil,
        onMove : OnMove.Callback? = nil,
        onUpdate : OnUpdate.Callback? = nil
    ) {
        assertIsValueType(Content.self)
        
        self.content = content
        
        let defaults = self.content.defaultItemProperties
        
        self.sizing = sizing ?? defaults.sizing ?? .thatFits(.noConstraint)
        self.layouts = layouts ?? defaults.layouts ?? .init()
        self.selectionStyle = selectionStyle ?? defaults.selectionStyle ?? .notSelectable
        self.insertAndRemoveAnimations = insertAndRemoveAnimations ?? defaults.insertAndRemoveAnimations ?? nil
        self.swipeActions = swipeActions ?? defaults.swipeActions ?? nil
        self.reordering = reordering ?? defaults.reordering ?? nil
        self.onWasReordered = onWasReordered ?? defaults.onWasReordered ?? nil
        self.onDisplay = onDisplay ?? defaults.onDisplay ?? nil
        self.onEndDisplay = onEndDisplay ?? defaults.onEndDisplay ?? nil
        self.onSelect = onSelect ?? defaults.onSelect ?? nil
        self.onDeselect = onDeselect ?? defaults.onDeselect ?? nil
        self.onInsert = onInsert ?? defaults.onInsert ?? nil
        self.onRemove = onRemove ?? defaults.onRemove ?? nil
        self.onMove = onMove ?? defaults.onMove ?? nil
        self.onUpdate = onUpdate ?? defaults.onUpdate ?? nil
        self.debuggingIdentifier = debuggingIdentifier ?? defaults.debuggingIdentifier ?? nil
        
        self.reordering = reordering
        self.onWasReordered = onWasReordered
                
        self.onDisplay = onDisplay
        self.onEndDisplay = onEndDisplay
        
        self.onSelect = onSelect
        self.onDeselect = onDeselect
        
        self.onInsert = onInsert
        self.onRemove = onRemove
        self.onMove = onMove
        self.onUpdate = onUpdate
        
        self.reuseIdentifier = .identifier(for: Content.self)
        
        self.identifier = self.content.identifier
        
        #if DEBUG
        precondition(
            self.identifier.value == self.content.identifierValue,
            
            """
            `\(String(describing: Content.self)).identifierValue` is not stable: When requested twice, \
            the value changed from `\(self.identifier.value)` to `\(self.content.identifierValue)`. In \
            order for Listable to perform correct and efficient updates to your content, your `identifierValue` \
            must be stable. See the documentation on `ItemContent.identifierValue` for suggestions.
            """
        )
        #endif
    }
    
    // MARK: AnyItem
    
    public var anyIdentifier : AnyIdentifier {
        self.identifier
    }
    
    public var anyContent: Any {
        self.content
    }
    
    public var reappliesToVisibleView: ReappliesToVisibleView {
        self.content.reappliesToVisibleView
    }
    
    // MARK: AnyItemConvertible
    
    public func toAnyItem() -> AnyItem {
        self
    }
    
    // MARK: AnyItem_Internal
    
    public func anyIsEquivalent(to other : AnyItem) -> Bool
    {
        guard let other = other as? Item<Content> else {
            return false
        }
        
        return self.content.isEquivalent(to: other.content)
    }
    
    public func anyWasMoved(comparedTo other : AnyItem) -> Bool
    {
        guard let other = other as? Item<Content> else {
            return true
        }
        
        return self.content.wasMoved(comparedTo: other.content)
    }
    
    public func newPresentationItemState(
        with dependencies : ItemStateDependencies,
        updateCallbacks : UpdateCallbacks,
        performsContentCallbacks : Bool
    ) -> Any
    {
        PresentationState.ItemState(
            with: self,
            dependencies: dependencies,
            updateCallbacks: updateCallbacks,
            performsContentCallbacks : performsContentCallbacks
        )
    }
}


extension ItemContent {
    
    /// Identical to `Item.init` which takes in an `ItemContent`,
    /// except you can call this on the `ItemContent` itself, instead of wrapping it,
    /// to avoid additional nesting, and to hoist your content up in your code.
    ///
    /// ```
    /// Section("id") { section in
    ///     section += MyItemContent(name: "Listable")
    ///                   .with(
    ///                       sizing: .thatFits(.noConstraint),
    ///                       selectionStyle: .tappable
    ///                   )
    ///
    /// struct MyItemContent : ItemContent {
    ///    var name : String
    ///    ...
    /// }
    /// ```
    public func with(
        sizing : Sizing? = nil,
        layouts : ItemLayouts? = nil,
        selectionStyle : ItemSelectionStyle? = nil,
        insertAndRemoveAnimations : ItemInsertAndRemoveAnimations? = nil,
        swipeActions : SwipeActionsConfiguration? = nil,
        reordering : ItemReordering? = nil,
        onWasReordered : Item<Self>.OnWasReordered? = nil,
        onDisplay : Item<Self>.OnDisplay.Callback? = nil,
        onEndDisplay : Item<Self>.OnEndDisplay.Callback? = nil,
        onSelect : Item<Self>.OnSelect.Callback? = nil,
        onDeselect : Item<Self>.OnDeselect.Callback? = nil,
        onInsert : Item<Self>.OnInsert.Callback? = nil,
        onRemove : Item<Self>.OnRemove.Callback? = nil,
        onMove : Item<Self>.OnMove.Callback? = nil,
        onUpdate : Item<Self>.OnUpdate.Callback? = nil
    ) -> Item<Self>
    {
        Item(
            self,
            sizing: sizing,
            layouts: layouts,
            selectionStyle: selectionStyle,
            insertAndRemoveAnimations: insertAndRemoveAnimations,
            swipeActions: swipeActions,
            reordering: reordering,
            onWasReordered: onWasReordered,
            onDisplay: onDisplay,
            onEndDisplay: onEndDisplay,
            onSelect: onSelect,
            onDeselect: onDeselect,
            onInsert: onInsert,
            onRemove: onRemove,
            onMove: onMove,
            onUpdate: onUpdate
        )
    }
}


extension Item : SignpostLoggable
{
    var signpostInfo : SignpostLoggingInfo {
        SignpostLoggingInfo(
            identifier: self.debuggingIdentifier,
            instanceIdentifier: self.identifier.debugDescription
        )
    }
}
