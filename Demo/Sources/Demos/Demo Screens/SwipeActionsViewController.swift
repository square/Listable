//
//  DemoTableViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 3/24/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//
import ListableUI
import BlueprintUILists
import BlueprintUI
import BlueprintUICommonControls
import UIKit

final class SwipeActionsViewController: UIViewController  {
    private let blueprintView = BlueprintView()

    private var allowDeleting: Bool = true
    private static var universalSwipeActionsEnabled: Bool = true
    
    private var sections = generateSections()
    
    private static func generateSections() -> [[SwipeActionsViewController.SwipeActionItem]] {
        (0..<2).map { _ in
            (0..<20).map {
                SwipeActionItem(
                    isSaved: Bool.random(),
                    identifier: UUID().uuidString,
                    title: "Item \($0)",
                    shouldConfigureLeadingSwipeActions: universalSwipeActionsEnabled || $0.isMultiple(of: 2),
                    shouldConfigureTrailingSwipeActions: universalSwipeActionsEnabled ||  $0.isMultiple(of: 3)
                )
            }
        }
    }
    
    override func loadView() {
        self.title = "Swipe Actions"

        self.view = self.blueprintView

        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(toggleDelete)),
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(toggleGlobalSwipeActions))
        ]

        self.reloadData()
    }

    func reloadData(animated: Bool = false) {

        self.blueprintView.element = List { list in
            
            list.appearance = .demoAppearance

            list.animatesChanges = animated
            
            list.layout = .table {
                
                $0.bounds = .init(
                    padding: UIEdgeInsets(
                        top: 0.0,
                        left: self.view.safeAreaInsets.left + 4,
                        bottom: 0.0,
                        right: self.view.safeAreaInsets.right + 4
                    )
                )
                
                $0.layout.itemSpacing = 4
            }

            list += Section("standardSwipeActionItems") { section in
                section.header = DemoHeader(title: "Standard Style Swipeable Items")
                section += self.sections[0].map { item in
                    Item(
                        SwipeActionsDemoItem(
                            item: item,
                            mode: .roundedWithBorder
                        ),
                        leadingSwipeActions: self.leadingSwipeActions(for: item),
                        trailingSwipeActions: self.trailingSwipeActions(for: item)
                    )
                }
            }
            
            // The style can be customized at the environment level via
            // `list.environment.swipeActionsViewStyle` or at the content level
            // as demonstrated below.

            list += Section("customSwipeActionItems") { section in
                section.header = DemoHeader(title: "Custom Style Swipeable Items")
                section += self.sections[1].map { item in
                    Item(
                        SwipeActionsDemoItem(
                            item: item,
                            swipeActionsStyle:
                                .init(
                                    containerCornerRadius: 6,
                                    buttonSizing: .equalWidth,
                                    minWidth: 80
                                ),
                            mode: .plain
                        ),
                        leadingSwipeActions: self.leadingSwipeActions(for: item),
                        trailingSwipeActions: self.trailingSwipeActions(for: item)
                    )
                }
            }
        }
    }
    
    private func leadingSwipeActions(for item: SwipeActionItem) -> SwipeActionsConfiguration? {
        guard item.shouldConfigureLeadingSwipeActions else { return nil }
        
        return SwipeActionsConfiguration(performsFirstActionWithFullSwipe: true) {
            SwipeAction(
                title: nil,
                accessibilityLabel: "Open Video",
                backgroundColor: .systemBlue,
                image: UIImage(systemName: "video.fill")
            ) { [weak self] expandActions in
                self?.open(item: item) {
                    expandActions(false)
                }
            }
            
            SwipeAction(
                title: nil,
                accessibilityLabel: "Share",
                backgroundColor: .systemOrange,
                image: UIImage(systemName: "square.and.arrow.up.fill")
            ) { [weak self] expandActions in
                self?.share(item: item) {
                    expandActions(false)
                }
            }
        }
    }

    private func trailingSwipeActions(for item: SwipeActionItem) -> SwipeActionsConfiguration? {
        guard item.shouldConfigureTrailingSwipeActions else { return nil }
        
        return SwipeActionsConfiguration(performsFirstActionWithFullSwipe: true) {
            if allowDeleting {
                SwipeAction(
                    title: "Delete",
                    backgroundColor: UIColor(red: 0.80, green: 0, blue: 0.137, alpha: 1.0),
                    image: nil
                ) { [weak self] expandActions in
                    self?.confirmDelete(item: item, expandActions: expandActions)
                }
            }
            
            SwipeAction(
                title: item.isSaved ? "Unsave" : "Save",
                backgroundColor: .black.withAlphaComponent(0.05),
                tintColor: UIColor(red: 0, green: 0.353, blue: 0.851, alpha: 1.0),
                image: item.isSaved ? nil : UIImage(named: "bookmark")!.withRenderingMode(.alwaysTemplate)
            ) { [weak self] expandActions in
                self?.toggleSave(item: item)
                expandActions(false)
            }
        }
    }

    @objc private func addItem() {
        let identifier = UUID().uuidString
        sections[0].append(
            SwipeActionItem(
                isSaved: false,
                identifier: identifier,
                title: "New Item",
                shouldConfigureLeadingSwipeActions: true,
                shouldConfigureTrailingSwipeActions: true
            )
        )
        reloadData(animated: true)
    }

    @objc private func toggleDelete() {
        allowDeleting.toggle()
        reloadData()
    }

    @objc func toggleGlobalSwipeActions() {
        Self.universalSwipeActionsEnabled.toggle()
        sections = Self.generateSections()
        reloadData(animated: true)
    }

    private func confirmDelete(item: SwipeActionItem, expandActions: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: item.title, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            expandActions(false)
        })

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            
            for i in self.sections.indices {
                self.sections[i].removeAll(where: { $0.identifier == item.identifier })
            }
            self.reloadData(animated: true)
            expandActions(true)
        })

        present(alert, animated: true, completion: nil)
    }

    private func toggleSave(item: SwipeActionItem) {
        for i in sections.indices {
            guard let index = sections[i].firstIndex(of: item) else { continue }
            sections[i][index].isSaved.toggle()
        }
        reloadData(animated: true)
    }
    
    private let shareURL = URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!
    
    private func share(item: SwipeActionItem, completion: (() -> Void)? = nil) {
        let activityController = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
        present(activityController, animated: true, completion: completion)
    }
    
    private func open(item: SwipeActionItem, completion: (() -> Void)? = nil) {
        UIApplication.shared.open(shareURL) { _ in
            completion?()
        }
    }

    struct SwipeActionsDemoItem: BlueprintItemContent, Equatable {
        enum Mode {
            case plain
            case roundedWithBorder
        }
        
        var item: SwipeActionItem
        var swipeActionsStyle: SwipeActionsView.Style?
        var mode: Mode

        var identifierValue: String {
            self.item.identifier
        }

        func overlayDecorationElement(with info: ApplyItemContentInfo) -> Element? {
            switch mode {
            case .plain:
                return nil
            case .roundedWithBorder:
                return Empty()
                    .box(background: .clear, corners: .rounded(radius: 6), borders: .solid(color: .black, width: 2))
            }
        }
        
        func contentAreaViewProperties(with info: ApplyItemContentInfo) -> ViewProperties {
            switch mode {
            case .plain:
                return .init()
            case .roundedWithBorder:
                return .init(clipsToBounds: true, cornerStyle: .rounded(radius: 6))
            }
        }
        
        func backgroundElement(with info: ApplyItemContentInfo) -> Element? {
            switch mode {
            case .plain:
                return nil
            case .roundedWithBorder:
                return Empty()
                    .box(
                        background: .white,
                        corners: .rounded(radius: 6),
                        shadow: .simple(
                            radius: 3,
                            opacity: 0.2,
                            offset: .init(width: 0, height: 2),
                            color: .black
                        )
                    )
            }
        }
        
        func element(with info : ApplyItemContentInfo) -> Element {
            Column(alignment: .fill) {
                Row(alignment: .center, underflow: .spaceEvenly, minimumSpacing: 8) {
                    Column {
                        Label(text: item.title)
                        
                        if !item.universalSwipeActionsEnabled {
                            Label(
                                text: "Leading items: \(item.shouldConfigureLeadingSwipeActions)",
                                configure: { label in
                                    label.font = .systemFont(ofSize: 10)
                                }
                            )
                            
                            Label(
                                text: "Trailing items: \(item.shouldConfigureTrailingSwipeActions)",
                                configure: { label in
                                    label.font = .systemFont(ofSize: 10)
                                }
                            )
                        }
                        
                        Label(
                            text: item.subtitle,
                            configure: { label in
                                label.font = .systemFont(ofSize: 10)
                            }
                        )
                    }
                    
                    let bookmark = UIImage(named: "bookmark")!
                    
                    if item.isSaved {
                        Image(image: bookmark, contentMode: .center)
                    } else {
                        Spacer(size: bookmark.size)
                    }
                }
                .inset(uniform: 16)
            }
            .accessibilityElement(label: "Swipeable Item", value: item.title, traits: [.button])
        }
    }

    struct SwipeActionItem: Equatable, Hashable {
        var isSaved: Bool
        var identifier: String
        var title: String
        var subtitle: String { identifier }
        var shouldConfigureLeadingSwipeActions: Bool
        var shouldConfigureTrailingSwipeActions: Bool
        var universalSwipeActionsEnabled: Bool { SwipeActionsViewController.universalSwipeActionsEnabled }
    }
}
