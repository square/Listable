//
//  RetailGridViewController.swift
//  Demo
//
//  Created by Gabriel Hernandez Ontiveros on 2021-07-23.
//  Copyright © 2021 Kyle Van Essen. All rights reserved.
//

import BlueprintUILists
import ListableUI
import UIKit

final class RetailGridViewController: ListViewController {
    override func configure(list: inout ListProperties) {
        list += Section("default") { section in
            list.appearance = .demoAppearance

            if self.infiniteScollOn {
                list.layout = .retailGridDemo(columns: 5)
            } else {
                list.layout = .retailGridDemo(columns: 5, rows: .rows(5))
            }

            section += Item(DemoItem(text: "Single")) { item in
                item.layouts.retailGrid = RetailGridAppearance.ItemLayout(
                    origin: .init(x: 0, y: 0), size: .single
                )
            }

            section += Item(DemoItem(text: "Wide")) { item in
                item.layouts.retailGrid = RetailGridAppearance.ItemLayout(
                    origin: .init(x: 1, y: 0), size: .wide
                )
            }

            section += Item(DemoItem(text: "Tall")) { item in
                item.layouts.retailGrid = RetailGridAppearance.ItemLayout(
                    origin: .init(x: 3, y: 0), size: .tall
                )
            }

            section += Item(DemoItem(text: "Big")) { item in
                item.layouts.retailGrid = RetailGridAppearance.ItemLayout(
                    origin: .init(x: 1, y: 1), size: .big
                )
            }

            section += Item(DemoItem(text: "Single")) { item in
                item.layouts.retailGrid = RetailGridAppearance.ItemLayout(
                    origin: .init(x: 4, y: 4), size: .single
                )
            }

            section += Item(DemoItem(text: "Single")) { item in
                item.layouts.retailGrid = RetailGridAppearance.ItemLayout(
                    origin: .init(x: 0, y: 1), size: .single
                )
            }

            section += Item(DemoItem(text: "Single")) { item in
                item.layouts.retailGrid = RetailGridAppearance.ItemLayout(
                    origin: .init(x: 0, y: 2), size: .single
                )
            }

            section += Item(DemoItem(text: "Single")) { item in
                item.layouts.retailGrid = RetailGridAppearance.ItemLayout(
                    origin: .init(x: 0, y: 3), size: .single
                )
            }

            section += Item(DemoItem(text: "Single")) { item in
                item.layouts.retailGrid = RetailGridAppearance.ItemLayout(
                    origin: .init(x: 0, y: 4), size: .single
                )
            }

            section += Item(DemoItem(text: "Single")) { item in
                item.layouts.retailGrid = RetailGridAppearance.ItemLayout(
                    origin: .init(x: 4, y: 0), size: .single
                )
            }

            section += Item(DemoItem(text: "Single")) { item in
                item.layouts.retailGrid = RetailGridAppearance.ItemLayout(
                    origin: .init(x: 0, y: 5), size: .single
                )
            }

            section += Item(DemoItem(text: "Single")) { item in
                item.layouts.retailGrid = RetailGridAppearance.ItemLayout(
                    origin: .init(x: 1, y: 5), size: .single
                )
            }

            section += Item(DemoItem(text: "Single")) { item in
                item.layouts.retailGrid = RetailGridAppearance.ItemLayout(
                    origin: .init(x: 0, y: 10), size: .single
                )
            }

            section += Item(DemoItem(text: "Single")) { item in
                item.layouts.retailGrid = RetailGridAppearance.ItemLayout(
                    origin: .init(x: 1, y: 10), size: .single
                )
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Switch scrolling", style: .plain, target: self, action: #selector(swapLayout))
    }

    private var infiniteScollOn: Bool = false

    @objc func swapLayout() {
        infiniteScollOn.toggle()
        reload(animated: true)
    }
}
