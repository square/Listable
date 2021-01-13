//
//  CollectionViewBasicDemoViewController.swift
//  ListableUI-DemoApp
//
//  Created by Kyle Van Essen on 7/9/19.
//

import UIKit

import ListableUI
import BlueprintUILists


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
    
    var showsOverscrollFooter : Bool = true
    var showsSectionHeaders : Bool = true
    
    let listView = ListView()
    
    override func loadView()
    {
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "UF", style: .plain, target: self, action: #selector(cycleUnderflow)),
            UIBarButtonItem(title: "OS", style: .plain, target: self, action: #selector(toggleOverscroll)),
            UIBarButtonItem(title: "SH", style: .plain, target: self, action: #selector(toggleSectionHeaders)),
            
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeItem)),
        ]
        
        self.view = self.listView
        
        self.listView.appearance = .demoAppearance
        self.listView.layout = .demoLayout
        
        self.updateTable(animated: false)
    }
    
    func updateTable(animated : Bool)
    {
        listView.configure { list in
            
            if self.showsOverscrollFooter {
                list.content.overscrollFooter = HeaderFooter(
                    DemoHeader(title: "Thanks for using Listable!!")
                )
            }
            
            list.animatesChanges = animated
            
            list += self.rows.map { sectionRows in
                Section("Demo Section") { section in
                    
                    section.layouts.list.columns = .init(count: 2, spacing: 10.0)
                     
                    if self.showsSectionHeaders {
                        section.header = HeaderFooter(DemoHeader(title: "Section Header"))
                    } else {
                        section.header = HeaderFooter(DemoHeader2(title: "Section Header"))
                    }
                    
                    section.footer = HeaderFooter(
                        DemoFooter(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi non luctus sem, eu consectetur ipsum. Curabitur malesuada cursus ante."),
                        sizing: .thatFits()
                    )
                    
                    section += sectionRows
                }
            }
        }
    }
    
    @objc func toggleOverscroll()
    {
        self.showsOverscrollFooter.toggle()
        
        self.updateTable(animated: true)
    }
    
    @objc func toggleSectionHeaders()
    {
        self.showsSectionHeaders.toggle()
        
        self.updateTable(animated: true)
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
            self.listView.behavior.underflow.alignment = {
                switch self.listView.behavior.underflow.alignment {
                case .top: return .center
                case .center: return .bottom
                case .bottom: return .top
                }
            }()
        }
    }
}
