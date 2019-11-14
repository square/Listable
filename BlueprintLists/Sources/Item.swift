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
    
    func element(with state : ItemState) -> BlueprintUI.Element
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
        sizing : Sizing = .default,
        layout : ItemLayout = ItemLayout(),
        selection : ItemSelection = .notSelectable,
        swipeActions : SwipeActions? = nil,
        bind : CreateBinding? = nil,
        onDisplay : OnDisplay? = nil,
        onSelect : OnSelect? = nil,
        onDeselect : OnDeselect? = nil
        )
    {
        self.init(
            with: element,
            appearance: BlueprintItemElementAppearance(),
            sizing: sizing,
            layout: layout,
            selection: selection,
            swipeActions: swipeActions,
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
    
    func apply(to view: Appearance.ContentView, with state : ItemState, reason: ApplyReason)
    {        
        view.element = self.element(with: state)
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
        return BlueprintView(frame: frame)
    }
    
    public func update(view: BlueprintView, with position: ItemPosition) {}
    
    public func apply(to view: BlueprintView, with state : ItemState, previous: BlueprintItemElementAppearance?) {}
    
    public func wasUpdated(comparedTo other: BlueprintItemElementAppearance) -> Bool
    {
        return false
    }
}
