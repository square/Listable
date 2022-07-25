//
//  ItemizationEditorViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 10/25/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import BlueprintUI
import BlueprintUICommonControls
import BlueprintUILists

import ListableUI

final class ItemizationEditorViewController: UIViewController {
    let blueprintView: BlueprintView = .init()

    override func loadView() {
        view = blueprintView

        updateList()
    }

    func updateList() {
        blueprintView.element = list
    }

    var availableOptions: AvailableOptions = DemoData.availableOptions

    var itemization: Itemization = DemoData.itemization {
        didSet {
            updateList()
        }
    }

    enum SectionIdentifier: Hashable {
        case variations
        case modifier(String)
        case discounts
        case taxes
    }

    var list: List {
        List { list in

            list.appearance = self.listAppearance
            list.layout = self.listLayout

            list.behavior.selectionMode = .multiple

            list.behavior.underflow = .init(
                alwaysBounce: true,
                alignment: .top
            )
        } sections: {
            let variationsTitle: String = {
                if let selected = self.itemization.variations.selected.first {
                    return selected.name
                } else {
                    return self.itemization.variations.name
                }
            }()

            let footerText: String = {
                if self.itemization.variations.selected.isEmpty {
                    return "Choose at least one variation"
                } else {
                    return "You chose too many!!"
                }
            }()

            Section(SectionIdentifier.variations) { section in

                section.layouts.table.columns = .init(count: 2, spacing: 20.0)
                section.header = Header(title: variationsTitle)
                section.footer = Footer(text: footerText)

                section += self.itemization.variations.all.map { variation in
                    Item(
                        ChoiceItem(title: variation.name, detail: "$0.00"),
                        selectionStyle: .selectable(isSelected: self.itemization.variations.selected.contains(variation)),
                        onSelect: { _ in
                            self.itemization.variations.select(modifier: variation)
                        },
                        onDeselect: { _ in
                            self.itemization.variations.deselect(modifier: variation)
                        }
                    )
                }
            }

            itemization.modifiers.map { set in
                Section(SectionIdentifier.modifier(set.name)) { section in

                    section.layouts.table.columns = .init(count: 2, spacing: 20.0)

                    section.header = Header(title: set.name)
                    section.footer = Footer(text: "Choose modifiers")

                    section += set.all.map { modifier in
                        Item(
                            ChoiceItem(title: modifier.name, detail: "$0.00"),
                            selectionStyle: .selectable(isSelected: false),
                            onSelect: { _ in

                            },
                            onDeselect: { _ in
                            }
                        )
                    }
                }
            }

            Section(SectionIdentifier.discounts) { section in

                section.layouts.table.columns = .init(count: 2, spacing: 20.0)
                section.header = Header(title: "Discounts")

                section += self.availableOptions.allDiscounts.map { discount in
                    ToggleItem(content: .init(title: discount.name, detail: "$0.00", isOn: self.itemization.has(discount))) { isOn in
                        if isOn {
                            self.itemization.add(discount)
                        } else {
                            self.itemization.remove(discount)
                        }
                    }
                }
            }

            Section(SectionIdentifier.taxes) { section in

                section.layouts.table.columns = .init(count: 2, spacing: 20.0)
                section.header = Header(title: "Taxes")

                section += self.availableOptions.allTaxes.map { tax in
                    ToggleItem(content: .init(title: tax.name, detail: "$0.00", isOn: self.itemization.has(tax))) { isOn in
                        if isOn {
                            self.itemization.add(tax)
                        } else {
                            self.itemization.remove(tax)
                        }
                    }
                }
            }
        }
    }

    var listAppearance: Appearance {
        Appearance(backgroundColor: .white)
    }

    var listLayout: LayoutDescription {
        .table {
            $0.stickySectionHeaders = false

            $0.bounds = .init(
                padding: UIEdgeInsets(top: 30.0, left: 30.0, bottom: 30.0, right: 30.0),
                width: .atMost(600.0)
            )

            $0.layout = .init(
                interSectionSpacingWithNoFooter: 20.0,
                interSectionSpacingWithFooter: 20.0,
                sectionHeaderBottomSpacing: 0.0,
                itemSpacing: 20.0,
                itemToSectionFooterSpacing: 20.0
            )
        }
    }
}

struct Header: BlueprintHeaderFooterContent, Equatable {
    var title: String

    var elementRepresentation: Element {
        Inset(insets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 10.0, right: 0.0), wrapping: Label(text: title) { label in
            label.font = .systemFont(ofSize: 30.0, weight: .bold)
        })
    }
}

struct Footer: BlueprintHeaderFooterContent, Equatable {
    var text: String

    var elementRepresentation: Element {
        Label(text: text) { label in
            label.font = .systemFont(ofSize: 14.0, weight: .regular)
            label.alignment = .center
        }
    }
}

struct ChoiceItem: BlueprintItemContent, Equatable {
    var title: String
    var detail: String

    // MARK: BlueprintItemElement

    func element(with info: ApplyItemContentInfo) -> Element {
        var box = Box(
            cornerStyle: .rounded(radius: 8.0),
            wrapping: Inset(
                uniformInset: 10.0,
                wrapping: Row { row in
                    row.verticalAlignment = .center

                    row.add(child: Label(text: self.title) { label in
                        label.font = .systemFont(ofSize: 18.0, weight: .semibold)
                    })
                    row.add(child: Label(text: self.detail) { label in
                        label.font = .systemFont(ofSize: 18.0, weight: .regular)
                    })
                }
            )
        )

        if info.state.isSelected {
            box.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
            box.borderStyle = .solid(color: .init(white: 0.6, alpha: 1.0), width: 2.0)
            box.shadowStyle = .simple(radius: 2.0, opacity: 0.25, offset: .init(width: 0, height: 1.0), color: .black)
        } else {
            box.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
            box.borderStyle = .solid(color: .init(white: 0.9, alpha: 1.0), width: 2.0)
        }

        return box
    }

    var identifierValue: String {
        title
    }
}

struct ToggleItem: BlueprintItemContent {
    var content: Content

    struct Content: Equatable {
        var title: String
        var detail: String

        var isOn: Bool
    }

    var onToggle: (Bool) -> Void

    func isEquivalent(to other: ToggleItem) -> Bool {
        content == other.content
    }

    var identifierValue: String {
        content.title
    }

    func element(with _: ApplyItemContentInfo) -> Element {
        var box = Box(
            cornerStyle: .rounded(radius: 8.0),
            wrapping: Inset(
                uniformInset: 10.0,
                wrapping: Row { row in
                    row.horizontalUnderflow = .growProportionally
                    row.verticalAlignment = .center

                    row.add(growPriority: 0.0, child: Label(text: self.content.title) { label in
                        label.font = .systemFont(ofSize: 18.0, weight: .semibold)
                    })

                    row.add(growPriority: 1.0, child: Spacer(size: .init(width: 10.0, height: 0.0)))

                    row.add(growPriority: 0.0, child: Label(text: self.content.detail) { label in
                        label.font = .systemFont(ofSize: 18.0, weight: .regular)
                    })

                    row.add(growPriority: 0.0, child: Spacer(size: .init(width: 10.0, height: 0.0)))

                    row.add(growPriority: 0.0, child: Toggle(isOn: self.content.isOn, onToggle: self.onToggle))
                }
            )
        )

        box.backgroundColor = .clear
        box.borderStyle = .solid(color: .init(white: 0.9, alpha: 1.0), width: 2.0)

        return box
    }
}

//

// MARK: Demo Data

//

enum DemoData {
    static var availableOptions: AvailableOptions {
        AvailableOptions(
            allDiscounts: [
                Discount(name: "Employees", type: .percent(5.0)),
                Discount(name: "Friends & Family", type: .percent(10.0)),
                Discount(name: "5% Off", type: .percent(5.0)),
                Discount(name: "10% Off", type: .percent(10.0)),
                Discount(name: "20% Off", type: .percent(20.0)),
                Discount(name: "$10 Off", type: .amount(Money(cents: 1000, currency: .USD))),
                Discount(name: "$15 Off", type: .amount(Money(cents: 1500, currency: .USD))),
            ],
            allTaxes: [
                Tax(name: "VAT 5%", percent: 5.0),
                Tax(name: "VAT 10%", percent: 10.0),
                Tax(name: "VAT 15%", percent: 15.0),
                Tax(name: "Healthy SF", percent: 3.7),
                Tax(name: "GST", percent: 7.0),
                Tax(name: "PST", percent: 7.0),
            ]
        )
    }

    static var itemization: Itemization {
        Itemization(
            variations: ModifierSet(
                name: "Variations",
                all: [
                    ModifierSet.Modifier(name: "Small", price: Money(cents: 500, currency: .USD)),
                    ModifierSet.Modifier(name: "Medium", price: Money(cents: 1000, currency: .USD)),
                    ModifierSet.Modifier(name: "Large", price: Money(cents: 1500, currency: .USD)),
                    ModifierSet.Modifier(name: "Extra Large", price: Money(cents: 2000, currency: .USD)),
                ],
                selected: [],
                selectionType: .single
            ),
            modifiers: [
                ModifierSet(
                    name: "Style",
                    all: [
                        ModifierSet.Modifier(name: "New York", price: Money(cents: 400, currency: .USD)),
                        ModifierSet.Modifier(name: "Neopolitan", price: Money(cents: 200, currency: .USD)),
                        ModifierSet.Modifier(name: "Sicilian", price: Money(cents: 500, currency: .USD)),
                        ModifierSet.Modifier(name: "Deep Dish", price: Money(cents: 500, currency: .USD)),
                        ModifierSet.Modifier(name: "California", price: Money(cents: 400, currency: .USD)),
                        ModifierSet.Modifier(name: "Pan Pizza", price: Money(cents: 300, currency: .USD)),
                    ],
                    selected: [],
                    selectionType: .single
                ),
                ModifierSet(
                    name: "Toppings",
                    all: [
                        ModifierSet.Modifier(name: "Artichoke", price: nil),
                        ModifierSet.Modifier(name: "Bacon", price: nil),
                        ModifierSet.Modifier(name: "Banana Peppers", price: nil),
                        ModifierSet.Modifier(name: "Black Olives", price: nil),
                        ModifierSet.Modifier(name: "Cheese", price: nil),
                        ModifierSet.Modifier(name: "Green Olives", price: nil),
                        ModifierSet.Modifier(name: "Green Peppers", price: nil),
                        ModifierSet.Modifier(name: "Ground Beef", price: nil),
                        ModifierSet.Modifier(name: "Ham", price: nil),
                        ModifierSet.Modifier(name: "Jalapeno", price: nil),
                        ModifierSet.Modifier(name: "Mushrooms", price: nil),
                        ModifierSet.Modifier(name: "Onions", price: nil),
                        ModifierSet.Modifier(name: "Peperoncini", price: nil),
                        ModifierSet.Modifier(name: "Pepperoni", price: nil),
                        ModifierSet.Modifier(name: "Pineapple", price: nil),
                        ModifierSet.Modifier(name: "Salami", price: nil),
                        ModifierSet.Modifier(name: "Sausage", price: nil),
                    ],
                    selected: [],
                    selectionType: .maximum(10)
                ),
            ],
            notes: "",
            discounts: [],
            taxes: []
        )
    }
}

struct AvailableOptions {
    var allDiscounts: [Discount]
    var allTaxes: [Tax]
}

struct Itemization: Equatable {
    var variations: ModifierSet

    var modifiers: [ModifierSet]

    var notes: String

    private(set) var discounts: [Discount.Applied]
    private(set) var taxes: [Tax.Applied]

    func has(_ discount: Discount) -> Bool {
        discounts.contains { $0.discount == discount }
    }

    mutating func add(_ discount: Discount) {
        guard has(discount) == false else { return }

        discounts.append(Discount.Applied(
            discount: discount,
            amount: Money(cents: 100, currency: .USD)
        ))
    }

    mutating func remove(_ discount: Discount) {
        guard has(discount) == true else { return }

        discounts.removeAll { $0.discount == discount }
    }

    func has(_ tax: Tax) -> Bool {
        taxes.contains { $0.tax == tax }
    }

    mutating func add(_ tax: Tax) {
        guard has(tax) == false else { return }

        taxes.append(Tax.Applied(
            tax: tax,
            amount: Money(cents: 100, currency: .USD)
        ))
    }

    mutating func remove(_ tax: Tax) {
        guard has(tax) == true else { return }

        taxes.removeAll { $0.tax == tax }
    }
}

struct ModifierSet: Equatable {
    var name: String

    var all: [Modifier]

    private(set) var selected: [Modifier]

    var selectionType: SelectionType

    @discardableResult
    mutating func select(modifier: Modifier) -> Bool {
        switch selectionType {
        case .single:
            selected.removeAll()
            selected.append(modifier)

        case .minimum(_), .maximum:
            if selected.contains(modifier) == false {
                selected.append(modifier)
            }
        }

        return true
    }

    mutating func deselect(modifier: Modifier) {
        switch selectionType {
        case .single: return
        case .maximum(_), .minimum: break
        }

        selected.removeAll {
            $0 == modifier
        }
    }

    enum SelectionType: Equatable {
        case single
        case minimum(Int)
        case maximum(Int)
    }

    struct Modifier: Equatable {
        var name: String
        var price: Money?
    }
}

struct Discount: Equatable {
    var name: String

    var type: DiscountType

    enum DiscountType: Equatable {
        case percent(Double)
        case amount(Money)
    }

    struct Applied: Equatable {
        var discount: Discount

        var amount: Money
    }
}

struct Tax: Equatable {
    var name: String

    var percent: Double

    struct Applied: Equatable {
        var tax: Tax

        var amount: Money
    }
}

struct Money: Hashable {
    var cents: Int
    var currency: Currency = .USD

    enum Currency {
        case USD
    }

    var localized: String {
        "$10.00"
    }
}
