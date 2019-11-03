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
            list += Section(
            identifier: "collection-view",
            header: HeaderFooter(
                HeaderElement(title: "Collection Views"),
                appearance: self.headerAppearance
                )
            ) { rows in
                rows += Item(
                    TitleElement(title: "Basic Demo"),
                    appearance: self.itemAppearance,
                    selection: .isSelectable(isSelected: false),
                    onSelect : { _ in
                        self.push(CollectionViewBasicDemoViewController())
                })
                
                rows += Item(
                    TitleElement(title: "Blueprint Integration"),
                    appearance: self.itemAppearance,
                    selection: .isSelectable(isSelected: false),
                    onSelect : { _ in
                        self.push(BlueprintListDemoViewController())
                })
                
                rows += Item(
                    TitleElement(title: "Itemization Editor"),
                    appearance: self.itemAppearance,
                    selection: .isSelectable(isSelected: false),
                    onSelect : { _ in
                        self.push(ItemizationEditorViewController())
                })
                
                rows += Item(
                    TitleElement(title: "English Dictionary Search"),
                    appearance: self.itemAppearance,
                    selection: .isSelectable(isSelected: false),
                    onSelect : { _ in
                        self.push(CollectionViewDictionaryDemoViewController())
                })
            }
        }
    }
}

struct TitleElement : ItemElement, Equatable
{
    var title : String

    // ItemElement
    
    typealias Appearance = ItemAppearance<UILabel>
    
    var identifier: Identifier<TitleElement> {
        return .init(self.title)
    }
    
    func apply(to view: Appearance.View, with state : ItemState, reason: ApplyReason)
    {
        view.content.text = self.title
    }
}
