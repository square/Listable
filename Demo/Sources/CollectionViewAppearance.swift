//
//  CollectionViewAppearance.swift
//  Demo
//
//  Created by Kyle Van Essen on 10/20/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import Listable
import BlueprintLists
import BlueprintUI
import BlueprintUICommonControls


let demoAppearance = Appearance {
    $0.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
                
    $0.layout = ListLayout(
        padding: UIEdgeInsets(top: 30.0, left: 20.0, bottom: 30.0, right: 20.0),
        width: .atMost(600.0),
        interSectionSpacingWithNoFooter: 20.0,
        interSectionSpacingWithFooter: 20.0,
        sectionHeaderBottomSpacing: 10.0,
        itemSpacing: 6.0,
        itemToSectionFooterSpacing: 10.0,
        stickySectionHeaders: true
    )
}

extension UIColor
{
    static func white(_ blend : CGFloat) -> UIColor
    {
        return UIColor(white: blend, alpha: 1.0)
    }
}


struct DemoHeader : BlueprintHeaderFooterElement, Equatable
{
    var title : String
    
    var element: Element {
        var box = Box(
            backgroundColor: .white,
            cornerStyle: .rounded(radius: 10.0),
            wrapping: Inset(
                uniformInset: 10.0,
                wrapping: Label(text: self.title) {
                    $0.font = .systemFont(ofSize: 16.0, weight: .semibold)
                }
            )
        )
        
        box.borderStyle = .solid(color: .white(0.7), width: 1.0)
        box.shadowStyle = .simple(radius: 2.0, opacity: 0.20, offset: .init(width: 0, height: 1.0), color: .black)
        
        return box
    }
}


struct DemoItem : BlueprintItemElement, Equatable
{
    var text : String
    
    var identifier: Identifier<DemoItem> {
        return .init(self.text)
    }
    
    func element(with state: ItemState) -> Element {
        var box = Box(
            backgroundColor: .white,
            cornerStyle: .rounded(radius: 6.0),
            wrapping: Inset(
                uniformInset: 10.0,
                wrapping: Label(text: self.text)
            )
        )
        
        box.borderStyle = .solid(color: .white(0.8), width: 1.0)
        box.shadowStyle = .simple(radius: 2.0, opacity: 0.15, offset: .init(width: 0, height: 1.0), color: .black)
        
        return box
    }
}


struct DemoFooter : BlueprintHeaderFooterElement, Equatable
{
    var text : String
    
    var element: Element {
        return Centered(Label(text: self.text))
    }
}
