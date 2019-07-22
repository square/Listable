//
//  TableViewDemosBindingsViewController.swift
//  Listable-DemoApp
//
//  Created by Kyle Van Essen on 6/27/19.
//

import Foundation

import Listable


extension NSNotification.Name
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
                    
                    // TODO: How do we account for the time between creation and display? How do we update the element data?
                    
                    Binding(initial: $0, bind: { binding in
                        Binding.NotificationContext(
                            with: binding,
                            name: .incrementedDemo
                        )
                    }, update: { context, element in
                        String(self.number)
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
