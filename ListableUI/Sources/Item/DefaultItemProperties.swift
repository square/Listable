//
//  DefaultItemProperties.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 12/14/20.
//

import Foundation


/// Allows specifying default properties to apply to an item when it is initialized,
/// if those values are not provided to the initializer.
/// Only non-nil values are used – if you do not want to provide a default value,
/// simply leave the property nil.
///
/// The order of precedence used when assigning values is:
/// 1) The value passed to the initializer.
/// 2) The value from `defaultItemProperties` on the contained `ItemContent`, if non-nil.
/// 3) A standard, default value.
public struct DefaultItemProperties<ContentType:ItemContent>
{
    public typealias Item = ListableUI.Item<ContentType>
    
    public var sizing : Sizing?
    public var layouts : ItemLayouts?
    public var selectionStyle : ItemSelectionStyle?
    public var insertAndRemoveAnimations : ItemInsertAndRemoveAnimations?
    public var swipeActions : SwipeActionsConfiguration?
    
    public var reordering : ItemReordering?
    public var onWasReordered : Item.OnWasReordered?
        
    public var onDisplay : Item.OnDisplay.Callback?
    public var onEndDisplay : Item.OnEndDisplay.Callback?
    
    public var onSelect : Item.OnSelect.Callback?
    public var onDeselect : Item.OnDeselect.Callback?
    
    public var onInsert : Item.OnInsert.Callback?
    public var onRemove : Item.OnRemove.Callback?
    public var onMove : Item.OnMove.Callback?
    public var onUpdate : Item.OnUpdate.Callback?
        
    public var debuggingIdentifier : String?
        
    public init(
        sizing : Sizing? = nil,
        layouts : ItemLayouts? = nil,
        selectionStyle : ItemSelectionStyle? = nil,
        insertAndRemoveAnimations : ItemInsertAndRemoveAnimations? = nil,
        swipeActions : SwipeActionsConfiguration? = nil,
        reordering : ItemReordering? = nil,
        onWasReordered : Item.OnWasReordered? = nil,
        onDisplay : Item.OnDisplay.Callback? = nil,
        onEndDisplay : Item.OnEndDisplay.Callback? = nil,
        onSelect : Item.OnSelect.Callback? = nil,
        onDeselect : Item.OnDeselect.Callback? = nil,
        onInsert : Item.OnInsert.Callback? = nil,
        onRemove : Item.OnRemove.Callback? = nil,
        onMove : Item.OnMove.Callback? = nil,
        onUpdate : Item.OnUpdate.Callback? = nil,
        debuggingIdentifier : String? = nil,
        
        configure : (inout Self) -> () = { _ in }
    ) {
        self.sizing = sizing
        self.layouts = layouts
        self.selectionStyle = selectionStyle
        self.insertAndRemoveAnimations = insertAndRemoveAnimations
        self.swipeActions = swipeActions
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
        self.debuggingIdentifier = debuggingIdentifier
        
        configure(&self)
    }
    
    public static func defaults(with configure : (inout Self) -> () = { _ in }) -> Self {
        .init(configure: configure)
    }
}
