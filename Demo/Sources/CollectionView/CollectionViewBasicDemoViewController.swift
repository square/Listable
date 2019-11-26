//
//  CollectionViewBasicDemoViewController.swift
//  Listable-DemoApp
//
//  Created by Kyle Van Essen on 7/9/19.
//

import UIKit

import Listable
import BlueprintLists


final class CollectionViewBasicDemoViewController : UIViewController
{
    var rows : [[DemoItem]] = [
        [
            DemoItem(text: "Nam sit amet imperdiet odio. Duis sed risus aliquet, finibus ex in, maximus diam. Mauris dapibus cursus rhoncus. Fusce faucibus velit at leo vestibulum, a pharetra dui interdum."),
            DemoItem(text: "Row 2"),
        ],
        [
            DemoItem(text: "Row 1"),
            DemoItem(text: "Row 2"),
            DemoItem(text: "Row 3"),
        ],
        ]
    
    let listView = ListView()
    
    override func loadView()
    {
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeItem)),
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(cycleUnderflow))
        ]
        
        self.view = self.listView
        self.listView.appearance = demoAppearance
        self.updateTable(animated: false)
    }
    
    func updateTable(animated : Bool)
    {
        listView.setContent { list in
            
            list.animatesChanges = animated
            
            list += self.rows.map { sectionRows in
                Section(identifier: "Demo Section") { section in
                    
                    section.columns = .init(count: 2, spacing: 10.0)
                     
                    section.header = HeaderFooter(with: DemoHeader(title: "Section Header"))
                    
                    section.footer = HeaderFooter(
                        with: DemoFooter(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi non luctus sem, eu consectetur ipsum. Curabitur malesuada cursus ante."),
                        sizing: .thatFits
                    )
                    
                    section += sectionRows
                }
            }
        }
    }
    
    @objc func addItem()
    {
        self.rows[0].insert(DemoItem(text: Date().description), at: 0)
        self.rows[1].insert(DemoItem(text: Date().description), at: 0)
        
        self.updateTable(animated: true)
    }
    
    @objc func removeItem()
    {
        if self.rows[0].isEmpty == false {
            self.rows[0].removeLast()
        }
        
        if self.rows[1].isEmpty == false {
            self.rows[1].removeLast()
        }
        
        self.updateTable(animated: true)
    }
    
    @objc func cycleUnderflow()
    {
        UIView.animate(withDuration: 0.3) {
            self.listView.appearance.underflow.alignment = {
                switch self.listView.appearance.underflow.alignment {
                case .top: return .center
                case .center: return .bottom
                case .bottom: return .top
                }
            }()
        }
    }
}
