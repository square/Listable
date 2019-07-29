//
//  TableViewDemosBindingsViewController.swift
//  Listable-DemoApp
//
//  Created by Kyle Van Essen on 6/27/19.
//

import Foundation

import Listable


extension Notification.Name
{
    static let incrementedDemo = Notification.Name("IncrementedDemo")
}

final class TableViewDemosBindingsViewController : UIViewController
{
    let tableView = TableView()
    
    var number : Int = 0
    
    override func loadView()
    {
        self.title = "Bindings"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Increment", style: .plain, target: self, action: #selector(increment))
        
        self.view = self.tableView
        
        self.tableView.setContent { table in
            table += TableView.Section(header: "Demo Section") { rows in
                rows += TableView.Row(String(self.number), bind: {
                    Binding(initial: $0, bind: { _ in
                        NotificationContext<String,NoUpdate>(
                            name: .incrementedDemo,
                            createUpdate : { _ in
                                return .none
                        })
                    }, update: { _, _, element in
                        element = String(self.number)
                    })
                })
            }
        }
    }
    
    @objc func increment()
    {
        self.number += 1
        
        NotificationCenter.default.post(name: .incrementedDemo, object: nil)
    }
}
