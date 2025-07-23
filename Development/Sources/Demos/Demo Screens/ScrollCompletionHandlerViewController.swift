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


/// This demo superclass that is used to showcase the `scrollTo(...)` and `scollToSection(...)`
/// completion handlers. This allows you to demo how it executes in a number of layout situations.
/// This class should not be used directly. Instead, instantiate a subclass.
class ScrollCompletionHandlerViewController : UIViewController {
    
    fileprivate let list = ListView()
    
    fileprivate var sections: [Section] { [] }
    
    fileprivate var animateScroll: Bool = true
    
    fileprivate var scrollPosition: ScrollPosition.Position = .top
    
    fileprivate var ifAlreadyVisible: ScrollPosition.IfAlreadyVisible = .scrollToPosition
    
    private var layoutDirection : LayoutDirection = .vertical
    
    fileprivate lazy var scrollButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Scroll", style: .plain, target: self, action: #selector(performScroll))
    }()
    
    fileprivate lazy var axisButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Axis", style: .plain, target: self, action: #selector(toggleDirection))
    }()
    
    fileprivate lazy var animationsButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Toggle Animations", style: .plain, target: self, action: #selector(toggleAnimations))
    }()
    
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
        updateList()
    }

    private func updateList() {
        list.configure { list in
            list.appearance = .demoAppearance
            list.layout = .demoLayout { tableAppearance in
                tableAppearance.direction = self.layoutDirection
            }
            list.animation = .fast
            list += sections
        }
    }
    
    @objc fileprivate func performScroll() {
        assertionFailure("Override in subclasses.")
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
    
    fileprivate var settingsControls: [UIView] {
        [selectionPanel, alreadyVisiblePanel, positionPanel]
    }
    
    /// This view contains all the configurable scroll settings.
    lazy var settingsPanel: UIView = {
        let stackView = UIStackView(
            arrangedSubviews: settingsControls
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
    
    /// The label and segmented control for selecting the scrolled item/section.
    /// Override in subclasses.
    fileprivate var selectionPanel: UIView {
        assertionFailure("Override in subclasses.")
        return UIView()
    }
    
    /// A helper to add a label before `view`.
    fileprivate func titledView(_ view: UIView, title: String) -> UIView {
        let label = UILabel()
        label.text = title
        label.widthAnchor.constraint(equalToConstant: 125).isActive = true
        label.textAlignment = .right
        let stackView = UIStackView(arrangedSubviews: [label, view])
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }
}

/// A demo for showcasing scrolling to a particular item.
class ScrollToItemCompletionHandlerViewController: ScrollCompletionHandlerViewController {
    
    private lazy var items: [Item<SimpleScrollItem>] = {
        Array(0...100).map {
            Item(SimpleScrollItem(text: "Item \($0)"))
        }
    }()
    
    override var sections: [Section] {
        [Section("items", items: items)]
    }
    
    override var selectionPanel: UIView { itemSegmentedControl }
    
    private lazy var itemSegmentedControl: UIView = {
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
    
    private var scrolledItem = Item(SimpleScrollItem(text: "Item 50"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Fully add support for programmatic scrolling in horizontal layouts.
        // The axisButton is used in this demo because there are no section headers.
        navigationItem.rightBarButtonItems = [scrollButton, animationsButton, axisButton]
    }
    
    override func performScroll() {
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
}

/// A demo for showcasing scrolling to a particular section.
class ScrollToSectionCompletionHandlerViewController: ScrollCompletionHandlerViewController {
    
    override var sections: [Section] { _sections }
    
    private lazy var _sections: [Section] = {
        (0...2).map { sectionIndex in
            Section(
                "Section \(sectionIndex)",
                items: {
                    (0...100).map { itemIndex in
                        Item(SimpleScrollItem(text: "Section \(sectionIndex) - Item \(itemIndex)"))
                    }
                },
                header: {
                    DemoHeader(title: "Section \(sectionIndex) Header")
                },
                footer: {
                    DemoFooter(text: "Section \(sectionIndex) Footer")
                }
            )
        }
    }()
    
    override var selectionPanel: UIView { sectionSegmentedControl }
    
    private lazy var sectionSegmentedControl: UIView = {
        let control = UISegmentedControl(
            items: [
                UIAction(title: "0") { [weak self] _ in
                    self?.scrolledSection = Section.identifier(with: "Section 0")
                },
                UIAction(title: "1") { [weak self] _ in
                    self?.scrolledSection = Section.identifier(with: "Section 1")
                },
                UIAction(title: "2") { [weak self] _ in
                    self?.scrolledSection = Section.identifier(with: "Section 2")
                }
            ]
        )
        control.selectedSegmentIndex = 1
        return titledView(control, title: "Section")
    }()
    
    private var sectionPosition: SectionPosition = .top
    
    override var settingsControls: [UIView] {
        super.settingsControls + [sectionPositionControl]
    }
    
    /// The label and segmented control for selecting the section position, which powers
    /// whether the header or footer will be positioned.
    lazy var sectionPositionControl: UIView = {
        let control = UISegmentedControl(
            items: [
                UIAction(title: "Top/Header") { [weak self] _ in
                    self?.sectionPosition = .top
                },
                UIAction(title: "Bottom/Footer") { [weak self] _ in
                    self?.sectionPosition = .bottom
                },
            ]
        )
        control.selectedSegmentIndex = 0
        return titledView(control, title: "Supp. View")
    }()
    
    private var scrolledSection: Section.Identifier = Section.identifier(with: "Section 1")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Fully add support for programmatic scrolling in horizontal layouts.
        // Until then, the axisButton is not used in this demo.
        navigationItem.rightBarButtonItems = [scrollButton, animationsButton]
    }
    
    override func performScroll() {
        list.scrollToSection(
            with: scrolledSection,
            sectionPosition: sectionPosition,
            scrollPosition: ScrollPosition(
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
