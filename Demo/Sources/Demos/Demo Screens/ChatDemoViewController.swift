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


final class ChatDemoViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Top", style: .plain, target: self, action: #selector(addAtTop)),
            UIBarButtonItem(title: "Bottom", style: .plain, target: self, action: #selector(addAtBottom)),
        ]

        self.view.addSubview(listView)
        listView.translatesAutoresizingMaskIntoConstraints = true
        listView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        listView.frame = view.bounds

        listView.customScrollViewInsets = { [weak self] in
            guard let self = self else { return .zero }
            let inset = max(self.footerHeight, self.keyboardHeight)
            print("inset", inset)
            return UIEdgeInsets(
               top: 0,
               left: 0,
               bottom: inset,
               right: 0
           )
        }
        listView.updateScrollViewInsets()
        listView.onKeyboardFrameWillChange = { [weak self] keyboardCurrentFrameProvider, keyboardAnimation in
            guard let self = self else { return }
            switch keyboardCurrentFrameProvider.currentFrame(in: self.view) {
            case .overlapping(frame: let frame):
                self.keyboardHeight = frame.height
            case .nonOverlapping, .none:
                self.keyboardHeight = 0
            }
            
            UIView.animate(
                withDuration: keyboardAnimation.animationDuration,
                delay: 0.0,
                options: keyboardAnimation.options,
                animations: {
                    self.listView.updateScrollViewInsets()
                }
            )
        }
        
        self.view.addSubview(footerView)
        footerView.translatesAutoresizingMaskIntoConstraints = false

        self.reload()
    }
    
    @objc private func addAtTop() {
        messages.insert((UUID(), .random), at: 0)
        messages.insert((UUID(), .random), at: 0)
        messages.insert((UUID(), .random), at: 0)
        messages.insert((UUID(), .random), at: 0)
        messages.insert((UUID(), .random), at: 0)
        if listView.isContentScrollable {
            UIView.performWithoutAnimation {
                self.reload()
            }
        } else {
            self.reload()
        }
    }
    
    @objc private func addAtBottom() {
        messages.append((UUID(), .random))
        self.reload()
    }

    private var footerHeight: CGFloat = 50
    private var keyboardHeight: CGFloat = 0
    private let listView = ListView()
    private var footerView = BlueprintView()

    private func reload()
    {
        configureListView()
        footerView.element = Row(alignment: .center, minimumSpacing: 8) {
            TextField(text: "").box(background: UIColor.white).inset(uniform: 8)
            Button(
                onTap: { [weak self] in
                    guard let self = self else { return }
                    guard self.footerHeight > 50 else { return }
                    self.footerHeight -= 50
                    self.footerView.frame.size.height = self.footerHeight
                    self.reload()
                    self.listView.updateScrollViewInsets()
                },
                wrapping: Label(text: "Decrease height")
            )
            Button(
                onTap: { [weak self] in
                    guard let self = self else { return }
                    self.footerHeight += 50
                    self.footerView.frame.size.height = self.footerHeight
                    self.reload()
                    self.listView.updateScrollViewInsets()
                },
                wrapping: Label(text: "Increase height")
            )
        }.box(background: UIColor.lightGray)
    }

    private func footerViewFrame() -> CGRect {
        var frame = CGRect()
        frame.size.width = view.bounds.width
        frame.size.height = footerHeight
        frame.origin.y = view.bounds.height - footerHeight
        return frame
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        footerView.frame = footerViewFrame()
    }

    private var messages: [(UUID, MessageContent.Sender)] = [
        (UUID(), .random),
        (UUID(), .random),
        (UUID(), .random),
    ]
    
    private func configureListView() {
        
        listView.configure { list in
            
            list.layout = .table { layout in
                layout.bounds = .init(
                    padding: .init(top: 20, left: 20, bottom: 20, right: 20),
                    width: .atMost(600)
                )
                
                layout.layout.itemSpacing = 10
            }
            
            list.behavior.verticalLayoutGravity = .bottom
            list.behavior.keyboardAdjustmentMode = .custom
            
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
