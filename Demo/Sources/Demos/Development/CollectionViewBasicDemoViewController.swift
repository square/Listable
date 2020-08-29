//
//  CollectionViewBasicDemoViewController.swift
//  Listable-DemoApp
//
//  Created by Kyle Van Essen on 7/9/19.
//

import UIKit

import Listable
import BlueprintLists
import BlueprintUICommonControls


final class CollectionViewBasicDemoViewController : UIViewController
{
    var rows : [[DemoTextItem]] = [
        [
            DemoTextItem(text: "Nam sit amet imperdiet odio. Duis sed risus aliquet, finibus ex in, maximus diam. Mauris dapibus cursus rhoncus. Fusce faucibus velit at leo vestibulum, a pharetra dui interdum."),
            DemoTextItem(text: "Row 2"),
        ],
        [
            DemoTextItem(text: "Row 1"),
            DemoTextItem(text: "Row 2"),
            DemoTextItem(text: "Row 3"),
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
                    
                    section.columns = .init(count: 2, spacing: 10.0)
                     
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
        self.rows[0].insert(DemoTextItem(text: Date().description), at: 0)
        self.rows[1].insert(DemoTextItem(text: Date().description), at: 0)
        
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


fileprivate struct DemoHeader2 : BlueprintHeaderFooterContent, Equatable
{
    var title : String
    
    var elementRepresentation: Element {
        Label(text: self.title) {
            $0.font = .systemFont(ofSize: 20.0, weight: .bold)
        }
        .inset(horizontal: 15.0, vertical: 30.0)
        .box(
            background: .white,
            corners: .rounded(radius: 10.0),
            shadow: .simple(radius: 2.0, opacity: 0.2, offset: .init(width: 0.0, height: 1.0), color: .black)
        )
    }
}
