//
//  ChatDemoViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 5/31/23.
//  Copyright © 2023 Kyle Van Essen. All rights reserved.
//

import ListableUI
import BlueprintUI
import BlueprintUICommonControls
import BlueprintUILists


final class ChatDemoViewController : ListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Top", style: .plain, target: self, action: #selector(addAtTop)),
            UIBarButtonItem(title: "Bottom", style: .plain, target: self, action: #selector(addAtBottom)),
        ]
    }
    
    @objc private func addAtTop() {
        messages.insert((UUID(), .random), at: 0)
        self.reload(animated: true)
    }
    
    @objc private func addAtBottom() {
        messages.append((UUID(), .random))
        self.reload(animated: true)
    }
    
    private var messages: [(UUID, MessageContent.Sender)] = [
        (UUID(), .random),
        (UUID(), .random),
        (UUID(), .random),
    ]
    
    override func configure(list: inout ListProperties) {
        
        list.layout = .table { layout in
            layout.bounds = .init(
                padding: .init(top: 20, left: 20, bottom: 20, right: 20),
                width: .atMost(600)
            )
            
            layout.layout.itemSpacing = 0
        }
        
        list.behavior.verticalLayoutGravity = .bottom
        
        list.refreshControl = .init(isRefreshing: false) {
            print("Refreshy")
        }
        
        list.add {
            Section("messages") {
                for (id, sender) in messages {
                    MessageContent(
                        identifierValue: id,
                        sender: sender,
                        content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam nec nibh dui."
                    )
                }
            }
        }
    }
}

fileprivate struct MessageContent : BlueprintItemContent, Equatable {
    
    var identifierValue: AnyHashable
    
    var sender : Sender
    
    var content : String
    
    enum Sender : Equatable {
        case me
        case other
        
        static var random : Self {
            if Bool.random() {
                return .me
            } else {
                return .other
            }
        }
    }
    
    func element(with info: ApplyItemContentInfo) -> Element {
        Label(text: content) {
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.color = .white
        }
        .inset(uniform: 12)
        .box(background: backgroundColor, corners: .rounded(radius: 10))
        .constrainedTo(width: .atMost(300))
        .aligned(horizontally: horizontalAlignment)
    }
    
    private var backgroundColor : UIColor {
        switch sender {
        case .me: return .systemBlue
        case .other: return .systemGray2
        }
    }
    
    private var horizontalAlignment : Aligned.HorizontalAlignment {
        switch sender {
        case .me: return .trailing
        case .other: return .leading
        }
    }
}
