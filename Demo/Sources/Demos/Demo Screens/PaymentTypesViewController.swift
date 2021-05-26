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
        
        let types = self.types
        
        let makeRow = { (type:PaymentType) -> PaymentTypeRow in
            .init(type: type) { isOn in
                self.types = self.types.edit(with: type.name) {
                    $0.isEnabled = isOn
                }
            }
        }
        
        list += Section(SectionID.main) { section in
            
            section += types.filter { $0.isEnabled }
            .filter { $0.isMain }
            .sorted { $0.sortOrder < $1.sortOrder }
            .map(makeRow)
        }
        
        list += Section(SectionID.more) { section in
            
            section += types.filter { $0.isEnabled }
            .filter { $0.isMain == false }
            .sorted { $0.sortOrder < $1.sortOrder }
            .map(makeRow)
        }
        
        list += Section(SectionID.disabled) { section in
            
            section += types.filter { $0.isEnabled == false }
            .sorted { $0.sortOrder < $1.sortOrder }
            .map(makeRow)
        }
    }
    
    enum SectionID : Hashable {
        case main
        case more
        case disabled
    }
}


fileprivate struct PaymentTypeRow : BlueprintItemContent {
    
    var type : PaymentType
    
    var onToggle : (Bool) -> ()
    
    var identifier: String {
        self.type.name
    }
    
    func element(with info: ApplyItemContentInfo) -> Element {
        fatalError()
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
