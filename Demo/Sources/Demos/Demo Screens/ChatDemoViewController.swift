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
    
    var texts : [Text] = initialTexts
    
    override func configure(list: inout ListProperties) {
        
        list.layout = .table {
            $0.layout.padding = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
            $0.layout.itemSpacing = 10.0
        }
        
        list.bottomBar = .element {
            TextField(text: "Hello, world!")
                .box(background: .lightGray)
                .constrainedTo(height: .atLeast(50))
        }
        
        list("chat") { section in
            section += self.texts.map {
                ChatBubble(text: $0)
            }
        }
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
            
            $0.color = text.from.ifMe(.white, someoneElse: .black)
        }
        .inset(uniform: 12.0)
        .box(
            background: text.from.ifMe(.systemBlue, someoneElse: .lightGray),
            corners: .rounded(radius: 20.0)
        )
        .constrainedTo(width: .within(50...300))
        .aligned(
            vertically: .fill,
            horizontally: text.from.ifMe(.trailing, someoneElse: .leading)
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
        
        func ifMe<Value>(_ me : () -> Value, someoneElse : () -> Value) -> Value {
            switch self {
            case .me: return me()
            case .someoneElse: return someoneElse()
            }
        }
        
        func ifMe<Value>(_ me : @autoclosure () -> Value, someoneElse : @autoclosure () -> Value) -> Value {
            self.ifMe(me, someoneElse: someoneElse)
        }
    }
}


private let initialTexts : [Text] = [

    Text(
        from: .someoneElse,
        content: "I am here for you",
        date: Date().addingTimeInterval(-60)
    ),
    
    Text(
        from: .me,
        content: "Thanks :) I'm going through a tough time so it means a lot",
        date: Date().addingTimeInterval(-30)
    ),
    
    Text(
        from: .me,
        content: "And sorry, I lost all my contacts, who is this?",
        date: Date().addingTimeInterval(-20)
    ),
    
    Text(
        from: .someoneElse,
        content: "This is your Uber driver",
        date: Date().addingTimeInterval(-10)
    ),
    
    Text(
        from: .someoneElse,
        content: "I am here to pick you up",
        date: Date().addingTimeInterval(-5)
    ),
    
    Text(
        from: .me,
        content: "Oh",
        date: Date().addingTimeInterval(-20)
    ),
    
]
