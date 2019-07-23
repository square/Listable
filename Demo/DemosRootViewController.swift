//
//  TableViewDemosRootViewController.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/24/19.
//

import UIKit

import Listable


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
            table += TableView.Section(header: "Table Views") { rows in
                
                rows += TableView.Row(
                    SubtitleRow(
                        text:"English Dictionary Search",
                        detail: "Shows the Websters English dictionary, sectioned by letter."
                    ),
                    onTap: {
                        self.push(TableViewDemosDictionaryViewController())
                })
                
                rows += TableView.Row(
                    SubtitleRow(
                        text: "Random Sorter",
                        detail: "Randomly resorts the content, with animation."),
                    onTap: {
                        self.push(TableViewDemosRandomResortViewController())
                })
                
                rows += TableView.Row(
                    SubtitleRow(
                        text: "Lorem Ipsum",
                        detail: "Headers, footers, and cells showing varying amounts of ipsum to demonstrate sizing."),
                    onTap: {
                        self.push(TableViewDemosIpsumViewController())
                })
                
                rows += TableView.Row(
                    SubtitleRow(
                        text: "Bindings Demo",
                        detail: "Shows how bindings work on table view cell."),
                    onTap: {
                        self.push(TableViewDemosBindingsViewController())
                })
                
                rows += TableView.Row(
                    SubtitleRow(
                        text: "SPOS Items List",
                        detail: "Example of what the items library looks like in SPOS."),
                    onTap: {
                        self.push(TableViewDemosSPOSItemsListViewController())
                })
                
                rows += TableView.Row(
                    SubtitleRow(
                        text: "Transaction History",
                        detail: "Example of what the transaction list looks like in SPOS, including load on scroll and pull to refresh."),
                    onTap: {
                        self.push(TableViewDemosSPOSTransactionsListViewController())
                })
                
                rows += TableView.Row(
                    SubtitleRow(
                        text: "Cart",
                        detail: "Example of the cart view in Point of Sale."),
                    onTap: {
                        self.push(TableViewDemosCartViewController())
                })
            }
            
            table += TableView.Section(header: "Collection Views") { rows in
                rows += TableView.Row(
                    SubtitleRow(
                        text: "Flow Layout",
                        detail: "Demo of flow layout wrapper."
                    ),
                    onTap : {
                        self.push(CollectionViewDemoFlowLayoutViewController())
                })
            }
        }
    }
}
