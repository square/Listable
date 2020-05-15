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

public protocol BlueprintHeaderFooterElement : HeaderFooterElement where ContentView == BlueprintView
{
    //
    // MARK: Creating Blueprint Element Representations
    //
    
    var element : BlueprintUI.Element { get }
}


//
// MARK: Applying Blueprint Elements
//


public extension BlueprintHeaderFooterElement
{
    func apply(to view: ContentView, reason: ApplyReason)
    {
        view.element = self.element
    }
    
    static func createReusableHeaderFooterView(frame: CGRect) -> ContentView
    {
        let view = BlueprintView(frame: frame)
        view.backgroundColor = .clear
        
        return view
    }
}

