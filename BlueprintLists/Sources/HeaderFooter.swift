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
    func apply(to view: Appearance.View, reason: ApplyReason)
    {
        view.content.element = self.element
        
        view.content.backgroundColor = .clear
    }
}


public struct BlueprintHeaderFooterElementAppearance : HeaderFooterElementAppearance
{
    //
    // MARK: HeaderFooterElementAppearance
    //
    
    public typealias ContentView = BlueprintView
    public typealias BackgroundView = UIView
    
    public static func createReusableHeaderFooterView(frame: CGRect) -> View
    {
        return HeaderFooterElementView(content: BlueprintView(frame: frame), background: UIView())
    }
    
    public func apply(to view: View, previous: BlueprintHeaderFooterElementAppearance?) {}
}

