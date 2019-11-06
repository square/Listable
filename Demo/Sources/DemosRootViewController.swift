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
    
    let listView = ListView()
    
    func push(_ viewController : UIViewController)
    {
        self.navigationController?.pushViewController(viewController, animated: true)
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
    
    override public func loadView()
    {        
        self.title = "Demos"
        
        self.view = self.listView
        
        self.listView.appearance = defaultAppearance
        
        self.listView.setContent { list in
            list += Section(identifier: "collection-view") { section in
                
                section.header = HeaderFooter(
                    HeaderElement(content: "Collection Views"),
                    appearance: self.headerAppearance
                )
                
                section += Item(
                    TitleElement(content: "Basic Demo"),
                    appearance: self.itemAppearance,
                    selection: .isSelectable(isSelected: false),
                    onSelect : { _ in
                        self.push(CollectionViewBasicDemoViewController())
                })
                
                section += Item(
                    TitleElement(content: "Blueprint Integration"),
                    appearance: self.itemAppearance,
                    selection: .isSelectable(isSelected: false),
                    onSelect : { _ in
                        self.push(BlueprintListDemoViewController())
                })
                
                section += Item(
                    TitleElement(content: "Itemization Editor"),
                    appearance: self.itemAppearance,
                    selection: .isSelectable(isSelected: false),
                    onSelect : { _ in
                        self.push(ItemizationEditorViewController())
                })
                
                section += Item(
                    TitleElement(content: "English Dictionary Search"),
                    appearance: self.itemAppearance,
                    selection: .isSelectable(isSelected: false),
                    onSelect : { _ in
                        self.push(CollectionViewDictionaryDemoViewController())
                })
            }
        }
    }
}

struct TitleElement : ItemElement
{
    var content : String

    // ItemElement
    
    typealias Appearance = ItemAppearance<UILabel>
    
    var identifier: Identifier<TitleElement> {
        return .init(self.content)
    }
    
    func apply(to view: Appearance.View, with state : ItemState, reason: ApplyReason)
    {
        view.content.text = self.content
    }
}
