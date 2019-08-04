//
//  TableViewDemosRandomResortViewController.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/25/19.
//

import UIKit

import Listable

final class TableViewDemosRandomResortViewController : UIViewController
{
    let presenter = TableView.Presenter(initial: ContentSource.State(), contentSource: ContentSource(), tableView: TableView())
    
    override func loadView()
    {
        self.title = "Random Resorter"
        
        self.view = self.presenter.tableView
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Rows", style: .plain, target: self, action: #selector(resortRows)),
            UIBarButtonItem(title: "Sections", style: .plain, target: self, action: #selector(resortSections))
        ]
    }
    
    @objc func resortRows()
    {
        self.presenter.update()
    }
    
    @objc func resortSections()
    {
        self.presenter.update()
    }
    
    struct SeedableRNG : RandomNumberGenerator, Equatable
    {
        var seed : UInt64
        
        mutating func next() -> UInt64
        {
            let seed = self.seed
            
            self.seed += 1
            
            return seed
        }
    }
    
    class ContentSource : TableViewContentSource
    {
        var rng = SeedableRNG(seed: 0)
        
        struct State : Equatable {}
        
        func tableViewContent(with state: TableView.State<State>, table: inout TableView.ContentBuilder)
        {
            (1...5).forEach { sectionIndex in
                table += TableView.Section(identifier: sectionIndex, header: TableView.HeaderFooter(String(sectionIndex))) { rows in
                    
                    (1...10).forEach { rowIndex in
                        rows += TableView.Row(String(rowIndex))
                    }
                    
                    rows.rows.shuffle(using: &self.rng)
                }
            }
            
            // TODO add me back
            //table.sections.shuffle(using: &self.rng)
        }
    }
}
