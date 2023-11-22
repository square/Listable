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
            UIBarButtonItem(title: "New message", style: .plain, target: self, action: #selector(addAtBottom)),
            UIBarButtonItem(title: "Grow", style: .plain, target: self, action: #selector(growFrame)),
            UIBarButtonItem(title: "Shrink", style: .plain, target: self, action: #selector(shrinkFrame)),
            UIBarButtonItem(title: "Scroll Down", style: .plain, target: self, action: #selector(scrollDown)),
        ]

        self.view.addSubview(listView)
        listView.translatesAutoresizingMaskIntoConstraints = true
        listView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        listView.frame = view.bounds

        listView.customScrollViewInsets = { [weak self] in
            guard let self = self else { return .init() }
            let inset = max(self.footerHeight, self.keyboardHeight - self.view.safeAreaInsets.bottom)
            let insets = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: inset,
                right: 0
            )
            return .init(content: insets, verticalScroll: insets)
        }
        listView.onKeyboardFrameWillChange = { [weak self] keyboardCurrentFrameProvider, keyboardAnimation in
            guard let self = self else { return }
            switch keyboardCurrentFrameProvider.currentFrame(in: self.view) {
            case .overlapping(frame: let frame):
                self.keyboardHeight = frame.height
            case .nonOverlapping, .none:
                self.keyboardHeight = 0
            }
            
            UIViewPropertyAnimator(
                duration: keyboardAnimation.animationDuration,
                curve: keyboardAnimation.animationCurve
            ) {
                self.listView.updateScrollViewInsets()
            }.startAnimation()
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

    @objc private func shrinkFrame() {
        view.frame.size.height -= 22
        reload()
    }

    @objc private func growFrame() {
        guard view.frame.size.height < view.superview!.frame.size
            .height else {
            return
        }
        view.frame.size.height += 22
        reload()
    }

    @objc private func scrollDown() {
        listView.scrollToLastItem(animation: .animated(1.0))
    }

    private var footerHeight: CGFloat = 80
    private var keyboardHeight: CGFloat = 0
    private let listView = ListView()
    private var footerView = BlueprintView()
    private var pagingId = UUID()
    private var isPaging = false

    private func reload()
    {
        configureListView()
        listView.updateScrollViewInsets()
        footerView.frame = footerViewFrame()
        footerView.element = Row(alignment: .center, minimumSpacing: 8) {
            TextField(text: "").box(background: UIColor.white).inset(uniform: 8)
            Button(
                onTap: { [weak self] in
                    guard let self = self else { return }
                    guard self.footerHeight > 80 else { return }
                    self.footerHeight -= 50
                    self.reload()
                },
                wrapping: Label(text: "Decrease height")
            )
            Button(
                onTap: { [weak self] in
                    guard let self = self else { return }
                    self.footerHeight += 50
                    self.reload()
                },
                wrapping: Label(text: "Increase height")
            )
        }
        .box(background: .lightGray)
        .inset(bottom: view.safeAreaInsets.bottom)
        .box(background: .gray)
    }

    private func footerViewFrame() -> CGRect {
        var frame = CGRect()
        frame.size.width = view.bounds.width
        frame.size.height = footerHeight + view.safeAreaInsets.bottom
        frame.origin.y = view.bounds.height - footerHeight - view.safeAreaInsets.bottom
        return frame
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reload()
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

            if messages.count > 15 {
                list.add {
                    Section("paging") {
                        ActivityIndicatorContent(identifierValue: pagingId.uuidString)
                            .with(
                                onDisplay: { info in
                                    // onDisplay can be triggered multiple times so
                                    // we use `isPaging` to avoid paging more than necessary
                                    guard !self.isPaging else { return }
                                    self.isPaging = true
                                    // simulate loading:
                                    Task { [weak self] in
                                        try await Task.sleep(nanoseconds: NSEC_PER_SEC * 3)
                                        self?.addAtTop()
                                        self?.pagingId = UUID()
                                        self?.isPaging = false
                                    }
                                }
                            )
                    }
                }
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

fileprivate struct ActivityIndicatorContent: BlueprintItemContent, Equatable {
    var identifierValue: AnyHashable

    func element(with info: ListableUI.ApplyItemContentInfo) -> BlueprintUI.Element {
        ActivityIndicatorElement().inset(top: 10, bottom: 30)
    }
}

fileprivate struct ActivityIndicatorElement: UIViewElement {
    func makeUIView() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        return activityIndicator
    }

    func updateUIView(_ view: UIActivityIndicatorView, with context: UIViewElementContext) {
        if !context.isMeasuring && !view.isAnimating {
            view.startAnimating()
        }
    }
}
