//
//  HeaderFooter.swift
//  BlueprintLists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import BlueprintUI
import Listable


public typealias BlueprintHeaderContent = BlueprintHeaderFooterContent
public typealias BlueprintFooterContent = BlueprintHeaderFooterContent


public protocol BlueprintHeaderFooterContent : HeaderFooterContent where ContentView == BlueprintView
{
    //
    // MARK: Creating Blueprint Element Representations
    //
    
    var elementRepresentation : Element { get }
}


public extension BlueprintHeaderFooterContent
{
    //
    // MARK: HeaderFooterContent
    //
    
    func apply(to view: ContentView, reason: ApplyReason)
    {
        view.element = self.elementRepresentation
    }
    
    static func createReusableHeaderFooterView(frame: CGRect) -> ContentView
    {
        let view = BlueprintView(frame: frame)
        view.backgroundColor = .clear
        
        return view
    }
}

