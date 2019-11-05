//
//  ItemizationEditorViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 10/25/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import BlueprintLists
import BlueprintUI
import BlueprintUICommonControls

import Listable


final class ItemizationEditorViewController : UIViewController
{
    let blueprintView : BlueprintView = BlueprintView()
    
    override func loadView()
    {
        self.view = self.blueprintView
        
        self.updateList()
    }
    
    func updateList()
    {
        self.blueprintView.element = self.list
    }
    
    var availableOptions : AvailableOptions = DemoData.availableOptions
    
    var itemization : Itemization = DemoData.itemization {
        didSet {
            self.updateList()
        }
    }
    
    enum SectionIdentifier : Hashable
    {
        case variations
        case modifier(String)
        case discounts
        case taxes
    }
    
    var list : List
    {
        return List(appearance: self.listAppearance) { list in
            
            list.selectionMode = .multiple
            
            let variationsTitle : String = {
                if let selected = self.itemization.variations.selected.first {
                    return selected.name
                } else {
                    return self.itemization.variations.name
                }
            }()
            
            let footerText : String = {
                if self.itemization.variations.selected.isEmpty {
                    return "Choose at least one variation"
                } else {
                    return "You chose too many!!"
                }
            }()
            
            list += Section(
                identifier: SectionIdentifier.variations,
                layout: Section.Layout(columns: 2, spacing: 20.0),
                header: HeaderFooter(Header(content: variationsTitle), height: .thatFits(.noConstraint)),
                footer: HeaderFooter(Footer(content: footerText), height: .thatFits(.noConstraint)),
                content: { section in
                    section += self.itemization.variations.all.map { variation in
                        Item(
                            ChoiceItem(content: .init(title: variation.name, detail: "$0.00")),
                            selection: .isSelectable(isSelected: self.itemization.variations.selected.contains(variation)),
                            onSelect: { _ in
                                self.itemization.variations.select(modifier: variation)
                            },
                            onDeselect: { _ in
                                self.itemization.variations.deselect(modifier: variation)
                        })
                    }
            })

            list += itemization.modifiers.map { set in
                Section(
                    identifier: SectionIdentifier.modifier(set.name),
                    layout: Section.Layout(columns: 2, spacing: 20.0),
                    header: HeaderFooter(Header(content: set.name), height: .thatFits(.noConstraint)),
                    footer: HeaderFooter(Footer(content: "Choose modifiers"), height: .thatFits(.noConstraint)),
                    content: { section in
                        section += set.all.map { modifier in
                            Item(
                                ChoiceItem(content: .init(title: modifier.name, detail: "$0.00")),
                                selection: .isSelectable(isSelected: false),
                                onSelect: { _ in
                                    
                            },
                                onDeselect: { _ in
                                    
                            })
                        }
                })
            }
            
            list += Section(
                identifier: SectionIdentifier.discounts,
                layout: Section.Layout(columns: 2, spacing: 20.0),
                header: HeaderFooter(Header(content: "Discounts"), height: .thatFits(.noConstraint)),
                footer: nil,
                content: { section in
                    section += self.availableOptions.allDiscounts.map { discount in
                        Item(
                            ToggleItem(content: .init(title: discount.name, detail: "$0.00", isOn: self.itemization.has(discount))) { isOn in
                                if isOn {
                                    self.itemization.add(discount)
                                } else {
                                    self.itemization.remove(discount)
                                }
                            },
                            height: self.itemization.has(discount) ? .fixed(130.0) : .default,
                            selection: .isSelectable(isSelected: false)
                        )
                    }
            })
            
            list += Section(
                identifier: SectionIdentifier.taxes,
                layout: Section.Layout(columns: 2, spacing: 20.0),
                header: HeaderFooter(Header(content: "Taxes"), height: .thatFits(.noConstraint)),
                footer: nil,
                content: { section in
                    section += self.availableOptions.allTaxes.map { tax in
                        Item(
                            ToggleItem(content: .init(title: tax.name, detail: "$0.00", isOn: self.itemization.has(tax))) { isOn in
                                if isOn {
                                    self.itemization.add(tax)
                                } else {
                                    self.itemization.remove(tax)
                                }
                            },
                            height: self.itemization.has(tax) ? .fixed(130.0) : .default,
                            selection: .isSelectable(isSelected: false)
                        )
                    }
            })
        }
    }
    
    var listAppearance : Appearance {
        return Appearance(
            backgroundColor: .white,
            sizing: ListSizing(
                rowHeight: 70.0,
                sectionHeaderHeight: 50.0,
                sectionFooterHeight: 50.0,
                listHeaderHeight: 100.0,
                listFooterHeight: 100.0
            ),
            contentLayout: ListContentLayout(
                padding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0),
                width: .atMost(600.0),
                interSectionSpacingWithNoFooter: 20.0,
                interSectionSpacingWithFooter: 20.0,
                sectionHeaderBottomSpacing: 0.0,
                rowSpacing: 20.0,
                rowToSectionFooterSpacing: 20.0,
                sectionHeadersPinToVisibleBounds: false
            )
            ,
            underflow: .alwaysBounceVertical(true)
        )
    }
}

struct Header : BlueprintHeaderFooterElement
{
    var content : String
    
    var element : Element {
        return Inset(wrapping: Label(text: self.content) { label in
            label.font = .systemFont(ofSize: 30.0, weight: .bold)
        }, insets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 10.0, right: 0.0))
    }
}

struct Footer : BlueprintHeaderFooterElement
{
    var content : String
    
    var element : Element {
        return Label(text: self.content) { label in
            label.font = .systemFont(ofSize: 14.0, weight: .regular)
            label.alignment = .center
        }
    }
}

struct ChoiceItem : BlueprintItemElement
{
    var content : Content
    
    struct Content : Equatable
    {
        var title : String
        var detail : String
    }
    
    // MARK: BlueprintItemElement
    
    func element(with state: ItemState) -> Element
    {
        var box = Box(
            cornerStyle: .rounded(radius: 8.0),
            wrapping: Inset(
                wrapping: Row() { row in
                    row.verticalAlignment = .center
                    
                    row.add(child: Label(text: self.content.title) { label in
                        label.font = .systemFont(ofSize: 18.0, weight: .semibold)
                    })
                    row.add(child: Label(text: self.content.detail) { label in
                        label.font = .systemFont(ofSize: 18.0, weight: .regular)
                    })
                },
                uniformInset: 10.0
            )
        )
        
        if state.isSelected {
            box.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
            box.borderStyle = .solid(color: .init(white: 0.6, alpha: 1.0), width: 2.0)
            box.shadowStyle = .simple(radius: 2.0, opacity: 0.25, offset: .init(width: 0, height: 1.0), color: .black)
        } else {
            box.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
            box.borderStyle = .solid(color: .init(white: 0.9, alpha: 1.0), width: 2.0)
        }
        
        return box
    }
    
    var identifier: Identifier<ChoiceItem> {
        return .init(self.content.title)
    }
}

struct ToggleItem : BlueprintItemElement
{
    var content : Content
    
    struct Content : Equatable
    {
        var title : String
        var detail : String
        
        var isOn : Bool
    }
    
    var onToggle : (Bool) -> ()
    
    var identifier: Identifier<ToggleItem> {
        return .init(self.content.title)
    }
    
    func element(with state: ItemState) -> Element
    {
        var box = Box(
            cornerStyle: .rounded(radius: 8.0),
            wrapping: Inset(
                wrapping: Row() { row in
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
                },
                uniformInset: 10.0
            )
        )
        
        box.backgroundColor = .clear
        box.borderStyle = .solid(color: .init(white: 0.9, alpha: 1.0), width: 2.0)
        
        return box
    }
    
    struct Toggle : Element {
        var isOn : Bool
        
        var onToggle : (Bool) -> ()
        
        var content: ElementContent {
            return ElementContent(layout: Layout())
        }
        
        func backingViewDescription(bounds: CGRect, subtreeExtent: CGRect?) -> ViewDescription?
        {
            return ViewDescription(ToggleView.self) { config in
                config.builder = {
                    return ToggleView()
                }
                
                config.apply { toggle in
                    toggle.isOn = self.isOn
                    toggle.onToggle = self.onToggle
                }
            }
        }
        
        private final class ToggleView : UISwitch
        {
            var onToggle : (Bool) -> () = { _ in }
            
            override init(frame: CGRect)
            {
                super.init(frame: frame)
                
                self.addTarget(self, action: #selector(toggled), for: .valueChanged)
            }
            
            @available(*, unavailable)
            required init?(coder: NSCoder) {
                fatalError()
            }
            
            @objc func toggled()
            {
                self.onToggle(self.isOn)
            }
        }
        
        private struct Layout : BlueprintUI.Layout
        {
            static let measurementSwitch = ToggleView()
            
            func measure(in constraint: SizeConstraint, items: [(traits: (), content: Measurable)]) -> CGSize
            {
                return Layout.measurementSwitch.sizeThatFits(.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
            }
            
            func layout(size: CGSize, items: [(traits: (), content: Measurable)]) -> [LayoutAttributes]
            {
                return []
            }
        }
    }
    
}



//
// MARK: Demo Data
//


struct DemoData
{
    static var availableOptions : AvailableOptions {
        return AvailableOptions(
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
                Tax(name: "PST", percent: 7.0)
            ]
        )
    }
    
    static var itemization : Itemization {
        return Itemization(
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
                        ModifierSet.Modifier(name: "Sausage", price: nil)
                    ],
                    selected: [],
                    selectionType: .maximum(10)
                )
            ],
            notes: "",
            discounts: [],
            taxes: []
        )
    }
}

struct AvailableOptions
{
    var allDiscounts : [Discount]
    var allTaxes : [Tax]
}

struct Itemization : Equatable
{
    var variations : ModifierSet
    
    var modifiers : [ModifierSet]
    
    var notes : String
    
    private(set) var discounts : [Discount.Applied]
    private(set) var taxes : [Tax.Applied]
    
    func has(_ discount : Discount) -> Bool
    {
        return self.discounts.contains { $0.discount == discount }
    }
    
    mutating func add(_ discount : Discount)
    {
        guard self.has(discount) == false else { return }
        
        self.discounts.append(Discount.Applied(
            discount: discount,
            amount: Money(cents: 100, currency: .USD)
        ))
    }
    
    mutating func remove(_ discount : Discount)
    {
        guard self.has(discount) == true else { return }
        
        self.discounts.removeAll { $0.discount == discount }
    }
    
    func has(_ tax : Tax) -> Bool
    {
        return self.taxes.contains { $0.tax == tax }
    }
    
    mutating func add(_ tax : Tax)
    {
        guard self.has(tax) == false else { return }
        
        self.taxes.append(Tax.Applied(
            tax: tax,
            amount: Money(cents: 100, currency: .USD)
        ))
    }
    
    mutating func remove(_ tax : Tax)
    {
        guard self.has(tax) == true else { return }

        self.taxes.removeAll { $0.tax == tax }
    }
}

struct ModifierSet : Equatable
{
    var name : String
    
    var all : [Modifier]
    
    private(set) var selected : [Modifier]
    
    var selectionType : SelectionType
    
    @discardableResult
    mutating func select(modifier : Modifier) -> Bool
    {
        switch self.selectionType {
        case .single:
            self.selected.removeAll()
            self.selected.append(modifier)
            
        case .minimum(_), .maximum(_):
            if self.selected.contains(modifier) == false {
                self.selected.append(modifier)
            }
        }
        
        return true
    }
    
    mutating func deselect(modifier : Modifier)
    {
        switch self.selectionType {
        case .single: return
        case .maximum(_), .minimum(_): break
        }
        
        self.selected.removeAll {
            $0 == modifier
        }
    }
    
    enum SelectionType : Equatable
    {
        case single
        case minimum(Int)
        case maximum(Int)
    }
    
    struct Modifier : Equatable
    {
        var name : String
        var price : Money?
    }
}

struct Discount : Equatable
{
    var name : String
    
    var type : DiscountType
    
    enum DiscountType : Equatable
    {
        case percent(Double)
        case amount(Money)
    }
    
    struct Applied : Equatable
    {
        var discount : Discount
        
        var amount : Money
    }
}

struct Tax : Equatable
{
    var name : String
    
    var percent : Double
    
    struct Applied : Equatable
    {
        var tax : Tax
        
        var amount : Money
    }
}


struct Money : Hashable
{
    var cents : Int
    var currency : Currency = .USD
    
    enum Currency {
        case USD
    }
    
    var localized : String {
        return "$10.00" // TODO
    }
}
