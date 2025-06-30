//
//  ScrollCompletionHandlerViewController.swift
//  Demo
//
//  Created by John Newman on 6/17/25.
//

import BlueprintUI
import BlueprintUICommonControls
import BlueprintUILists
import ListableUI
import UIKit


/// This demo showcases the scrollTo(...) completion handler. It allows you to demo
/// how it executes in a number of layout situations.
class ScrollCompletionHandlerViewController : UIViewController {
    
    private let list = ListView()
    
    private var animateScroll: Bool = true
    
    private var scrollPosition: ScrollPosition.Position = .top
    
    private var ifAlreadyVisible: ScrollPosition.IfAlreadyVisible = .scrollToPosition
    
    private var scrolledItem = Item(SimpleScrollItem(text: "Item 50"))
    
    private var layoutDirection : LayoutDirection = .vertical
    
    private lazy var scrollButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Scroll", style: .plain, target: self, action: #selector(scrollToItem))
    }()
    
    private lazy var axisButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Axis", style: .plain, target: self, action: #selector(toggleDirection))
    }()
    
    private lazy var animationsButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Toggle Animations", style: .plain, target: self, action: #selector(toggleAnimations))
    }()
    
    private var items: [Item<SimpleScrollItem>] = Array(0...100).map {
        Item(SimpleScrollItem(text: "Item \($0)"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let stackView = UIStackView(arrangedSubviews: [list, settingsPanel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 0
        view.addSubview(stackView)
        view.backgroundColor = .secondarySystemBackground
        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: stackView.topAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
        navigationItem.rightBarButtonItems = [scrollButton, animationsButton, axisButton]
        updateList()
    }

    private func updateList() {
        list.configure { list in
            list.appearance = .demoAppearance
            list.layout = .demoLayout { tableAppearance in
                tableAppearance.direction = self.layoutDirection
            }
            list.animation = .fast
            list += Section("items", items: items)
        }
    }
    
    @objc private func scrollToItem() {
        list.scrollTo(
            item: scrolledItem,
            position: ScrollPosition(
                position: scrollPosition,
                ifAlreadyVisible: ifAlreadyVisible
            ),
            animated: animateScroll,
            completion: { changes in
                let sortedItems = changes.positionInfo.visibleItems
                    .map { "\($0.identifier) "}
                    .sorted()
                print("Scroll completion: \(sortedItems)")
            }
        )
    }
    
    @objc func toggleAnimations() {
        animateScroll.toggle()
        print("Scroll animations are \(animateScroll ? "on" : "off").")
    }
    
    @objc func toggleDirection() {
        if layoutDirection == .horizontal {
            layoutDirection = .vertical
        } else {
            layoutDirection = .horizontal
        }
        updateList()
    }
    
    /// This view contains all the configurable scroll settings.
    lazy var settingsPanel: UIView = {
        let stackView = UIStackView(
            arrangedSubviews: [itemSelectionPanel, alreadyVisiblePanel, positionPanel]
        )
        stackView.axis = .vertical
        stackView.spacing = 8
        let containerView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 16),
            containerView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        ])
        return containerView
    }()
    
    /// The label and segmented control for selecting the scroll position.
    lazy var positionPanel: UIView = {
        let control = UISegmentedControl(
            items: [
                UIAction(title: "Top") { [weak self] _ in
                    self?.scrollPosition = .top
                },
                UIAction(title: "Centered") { [weak self] _ in
                    self?.scrollPosition = .centered
                },
                UIAction(title: "Bottom") { [weak self] _ in
                    self?.scrollPosition = .bottom
                }
            ]
        )
        control.selectedSegmentIndex = 0
        return titledView(control, title: "Position")
    }()
    
    /// The label and segmented control for selecting the behavior of an already-visible
    /// item
    lazy var alreadyVisiblePanel: UIView = {
        let control = UISegmentedControl(
            items: [
                UIAction(title: "Do nothing") { [weak self] _ in
                    self?.ifAlreadyVisible = .doNothing
                },
                UIAction(title: "Scroll to position") { [weak self] _ in
                    self?.ifAlreadyVisible = .scrollToPosition
                },
            ]
        )
        control.selectedSegmentIndex = 1
        return titledView(control, title: "If Visbile")
    }()
    
    /// The label and segmented control for selecting the scrolled item.
    lazy var itemSelectionPanel: UIView = {
        let control = UISegmentedControl(
            items: [
                UIAction(title: "1") { [weak self] _ in
                    self?.scrolledItem = Item(SimpleScrollItem(text: "Item 1"))
                },
                UIAction(title: "50") { [weak self] _ in
                    self?.scrolledItem = Item(SimpleScrollItem(text: "Item 50"))
                },
                UIAction(title: "99") { [weak self] _ in
                    self?.scrolledItem = Item(SimpleScrollItem(text: "Item 99"))
                }
            ]
        )
        control.selectedSegmentIndex = 1
        return titledView(control, title: "Selection")
    }()
    
    /// A helper to add a label before `view`.
    private func titledView(_ view: UIView, title: String) -> UIView {
        let label = UILabel()
        label.text = title
        label.widthAnchor.constraint(equalToConstant: 100).isActive = true
        label.textAlignment = .right
        let stackView = UIStackView(arrangedSubviews: [label, view])
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }
}

struct SimpleScrollItem : BlueprintItemContent, Equatable {
    var text : String

    var identifierValue: String {
        text
    }

    func element(with info : ApplyItemContentInfo) -> Element {
        Box(
            backgroundColor: .white,
            cornerStyle: .rounded(radius: 6.0),
            borderStyle: .solid(color: .white(0.9), width: 2.0),
            wrapping: Inset(
                uniformInset: 10.0,
                wrapping: Label(text: self.text)
            )
        )
    }
}
