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
        _ element : Element,
        height : Height = .default
    )
    {
        self.init(
            element,
            appearance: BlueprintHeaderFooterElementAppearance(),
            height: height
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
    }
}


public struct BlueprintHeaderFooterElementAppearance : HeaderFooterElementAppearance
{
    //
    // MARK: HeaderFooterElementAppearance
    //
    
    public typealias ContentView = BlueprintView
    public typealias BackgroundView = UIView
    
    public static func createReusableHeaderFooterView() -> View
    {
        return HeaderFooterElementView(content: BlueprintView(), background: UIView())
    }
    
    public func apply(to view: View, previous: BlueprintHeaderFooterElementAppearance?) {}
}

