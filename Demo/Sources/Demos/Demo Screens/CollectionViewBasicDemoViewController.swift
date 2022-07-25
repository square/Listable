//
//  CollectionViewBasicDemoViewController.swift
//  ListableUI-DemoApp
//
//  Created by Kyle Van Essen on 7/9/19.
//

import UIKit

import BlueprintUILists
import ListableUI

final class CollectionViewBasicDemoViewController: UIViewController {
    var rows: [[DemoItem]] = [
        [
            DemoItem(text: "Nam sit amet imperdiet odio. Duis sed risus aliquet, finibus ex in, maximus diam. Mauris dapibus cursus rhoncus. Fusce faucibus velit at leo vestibulum, a pharetra dui interdum."),
            DemoItem(text: "Row 2"),
        ],
        [
            DemoItem(text: "Row 1"),
            DemoItem(text: "Row 2"),
            DemoItem(text: "Row 3"),
        ],
    ]

    var showsOverscrollFooter: Bool = true
    var showsSectionHeaders: Bool = true
    var isVertical: Bool = true

    let listView = ListView()

    override func loadView() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "UF", style: .plain, target: self, action: #selector(cycleUnderflow)),
            UIBarButtonItem(title: "OS", style: .plain, target: self, action: #selector(toggleOverscroll)),
            UIBarButtonItem(title: "SH", style: .plain, target: self, action: #selector(toggleSectionHeaders)),
            UIBarButtonItem(title: "D", style: .plain, target: self, action: #selector(toggleDirection)),

            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeItem)),
        ]

        view = listView

        listView.appearance = .demoAppearance
        listView.layout = .demoLayout

        updateTable(animated: false)
    }

    func updateTable(animated: Bool) {
        listView.configure { list in

            if self.showsOverscrollFooter {
                list.content.overscrollFooter = DemoHeader(title: "Thanks for using Listable!!")
            }

            list.layout = .demoLayout {
                $0.direction = self.isVertical ? .vertical : .horizontal
            }

            list.animatesChanges = animated

            list += self.rows.map { sectionRows in
                Section("Demo Section") { section in

                    section.layouts.table.columns = .init(count: 2, spacing: 10.0)

                    if self.showsSectionHeaders {
                        section.header = DemoHeader(title: "Section Header")
                    } else {
                        section.header = DemoHeader2(title: "Section Header")
                    }

                    section.footer = DemoFooter(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi non luctus sem, eu consectetur ipsum. Curabitur malesuada cursus ante.")

                    section += sectionRows
                }
            }
        }
    }

    @objc func toggleOverscroll() {
        showsOverscrollFooter.toggle()

        updateTable(animated: true)
    }

    @objc func toggleSectionHeaders() {
        showsSectionHeaders.toggle()

        updateTable(animated: true)
    }

    @objc func toggleDirection() {
        isVertical.toggle()

        updateTable(animated: true)
    }

    @objc func addItem() {
        rows[0].insert(DemoItem(text: Date().description), at: 0)
        rows[1].insert(DemoItem(text: Date().description), at: 0)

        updateTable(animated: true)
    }

    @objc func removeItem() {
        if rows[0].isEmpty == false {
            rows[0].removeLast()
        }

        if rows[1].isEmpty == false {
            rows[1].removeLast()
        }

        updateTable(animated: true)
    }

    @objc func cycleUnderflow() {
        UIView.animate(withDuration: 0.3) {
            self.listView.behavior.underflow.alignment = {
                switch self.listView.behavior.underflow.alignment {
                case .top: return .center
                case .center: return .bottom
                case .bottom: return .top
                }
            }()
        }
    }
}
