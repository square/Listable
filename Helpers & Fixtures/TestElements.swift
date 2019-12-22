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
    
    func apply(to view: TestElement.Appearance.ContentView, for reason: ApplyReason, with info: ApplyItemElementInfo)
    {
        
    }

    struct Appearance : ItemElementAppearance, Equatable
    {
        typealias ContentView = UIView
        
        static func createReusableItemView(frame: CGRect) -> UIView {
            return UIView(frame: frame)
        }
        
        func apply(to view: UIView, with info: ApplyItemElementInfo)
        {
            
        }
    }
}
