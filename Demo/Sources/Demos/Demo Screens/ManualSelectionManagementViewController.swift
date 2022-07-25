//
//  ManualSelectionManagementViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 8/12/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import ListableUI
import UIKit

final class ManualSelectionManagementViewController: ListViewController {
    var selectedIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Deselect", style: .plain, target: self, action: #selector(deselect)),
            UIBarButtonItem(title: "Change", style: .plain, target: self, action: #selector(change)),
        ]
    }

    @objc private func deselect() {
        selectedIndex = nil
        reload(animated: true)
    }

    @objc private func change() {
        if selectedIndex ?? 0 < 10 {
            selectedIndex = (selectedIndex ?? 0) + 1
        } else {
            selectedIndex = 1
        }

        reload(animated: true)
    }

    override func configure(list: inout ListProperties) {
        list.behavior.selectionMode = .single

        list.appearance = .demoAppearance
        list.layout = .demoLayout

        list("content") { section in

            section += (1 ... 10).map { index in
                Item(DemoItem(text: "\(index)")) { item in
                    item.selectionStyle = .selectable(isSelected: index == selectedIndex)

                    item.onSelect = { _ in
                        self.selectedIndex = index
                        self.reload(animated: true)
                    }
                }
            }
        }
    }
}
