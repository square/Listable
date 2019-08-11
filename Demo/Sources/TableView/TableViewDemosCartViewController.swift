//
//  TableViewDemosCartViewController.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/25/19.
//

import UIKit
import ListableCore
import ListableTableView

import BlueprintUI
import BlueprintUICommonControls


final class TableViewDemosCartViewController : UIViewController
{
    override func loadView()
    {
        self.title = "Cart"
        
        self.view = TableView(state: Source.State(), source: Source())
    }
    
    class Source : TableViewSource
    {
        let searchRow = UIViewRowElement(view: SearchBar())
        
        var itemizations : [Itemization] = fakeItemizations()
        
        struct State : Equatable
        {
            var filter : String = ""
            
            func include(_ word : String) -> Bool
            {
                return self.filter.isEmpty || word.lowercased().contains(self.filter.lowercased())
            }
        }
        
        func content(with state: SourceState<State>, table: inout ContentBuilder)
        {
            guard self.itemizations.isEmpty == false else {
                return
            }
            
            table += Section(identifier: "search") { rows in
                self.searchRow.view.onStateChanged = { filter in
                    state.value.filter = filter
                }
                
                rows += self.searchRow
            }
            
            table += Section(identifier: "itemizations") { rows in
                
                rows += self.itemizations.compactMap { itemization in
                    
                    guard state.value.include(itemization.variation.name) else {
                        return nil
                    }
                    
                    return Row(
                        ItemizationRow(itemization: itemization),
                        
                        sizing: .thatFits(.noConstraint),
                        
                        trailingActions: SwipeActions(
                            SwipeAction(
                                title: "Delete",
                                style: .destructive,
                                onTap: { _ in
                                    return true
                            })
                        ),
                        
                        onTap: { _ in
                            print("Tapped!")
                    })
                }
            }
            
            table += Section(identifier: "amounts") { rows in
                rows += Row(AmountRow(title: "Tax", detail: "$1.50"))
                rows += Row(AmountRow(title: "Discount", detail: "$2.00"))
                rows += Row(AmountRow(title: "Loyalty", detail: "No Points"))
                rows += Row(AmountRow(title: "Total", detail: "$10.00"))
            }
        }
    }
}

struct Itemization : Equatable
{
    var variation : Variation
    var modifiers : [Modifier]
    
    var total : String
    var quantity : Int
    var remoteID : UUID
    
    struct Variation : Equatable
    {
        var name : String
        var catalogID : UUID
    }
    
    struct Modifier : Equatable
    {
        var name : String
        var price : String
    }
}

struct AmountRow : ProxyElement, TableViewRowViewElement, Equatable
{
    var title : String
    var detail : String
    
    var elementRepresentation: Element {
        return Inset(
            wrapping: Row() { row in
                row += (.zeroPriority, Label(text: self.title))
                row += Box()
                row += (.zeroPriority, Label(text: self.detail))
            },
            left: 20.0,
            right: 20.0
        )
    }
    
    // TableViewRowViewElement
    
    typealias View = ElementView<AmountRow>
    
    var identifier: Identifier<AmountRow> {
        return .init(self.title)
    }
    
    static func createReusableView() -> View
    {
        return ElementView()
    }
    
    func apply(to view : View, reason : ApplyReason)
    {
        view.element = self
    }
}

struct ItemizationRow : ProxyElement, TableViewRowViewElement, Equatable
{
    var itemization : Itemization
    
    // ProxyElement
    
    var elementRepresentation: Element {
        
        return Inset(
            wrapping: Column() { column in
                
                column += Row() { row in
                    row += (.zeroPriority, Label(text: itemization.variation.name))
                    
                    if itemization.quantity > 1 {
                        row += (.zeroPriority, Inset(wrapping: Label(text: "x \(itemization.quantity)"), left: 10.0))
                    }
                    
                    row += Box()
                    
                    row += (.zeroPriority, Label(text: itemization.total))
                    }.scaleContentToFit()
                
                for modifier in itemization.modifiers {
                    column += Label(text: modifier.name)
                }
                }.scaleContentToFit(),
            uniformInset: 20.0)
    }
    
    // TableViewRowViewElement
    
    typealias View = ElementView<ItemizationRow>
    
    var identifier: Identifier<ItemizationRow> {
        return .init(self.itemization.remoteID)
    }
    
    static func createReusableView() -> View
    {
        return ElementView()
    }
    
    func apply(to view : View, reason : ApplyReason)
    {
        view.element = self
    }
}

func fakeItemization() -> Itemization
{
    return Itemization(
        variation: .init(
            name: "Small",
            catalogID: UUID()
        ),
        modifiers: [
            .init(name: "Extra Cheese", price: "$1.00"),
            .init(name: "Spicy Mayo", price: "$.100"),
            .init(name: "To Go", price: "$1.00"),
        ],
        total: "$3.00",
        quantity: 4,
        remoteID: UUID()
    )
}

func fakeItemizations() -> [Itemization]
{
    return Array(repeating: fakeItemization(), count: 3)
}
