//
//  PaymentTypesViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 6/12/21.
//  Copyright © 2021 Kyle Van Essen. All rights reserved.
//

import BlueprintUILists
import BlueprintUICommonControls


final class PaymentTypesViewController : ListViewController {
    
    override func configure(list: inout ListProperties) {
        
        list.layout = .table { table in
            table.layout.interSectionSpacingWithNoFooter = 10.0
            table.bounds = .init(
                padding: UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
            )
        }
        
        let types = self.types
        
        list.stateObserver.onItemReordered { [weak self] info in
            self?.save(with: info)
        }
        
        list += Section(SectionID.main) { section in
            
            section.header = PaymentTypeHeader(title: SectionID.main.title)
            
            section += types.filter { $0.isEnabled }
            .filter { $0.isMain }
            .sorted { $0.sortOrder < $1.sortOrder }
            .map(makeItem(with:))
        }
        
        list += Section(SectionID.more) { section in
            
            section.header = PaymentTypeHeader(title: SectionID.more.title)
            
            section += types.filter { $0.isEnabled }
            .filter { $0.isMain == false }
            .sorted { $0.sortOrder < $1.sortOrder }
            .map(makeItem(with:))
        }
        
        list += Section(SectionID.disabled) { section in
            
            section.header = PaymentTypeHeader(title: SectionID.disabled.title)
            
            section.reordering.minItemCount = 0
            
            section += types.filter { $0.isEnabled == false }
            .sorted { $0.sortOrder < $1.sortOrder }
            .map(makeItem(with:))
            
            if section.items.isEmpty {
                section += EmptyRow()
            }
        }
    }
    
    private func save(with info : ListStateObserver.ItemReordered) {
        let main = info.sections.first { $0.identifier == Section.identifier(with: SectionID.main) }!
        let more = info.sections.first { $0.identifier == Section.identifier(with: SectionID.more) }!
        let disabled = info.sections.first { $0.identifier == Section.identifier(with: SectionID.disabled) }!
        
        let mainItems : [PaymentTypeRow] = main.filtered(to: PaymentTypeRow.self).map { row in
            var row = row
            row.type.isEnabled = true
            row.type.isMain = true
            
            return row
        }
        
        let moreItems : [PaymentTypeRow] = more.filtered(to: PaymentTypeRow.self).map { row in
            var row = row
            row.type.isEnabled = true
            row.type.isMain = false
            
            return row
        }
        
        let disabledItems : [PaymentTypeRow] = disabled.filtered(to: PaymentTypeRow.self).map { row in
            var row = row
            row.type.isEnabled = false
            
            return row
        }
        
        var index : Int = 0
        let all : [PaymentTypeRow] = (mainItems + moreItems + disabledItems).map { row in
            defer { index += 1 }
            
            var row = row
            row.type.sortOrder = index
            
            return row
        }
        
        self.types = all.map(\.type)
    }
    
    private func makeItem(with type : PaymentType) -> Item<PaymentTypeRow> {
        Item(
            PaymentTypeRow(type: type) { isOn in
                self.types = self.types.edit(with: type.name) {
                    $0.isEnabled = isOn
                }
            },
            reordering: .init(sections: .all)
        )
    }
    
    enum SectionID : Hashable {
        case main
        case more
        case disabled
        
        var title : String {
            switch self {
            case .main: return "Main payment types"
            case .more: return "More payment types"
            case .disabled: return "Disabled payment types"
            }
        }
    }
}

fileprivate struct PaymentTypeHeader : BlueprintHeaderFooterContent, Equatable {
    
    var title : String
    
    var elementRepresentation: Element {
        Label(text: title) {
            $0.font = .systemFont(ofSize: 18.0, weight: .medium)
        }
        .inset(uniform: 15.0)
    }
    
    var background: Element? {
        Box(backgroundColor: .white)
    }
}

fileprivate struct EmptyRow : BlueprintItemContent, Equatable {
    
    var identifierValue: String {
        ""
    }
    
    func element(with info: ApplyItemContentInfo) -> Element {
        Label(text: "No Contents") {
            $0.font = .systemFont(ofSize: 16.0, weight: .semibold)
            $0.color = .lightGray
        }
        .inset(uniform: 15.0)
    }
}

fileprivate struct PaymentTypeRow : BlueprintItemContent {
    
    var type : PaymentType
    
    var onToggle : (Bool) -> ()
    
    var identifierValue: String {
        self.type.name
    }
    
    func element(with info: ApplyItemContentInfo) -> Element {
        
        Row { row in
            row.horizontalUnderflow = .growUniformly
            row.verticalAlignment = .center
            
            row.addFixed(child: Label(text: type.name) {
                $0.font = .systemFont(ofSize: 16.0, weight: .medium)
                $0.color = .darkText
            })
            row.addFlexible(child: Spacer(width: 1))
            row.addFixed(child: Toggle(isOn: type.isEnabled, onToggle: onToggle))
            row.addFixed(child: Spacer(width: 10))
            
            row.addFixed(
                child: Image(
                    image: UIImage(named: "ReorderControl"),
                    contentMode: .center
                ).listReorderGesture(with: info.reorderingActions)
            )
        }
        .inset(uniform: 15.0)
        
    }
    
    func backgroundElement(with info: ApplyItemContentInfo) -> Element? {
        Box(
            backgroundColor: .white,
            shadowStyle: {
                if info.state.isReordering {
                    return .simple(
                        radius: 5.0,
                        opacity: 0.4,
                        offset: CGSize(width: 0, height: 2),
                        color: .black
                    )
                } else {
                    return .none
                }
            }()
        )
    }
    
    func isEquivalent(to other: PaymentTypeRow) -> Bool {
        self.type == other.type
    }
}


fileprivate extension Array where Element == PaymentType {
    
    func edit(with name : String, using edit : (inout PaymentType) -> ()) -> Self  {
        
        self.map { type in
            guard type.name == name else {
                return type
            }
            
            var edited = type
            edit(&edited)
            return edited
        }
    }
}


fileprivate struct PaymentType : Codable, Equatable {
    
    var name : String
    
    var isEnabled : Bool
    
    var isMain : Bool
    
    var sortOrder : Int
    
    static let defaults : [PaymentType] = [
        PaymentType(
            name: "Manual credit card entry",
            isEnabled: true,
            isMain: true,
            sortOrder: 0
        ),
        
        PaymentType(
            name: "Manual gift card entry",
            isEnabled: true,
            isMain: true,
            sortOrder: 1
        ),
        
        PaymentType(
            name: "Customer card on file",
            isEnabled: true,
            isMain: true,
            sortOrder: 2
        ),
        
        PaymentType(
            name: "Cash",
            isEnabled: true,
            isMain: true,
            sortOrder: 3
        ),
        
        PaymentType(
            name: "Invoice",
            isEnabled: true,
            isMain: false,
            sortOrder: 4
        ),
        
        PaymentType(
            name: "Check",
            isEnabled: true,
            isMain: false,
            sortOrder: 5
        ),
        
        PaymentType(
            name: "Pay with QR code",
            isEnabled: true,
            isMain: false,
            sortOrder: 6
        ),
        
        PaymentType(
            name: "Send payment link",
            isEnabled: true,
            isMain: false,
            sortOrder: 7
        ),
        
        PaymentType(
            name: "Other gift card or certificate",
            isEnabled: false,
            isMain: false,
            sortOrder: 8
        ),
        
        PaymentType(
            name: "Other payment types",
            isEnabled: false,
            isMain: false,
            sortOrder: 9
        )
    ]
}


fileprivate extension PaymentTypesViewController {
    
    var types : [PaymentType] {
        get {
            guard let data = UserDefaults.standard.value(forKey: "demo-payment-types") as? Data else {
                return PaymentType.defaults
            }
            
            let decoder = PropertyListDecoder()
            
            guard let types = try? decoder.decode([PaymentType].self, from: data) else {
                return PaymentType.defaults
            }
            
            return types
        }
        
        set {
            guard self.types != newValue else {
                return
            }
            
            let encoder = PropertyListEncoder()
            
            guard let data = try? encoder.encode(newValue) else {
                return
            }
            
            UserDefaults.standard.set(data, forKey: "demo-payment-types")
            
            self.reload(animated: true)
        }
    }
}
