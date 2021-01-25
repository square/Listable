//
//  ChatDemoViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 1/25/21.
//  Copyright © 2021 Kyle Van Essen. All rights reserved.
//

import ListableUI
import BlueprintUI
import BlueprintUILists
import BlueprintUICommonControls


final class ChatDemoViewController : ListViewController {
    
    var initialTexts : [Text] = initialTexts
    
    override func configure(list: inout ListProperties) {
        
        
        
    }
}


struct ChatBubble : BlueprintItemContent, Equatable {
    
    var text : Text
    
    var identifier: Identifier<ChatBubble> {
        .init(self.text.date)
    }
    
    func element(with info: ApplyItemContentInfo) -> Element {
        Label(text: self.text.content) {
            $0.font = .systemFont(ofSize: 18.0, weight: .medium)
        }
        .inset(uniform: 15.0)
        .constrainedTo(width: .atMost(300.0))
        .aligned(vertically: .fill, horizontally: .trailing)
    }
    
    func backgroundElement(with info: ApplyItemContentInfo) -> Element? {
        Box(
            backgroundColor: .systemBlue,
            cornerStyle: .rounded(radius: 20.0)
        )
    }
}


struct Text : Equatable {
    
    var from : Who
    var content : String
    
    var date : Date
    
    enum Who : Equatable {
        case me
        case someoneElse
    }
}


private let initialTexts : [Text] = [

]
