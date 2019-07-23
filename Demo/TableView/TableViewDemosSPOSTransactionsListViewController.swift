//
//  TableViewDemosSPOSTransactionsListViewController.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/25/19.
//

import UIKit

import Listable


final class TableViewDemosSPOSTransactionsListViewController : UIViewController
{
    let presenter = TableView.Presenter(
        initial: ContentSource.State(),
        contentSource: ContentSource(),
        tableView: TableView()
    )
    
    let endpoint = ListEndpoint()
    
    override func loadView()
    {
        self.title = "Transactions"
        
        self.view = self.presenter.tableView
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if self.presenter.state.value.content == .new {
            
        }
    }
    
    class ContentSource : TableViewContentSource
    {
        let searchRow = ViewInstance(view: SearchBar())
        
        struct State : Equatable
        {
            var filter : String = ""
            
            var content : Content = .new
            
            enum Content : Equatable
            {
                case new
                case loading(ListEndpoint.Request)
                case content(ListEndpoint.Response)
                case error
                case empty
            }
        }
        
        func tableViewContent(with state: TableView.State<State>, table: inout TableView.ContentBuilder)
        {
            switch state.value.content {
            case .new: break
                
            case .loading(_):
                table += TableView.Section(identifier: "loading") { rows in
                    rows += TableView.Row("Loading...")
                }
                
            case .content(let content):
                table += TableView.Section(header: "Payments") { rows in
                    
                    rows += content.transactions.map { transaction in
                        TableView.Row(transaction.remoteID.uuidString)
                    }
                    
                    if content.hasMore {
                        rows += TableView.Row("Load More", onDisplay: {
                            
                        })
                    }
                }
                
            case .error:
                table += TableView.Section(identifier: "error") { rows in
                    rows += TableView.Row("Error!")
                }
                
            case .empty:
                table += TableView.Section(identifier: "empty") { rows in
                    rows += TableView.Row("No Payments")
                }
            }
        }
    }
}

final class ListEndpoint
{
    struct Request : Equatable
    {
        var filter : String
        var pagintationToken : String? = nil
    }
    
    struct Response : Equatable
    {
        var request : Request
        
        var transactions : [Transaction]
        var pagintationToken : String
        var hasMore : Bool
    }
    
    struct Transaction : Equatable
    {
        var amount : Int
        
        var date : Date
        
        var remoteID : UUID
    }
    
    private static let fakePayments : [Transaction] = (1...10000).map({ index in
        return Transaction(
            amount: Int.random(in: 1000...10000),
            date: Date(timeIntervalSinceNow: TimeInterval.random(in: -1_000_000...1_000_000)),
            remoteID: UUID()
        )
    }).sorted(by: {
        $0.date < $1.date
    })
    
    init()
    {
        
    }
    
    func perform(_ request : Request, completion : (Response) -> ())
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.5...1.5)) {
            // TODO
        }
    }
}
