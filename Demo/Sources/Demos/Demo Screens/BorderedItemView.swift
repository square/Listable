//
//  BorderedItemView.swift
//  Demo
//
//  Created by Thomas Abend on 12/5/22.
//  Copyright © 2022 Kyle Van Essen. All rights reserved.
//

import ListableUI
import BlueprintUILists
import BlueprintUI
import BlueprintUICommonControls

struct BorderedItemView: BlueprintItemContent {
    let content: BorderedItem
    let context: BorderContext
    let style: BorderedListStyle

    var identifierValue: String { content.identifierValue }

    func isEquivalent(to other: Self) -> Bool {
        context.drawsSameBorders(as: other.context) && content.isEquivalent(to: other.content)
    }

    func element(with info: ApplyItemContentInfo) -> Element {
        content.element(with: info)
            .box(
                background: context.backgroundBorder == .none ? .clear : style.containerBackground.color,
                corners: .rounded(
                    radius: style.containerBackground.cornerRadius,
                    corners: context.backgroundBorder.corners
                )
            )
        
        // This stuff below used to be in element and is now in overlayDecorationElement. uncomment to see how it rendered
        
//            .bordered(context.outerBorder, style: style.outerBorder)
//            .bordered(context.selectionBorder, style: style.selectionBorder)
//            .bordered(context.separatorBorder, style: style.flatBottomSelectionBorder)
            .inset(horizontal: style.selectionBorder.width / 2)
    }
    
    func overlayDecorationElement(with info: ApplyItemContentInfo) -> Element? {
        Empty()
            .bordered(context.outerBorder, style: style.outerBorder)
            .bordered(context.selectionBorder, style: style.selectionBorder)
            .bordered(context.separatorBorder, style: style.flatBottomSelectionBorder)
    }
}
