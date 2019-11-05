//
//  CollectionViewBasicDemoViewController.swift
//  Listable-DemoApp
//
//  Created by Kyle Van Essen on 7/9/19.
//

import UIKit

import Listable


final class CollectionViewBasicDemoViewController : UIViewController
{
    var rows : [[DemoElement]] = [
        [
            DemoElement(content: "Nam sit amet imperdiet odio. Duis sed risus aliquet, finibus ex in, maximus diam. Mauris dapibus cursus rhoncus. Fusce faucibus velit at leo vestibulum, a pharetra dui interdum."),
            DemoElement(content: "Row 2"),
        ],
        [
            DemoElement(content: "Row 1"),
            DemoElement(content: "Row 2"),
            DemoElement(content: "Row 3"),
        ],
        ]
    
    let listView = ListView()
    
    override func loadView()
    {
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addItem)),
            UIBarButtonItem(title: "Remove", style: .plain, target: self, action: #selector(removeItem))
        ]
        
        self.view = listView
        
        self.updateTable(animated: false)
    }
    
    var itemAppearance : DemoElement.Appearance {
        return DemoElement.Appearance { label in
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 16.0, weight: .regular)
        }
    }
    
    var headerAppearance : HeaderElement.Appearance {
        return HeaderElement.Appearance { label in
            label.font = .systemFont(ofSize: 18.0, weight: .bold)
        }
    }
    
    var footerAppearance : FooterElement.Appearance {
        return FooterElement.Appearance { label in
            label.textColor = .darkGray
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 14.0, weight: .regular)
            label.textAlignment = .center
        }
    }
    
    func updateTable(animated : Bool)
    {
        listView.appearance = defaultAppearance
        
        listView.setContent(animated: animated) { list in
            
            list += self.rows.map { sectionRows in
                Section(
                    identifier: "Demo Section",
                    
                    layout: Section.Layout(columns: 2, spacing: 10.0),
                    
                    header: HeaderFooter(
                        HeaderElement(content: "Section Header"),
                        appearance: self.headerAppearance
                    ),
                    footer: HeaderFooter(
                        FooterElement(content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi non luctus sem, eu consectetur ipsum. Curabitur malesuada cursus ante."),
                        appearance: self.footerAppearance,
                        height: .thatFits(.noConstraint)
                    )
                ) { section in
                    section += sectionRows.map { row in
                        Item(
                            row,
                            appearance: self.itemAppearance,
                            height: .thatFits(.atLeast(.default))
                        )
                    }
                }
            }
        }
    }
    
    @objc func addItem()
    {
        self.rows[0].insert(DemoElement(content: Date().description), at: 0)
        self.rows[1].insert(DemoElement(content: Date().description), at: 0)
        
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
}


struct HeaderElement : HeaderFooterElement
{
    var content : String
    
    // HeaderFooterElement
    
    typealias Appearance = HeaderAppearance<UILabel>
    
    func apply(to views: HeaderFooterElementView<UILabel, UIView>, reason: ApplyReason)
    {
        views.content.text = self.content
    }
}

struct FooterElement : HeaderFooterElement
{
    var content : String
    
    // HeaderFooterElement
    
    typealias Appearance = FooterAppearance<UILabel>
    
    func apply(to views: HeaderFooterElementView<UILabel, UIView>, reason: ApplyReason)
    {
        views.content.text = self.content
    }
}

struct DemoElement : ItemElement
{
    var content : String

    // ItemElement
    
    typealias Appearance = ItemAppearance<UILabel>
    
    var identifier: Identifier<DemoElement> {
        return .init(self.content)
    }
    
    func apply(to view: Appearance.View, with state : ItemState, reason: ApplyReason)
    {
        view.content.text = self.content
    }
}
