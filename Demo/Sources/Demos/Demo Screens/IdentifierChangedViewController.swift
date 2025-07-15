//
//  IdentifierChangedViewController.swift
//  Demo
//
//  Created by Sebastian Celis on 7/2/25.
//  Copyright © 2025 Kyle Van Essen. All rights reserved.
//

import Foundation
import ListableUI
import BlueprintUI
import BlueprintUICommonControls
import BlueprintUILists
import UIKit

final class IdentifierChangedViewController : ListViewController {

    var identifier = UUID() {
        didSet {
            reload(animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Change", style: .plain, target: self, action: #selector(change)),
        ]
    }

    @objc private func change() {
        identifier = UUID()
    }

    override func configure(list: inout ListProperties) {
        list.identifier = identifier
        list.layout = .demoLayout

        list("items") { section in
            section += (1...100).map { number in
                Item(ItemRow(identifier: identifier, number: number)) { item in
                    item.selectionStyle = .tappable
                }
            }
        }
    }
}

fileprivate struct ItemRow : BlueprintItemContent, Equatable {
    var identifier : UUID
    var number : Int

    var name : String {
        "Row \(number) \(identifier.uuidString.prefix(8))"
    }

    var identifierValue: String {
        "\(number)"
    }

    func element(with info: ApplyItemContentInfo) -> Element {
        Row { row in
            row.verticalAlignment = .center

            row.addFlexible(child: Label(text: self.name) { label in
                label.font = .systemFont(ofSize: 18.0, weight: .semibold)
            })
        }
        .inset(uniform: 10.0)
        .box(background: .white(0.95), corners: .rounded(radius: 10))
    }
}
