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
    
    override public func loadView()
    {        
        self.title = "Demos"
        
        self.view = self.listView
        
        self.listView.appearance = demoAppearance
        
        self.listView.setContent { list in
            list += Section(identifier: "collection-view") { section in
                
                section.header = HeaderFooter(
                    with: DemoHeader(title: "Collection Views")
                )
                
                section += Item(
                    with: DemoItem(text: "Basic Demo"),
                    selection: .isSelectable(isSelected: false),
                    onSelect : { _ in
                        self.push(CollectionViewBasicDemoViewController())
                })
                
                section += Item(
                    with: DemoItem(text: "Blueprint Integration"),
                    selection: .isSelectable(isSelected: false),
                    onSelect : { _ in
                        self.push(BlueprintListDemoViewController())
                })
                
                section += Item(
                    with: DemoItem(text: "Itemization Editor"),
                    selection: .isSelectable(isSelected: false),
                    onSelect : { _ in
                        self.push(ItemizationEditorViewController())
                })
                
                section += Item(
                    with: DemoItem(text: "English Dictionary Search"),
                    selection: .isSelectable(isSelected: false),
                    onSelect : { _ in
                        self.push(CollectionViewDictionaryDemoViewController())
                })
                
                section += Item(
                    with: DemoItem(text: "Keyboard Testing"),
                    selection: .isSelectable(isSelected: false),
                    onSelect : { _ in
                        self.push(KeyboardTestingViewController())
                })
                
                section += Item(
                    with: DemoItem(text: "Horizontal Layout"),
                    selection: .isSelectable(isSelected: false),
                    onSelect : { _ in
                        self.push(HorizontalLayoutViewController())
                })
                
                section += Item(
                    with: DemoItem(text: "Width Customization"),
                    selection: .isSelectable(isSelected: false),
                    onSelect : { _ in
                        self.push(WidthCustomizationViewController())
                })
            }
        }
    }
}

