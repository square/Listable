//
//  HeaderFooter.swift
//  BlueprintLists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import BlueprintUI

import Listable

//
// MARK: Blueprint Elements
//

public protocol BlueprintHeaderFooterElement : HeaderFooterElement where Appearance == BlueprintHeaderFooterElementAppearance
{
    //
    // MARK: Creating Blueprint Element Representations
    //
    
    var element : BlueprintUI.Element { get }
}


//
// MARK: Creating Blueprint Headers & Footers
//

public extension Listable.HeaderFooter where Element : BlueprintHeaderFooterElement
{
    init(
        with element : Element,
        build : Build
        )
    {
        self.init(with: element)
        
        build(&self)
    }
    
    init(
        with element : Element,
        sizing : Sizing = .default,
        layout : HeaderFooterLayout = HeaderFooterLayout()
    )
    {
        self.init(
            with: element,
            appearance: BlueprintHeaderFooterElementAppearance(),
            sizing: sizing,
            layout : layout
        )
    }
}


//
// MARK: Applying Blueprint Elements
//


public extension BlueprintHeaderFooterElement
{
    func apply(to view: Appearance.ContentView, reason: ApplyReason)
    {
        view.element = self.element
        
        view.backgroundColor = .clear
    }
}


public struct BlueprintHeaderFooterElementAppearance : HeaderFooterElementAppearance
{
    //
    // MARK: HeaderFooterElementAppearance
    //
    
    public typealias ContentView = BlueprintView
    
    public static func createReusableHeaderFooterView(frame: CGRect) -> ContentView
    {
        return BlueprintView(frame: frame)
    }
    
    public func apply(to view: ContentView, previous: BlueprintHeaderFooterElementAppearance?) {}
    
    public func wasUpdated(comparedTo other: BlueprintHeaderFooterElementAppearance) -> Bool
    {
        return false
    }
}

