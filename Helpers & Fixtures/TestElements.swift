//
//  TestElements.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 12/22/19.
//

import Foundation

import Listable


struct TestElement : ItemElement, Equatable
{
    var name : String
    
    var identifier: Identifier<TestElement> {
        return .init(self.name)
    }
    
    func apply(to view: Appearance.ContentView, for reason: ApplyReason, with info: ApplyItemElementInfo)
    {
        view.text = self.name
        
        view.elementApplicationCount += 1
    }

    struct Appearance : ItemElementAppearance, Equatable
    {
        typealias ContentView = Label
        
        static func createReusableItemView(frame: CGRect) -> ContentView {
            return Label(frame: frame)
        }
        
        func apply(to view: ContentView, with info: ApplyItemElementInfo)
        {
            view.appearanceApplicationCount += 1
        }
    }
    
    final class Label : UILabel
    {
        var elementApplicationCount : Int = 0
        var appearanceApplicationCount : Int = 0
    }
}


struct TestSupplementary : HeaderFooterElement, Equatable
{
    var name : String
    
    func apply(to view: Appearance.ContentView, reason: ApplyReason)
    {
        view.text = self.name
        view.elementApplicationCount += 1
    }
    
    struct Appearance : HeaderFooterElementAppearance, Equatable
    {
        typealias ContentView = Label
        
        static func createReusableHeaderFooterView(frame: CGRect) -> TestSupplementary.Label
        {
            return Label(frame: frame)
        }
        
        func apply(to view: TestSupplementary.Label)
        {
            view.appearanceApplicationCount += 1
        }
    }
    
    final class Label : UILabel
    {
        var elementApplicationCount : Int = 0
        var appearanceApplicationCount : Int = 0
    }
}
