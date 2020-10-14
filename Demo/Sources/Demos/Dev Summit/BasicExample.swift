//
//  BasicExample.swift
//  Demo
//
//  Created by Kyle Van Essen on 10/13/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import ListableUI
import BlueprintUI
import BlueprintUICommonControls
import BlueprintUILists


struct BasicExample : ProxyElement
{
    var elementRepresentation: Element {
        List { list in
            
            list.layout = layout
            
            list(1) { section in
                section += BasicItem(text: "First Item")
            }
            
            list(2) { section in
                section += BasicItem(text: "First Item")
                section += BasicItem(text: "Second Item")
            }
            
            list(3) { section in
                section += BasicItem(text: "First Item")
                section += BasicItem(text: "Second Item")
                section += BasicItem(text: "Third Item")
            }
            
        }
    }
}

var layout : LayoutDescription {
    LayoutDescription.list { list in
        list.layout.padding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        list.layout.itemSpacing = 0.0
        list.layout.interSectionSpacingWithFooter = 20.0
        list.layout.interSectionSpacingWithNoFooter = 20.0
    }
}

fileprivate struct BasicItem : BlueprintItemContent, Equatable {
    
    var text : String
    
    var identifier: Identifier<BasicItem> {
        .init(self.text)
    }
    
    func element(with info: ApplyItemContentInfo) -> Element {
        Label(text: self.text) {
            $0.font = .systemFont(ofSize: 18.0, weight: .semibold)
        }
        .inset(uniform: 10.0)
        .box(
            background: .systemGray,
            corners: .rounded(
                radius: 10.0,
                corners: info.position.listCorners(for: info.direction)
            )
        )
    }
}


#if DEBUG && canImport(SwiftUI) && !arch(i386) && !arch(arm)

import SwiftUI

@available(iOS 13.0, *)
struct BasicExample_Preview : PreviewProvider {
    static var previews: some View {
        ElementPreview(named: "Basic", with: [.fixed(width: 300.0, height: 500.0)]) {
            BasicExample()
        }
    }
}

#endif

