//
//  Item.swift
//  BlueprintLists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import BlueprintUI

import Listable


//
// MARK: Blueprint Elements
//

public protocol BlueprintItemElement : ItemElement where Appearance == BlueprintItemElementAppearance
{
    //
    // MARK: Creating Blueprint Element Representations (Required)
    //
    
    func element(with info : ApplyItemElementInfo) -> BlueprintUI.Element
    
    //
    // MARK: Providing Default Item Values
    //
    
    var defaultItemLayout : ItemLayout { get }
}


public extension BlueprintItemElement
{
    var defaultItemLayout : ItemLayout {
        return ItemLayout()
    }
}


//
// MARK: Creating Blueprint Items
//


public extension Listable.Item where Element : BlueprintItemElement
{
    init(
        _ element : Element,
        build : Build
        )
    {
        self.init(with: element)
        
        build(&self)
    }
    
    init(
        with element : Element,
        sizing : Sizing = .thatFitsWith(.atLeast(.default)),
        layout : ItemLayout? = nil,
        selection : ItemSelection = .notSelectable,
        swipeActions : SwipeActions? = nil,
        reordering : Reordering? = nil,
        bind : CreateBinding? = nil,
        onDisplay : OnDisplay? = nil,
        onSelect : OnSelect? = nil,
        onDeselect : OnDeselect? = nil
        )
    {
        self.init(
            with: element,
            appearance: BlueprintItemElementAppearance(defaultItemLayout: element.defaultItemLayout),
            sizing: sizing,
            layout: layout,
            selection: selection,
            swipeActions: swipeActions,
            reordering: reordering,
            bind: bind,
            onDisplay: onDisplay,
            onSelect: onSelect,
            onDeselect: onDeselect
        )
    }
}

//
// MARK: Applying Blueprint Elements
//

public extension BlueprintItemElement
{
    //
    // MARK: ItemElement
    //
    
    func apply(to view : Appearance.ContentView, for reason: ApplyReason, with info : ApplyItemElementInfo)
    {
        view.element = self.element(with: info)
    }
}


public struct BlueprintItemElementAppearance : ItemElementAppearance
{
    //
    // MARK: ItemElementAppearance
    //
    
    public typealias ContentView = BlueprintView
    
    public static func createReusableItemView(frame: CGRect) -> ContentView
    {
        let view = BlueprintView(frame: frame)
        view.backgroundColor = .clear
        
        return view
    }
    
    public func update(view: BlueprintView, with position: ItemPosition) {}
    
    public func apply(to view: BlueprintView, with info: ApplyItemElementInfo) {}

    public func wasUpdated(comparedTo other: BlueprintItemElementAppearance) -> Bool
    {
        return false
    }
    
    public var defaultItemLayout : ItemLayout
}
