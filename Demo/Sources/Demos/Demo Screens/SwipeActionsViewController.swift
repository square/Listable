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
    
    private var sections = (0..<2).map { _ in
        (0..<10).map { _ in
            SwipeActionItem(isSaved: Bool.random(), identifier: UUID().uuidString)
        }
    }
    
    override func loadView() {
        self.title = "Swipe Actions"

        self.view = self.blueprintView

        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(toggleDelete)),
        ]

        self.reloadData()
    }

    func reloadData(animated: Bool = false) {

        self.blueprintView.element = List { list in

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
                        swipeActions: self.makeSwipeActions(for: item)
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
                                    equalButtonWidths: true,
                                    minWidth: 80
                                ),
                            mode: .plain
                        ),
                        swipeActions: self.makeSwipeActions(for: item)
                    )
                }
            }
        }
    }

    private func makeSwipeActions(for item: SwipeActionItem) -> SwipeActionsConfiguration {
        
        SwipeActionsConfiguration(performsFirstActionWithFullSwipe: true) {
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
        sections[0].append(SwipeActionItem(isSaved: false, identifier: identifier))
        reloadData(animated: true)
    }

    @objc private func toggleDelete() {
        allowDeleting.toggle()
        reloadData()
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
            return Column(alignment: .fill) {
                Row(alignment: .center, underflow: .spaceEvenly, minimumSpacing: 8) {
                    Column {
                        Label(text: "Item")
                        Label(
                            text: self.item.title,
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

        var title: String { identifier }
    }
}
