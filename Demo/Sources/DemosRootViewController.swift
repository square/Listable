//
//  TableViewDemosRootViewController.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/24/19.
//

import UIKit

import ListableTableView


public final class DemosRootViewController : UIViewController
{    
    public struct State : Equatable {}
    
    let tableView = TableView()
    
    func push(_ viewController : UIViewController)
    {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    override public func loadView()
    {        
        self.title = "Demos"
        
        self.view = self.tableView
        
        self.tableView.setContent { table in
            table += Section(header: "Table Views") { rows in
                
                rows += Row(
                    SubtitleRow(
                        text:"English Dictionary Search",
                        detail: "Shows the Websters English dictionary, sectioned by letter."
                    ),
                    onTap: { _ in
                        self.push(TableViewDemosDictionaryViewController())
                })
                
                rows += Row(
                    SubtitleRow(
                        text: "Random Sorter",
                        detail: "Randomly resorts the content, with animation."),
                    onTap: { _ in
                        self.push(TableViewDemosRandomResortViewController())
                })
                
                rows += Row(
                    SubtitleRow(
                        text: "Lorem Ipsum",
                        detail: "Headers, footers, and cells showing varying amounts of ipsum to demonstrate sizing."),
                    onTap: { _ in
                        self.push(TableViewDemosIpsumViewController())
                })
                
                rows += Row(
                    SubtitleRow(
                        text: "Bindings Demo",
                        detail: "Shows how bindings work on table view cell."),
                    onTap: { _ in
                        self.push(TableViewDemosBindingsViewController())
                })
                
                rows += Row(
                    SubtitleRow(
                        text: "SPOS Items List",
                        detail: "Example of what the items library looks like in SPOS."),
                    onTap: { _ in
                        self.push(TableViewDemosSPOSItemsListViewController())
                })
                
                rows += Row(
                    SubtitleRow(
                        text: "Transaction History",
                        detail: "Example of what the transaction list looks like in SPOS, including load on scroll and pull to refresh."),
                    onTap: { _ in
                        self.push(TableViewDemosSPOSTransactionsListViewController())
                })
                
                rows += Row(
                    SubtitleRow(
                        text: "Cart",
                        detail: "Example of the cart view in Point of Sale."),
                    onTap: { _ in
                        self.push(TableViewDemosCartViewController())
                })
            }
            
            table += Section(header: "Collection Views") { rows in
                rows += Row(
                    SubtitleRow(
                        text: "Flow Layout",
                        detail: "Demo of flow layout wrapper."
                    ),
                    onTap : { _ in
                        self.push(CollectionViewDemoFlowLayoutViewController())
                })
            }
            
            table += Section(header: "Blueprint") { rows in
                rows += Row(
                    SubtitleRow(
                        text: "Basic Table View",
                        detail: "Creating a Blueprint view backed by Listable."
                    ),
                    onTap : { _ in
                        self.push(TableViewDemosBlueprintViewController())
                })
            }
        }
    }
}
