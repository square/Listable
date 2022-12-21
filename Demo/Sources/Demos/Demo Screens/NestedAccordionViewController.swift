//
//  NestedAccordionViewController.swift
//  Demo
//
//  Created by Will on 12/21/22.
//  Copyright © 2022 Will Li. All rights reserved.
//

import BlueprintUILists
import BlueprintUICommonControls

/// Abstraction of the data model used for the nested hierarchy structure in nested accordion UI.
fileprivate protocol RowTreeModel {

    var name: String { get }

    func getChildren() -> [Self]
}

/// Data model that represents an item category to be used in the nested accordion.
fileprivate struct CategoryModel: RowTreeModel {

    let name: String

    let children: [Child]

    enum Child {
        case model(CategoryModel)
    }

    func getChildren() -> [Self] {
        children.map {
            switch $0 {
            case .model(let model):
                return model
            }
        }
    }
}

/// View model for the nested hierarchy structure.
fileprivate class RowTree<Model: RowTreeModel> {

    typealias OnTap = () -> Void

    var isExpanded : Bool

    let onTap: OnTap

    let model: Model

    let children : [RowTree<Model>]

    func render(atDepth depth: Int) -> [AnyItem] {
        let item = Item(IndentedAccordionRow(text: model.name, indentLevel: depth),
                        selectionStyle: .selectable(isSelected: self.isExpanded),
                        onSelect: { selected in
                            self.isExpanded = true
                            self.onTap()
                        }, onDeselect: { deselected in
                            self.isExpanded = false
                            self.onTap()
                        })

        return [item] + (isExpanded ? self.children.flatMap { $0.render(atDepth: depth + 1) } : [])
    }

    init(_ model: Model, onTap: @escaping OnTap) {
        self.isExpanded = false
        self.onTap = onTap
        self.model = model
        self.children = model.getChildren().map {
            .init($0, onTap: onTap)
        }
    }
}

/// View controller for the nested accordion view.
final class NestedAccordionViewController : ListViewController
{
    private var selectedIndex : Int? = nil

    private var viewModel: [RowTree<CategoryModel>] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = toViewModel()
    }

    override func configure(list: inout ListProperties) {
        list.behavior.selectionMode = .multiple

        #if false
        list.stateObserver.onSelectionChanged { change in
            print("Selection Changed from \(change.old) to \(change.new).")
        }
        #endif

        list("content") { section in
            section += self.viewModel
                            .enumerated()
                            .map { idx, rowTree in
                                rowTree.render(atDepth: 1)
                            }
                            .flatMap { $0 }
        }
    }

    private func toViewModel() -> [RowTree<CategoryModel>] {
        categories.map { RowTree($0, onTap: { [weak self] in
            self?.reload(animated: true)
        }) }
    }
}

/// Row element in the nested accordion view.
fileprivate struct IndentedAccordionRow : BlueprintItemContent, Equatable
{
    let text : String
    let indentLevel: Int

    var identifierValue: String {
        self.text
    }
    
    func element(with info: ApplyItemContentInfo) -> Element {
        Label(text: self.text) {
            $0.alignment = .left
            $0.font = .systemFont(ofSize: 16.0, weight: .semibold)
        }
        .inset(top: 10.0, bottom: 10.0, left: 30.0 * CGFloat(indentLevel), right: 20.0)
        .constrainedTo(height: .atLeast(60.0))
    }
    
    func backgroundElement(with info: ApplyItemContentInfo) -> Element? {
        Overlay(
            elements: [
                Box(backgroundColor: .white),
                Box(backgroundColor: .init(white: 0.90, alpha: 1.0))
                    .constrainedTo(height: .absolute(1.0))
                    .aligned(vertically: .bottom, horizontally: .fill)
            ]
        )
    }

    #if false
    func selectedBackgroundElement(with info: ApplyItemContentInfo) -> Element? {
        Box(backgroundColor: .white(0.8), cornerStyle: .rounded(radius: 15.0))
    }
    #endif
}

// Sample model data
fileprivate let categories: [CategoryModel] = [
    CategoryModel(name: "Fall/Winter 2022", children: [
        .model(CategoryModel(name: "Men", children: [])),
        .model(CategoryModel(name: "Women", children: [])),
        .model(CategoryModel(name: "Accessories", children: [
            .model(CategoryModel(name: "Scarf", children: [])),
            .model(CategoryModel(name: "Gloves", children: [])),
            .model(CategoryModel(name: "Hat", children: [])),
        ])),
    ]),
    CategoryModel(name: "Ready to Wear", children: [
        .model(CategoryModel(name: "Coats", children: [])),
        .model(CategoryModel(name: "Shirts", children: [
            .model(CategoryModel(name: "Long sleeve", children: [])),
            .model(CategoryModel(name: "Short sleeve", children: [])),
            .model(CategoryModel(name: "Sweathshirts", children: [])),
        ])),
        .model(CategoryModel(name: "Pants", children: [])),
    ]),
    CategoryModel(name: "Shoes", children: [
        .model(CategoryModel(name: "Running shoes", children: [])),
        .model(CategoryModel(name: "Others", children: [
            .model(CategoryModel(name: "Running shoes", children: [
                .model(CategoryModel(name: "Casuals", children: [])),
                .model(CategoryModel(name: "Air cushioned", children: [])),
                .model(CategoryModel(name: "High performance", children: [])),
            ])),
            .model(CategoryModel(name: "High heels", children: [])),
            .model(CategoryModel(name: "Hiking boots", children: [])),
        ])),
        .model(CategoryModel(name: "Winter boots", children: [])),
    ]),
    CategoryModel(name: "Bags", children: []),
]
