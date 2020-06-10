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
        
        self.listView.appearance = .demoAppearance
        
        self.listView.setContent { list in

            list.content.overscrollFooter = HeaderFooter(
                DemoHeader(title: "Thanks for using Listable!!")
            )
            
            list += Section(identifier: "list-view") { section in
                
                section.header = HeaderFooter(
                    DemoHeader(title: "List Views")
                )
                
                section += Item(
                    DemoItem(text: "Basic Demo"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(CollectionViewBasicDemoViewController())
                    }
                )
                
                section += Item(
                    DemoItem(text: "Blueprint Integration"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(BlueprintListDemoViewController())
                })

                section += Item(
                    DemoItem(text: "Auto Scrolling (Bottom Pin)"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(AutoScrollingViewController())
                })
                
                section += Item(
                    DemoItem(text: "Itemization Editor"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(ItemizationEditorViewController())
                })
                
                section += Item(
                    DemoItem(text: "English Dictionary Search"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(CollectionViewDictionaryDemoViewController())
                })
                
                section += Item(
                    DemoItem(text: "Keyboard Testing"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(KeyboardTestingViewController())
                })
                
                section += Item(
                    DemoItem(text: "Reordering (Experimental)"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(ReorderingViewController())
                })
                
                section += Item(
                    DemoItem(text: "Invoices Payment Schedule"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(InvoicesPaymentScheduleDemoViewController())
                })
                
                section += Item(
                    DemoItem(text: "Swipe Actions"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(SwipeActionsViewController())
                })
                
                section += Item(
                    DemoItem(text: "Item Content Coordinator"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(CoordinatorViewController())
                })
            }
            
            list += Section(identifier: "layouts") { section in
                
                section.header = HeaderFooter(
                    DemoHeader(title: "Other Layouts")
                )
                
                section += Item(
                    DemoItem(text: "Grid Layout"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(CustomLayoutsViewController())
                })
                
                section += Item(
                    DemoItem(text: "Paged Layout"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(PagedViewController())
                })
                
                section += Item(
                    DemoItem(text: "Horizontal Layout"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(HorizontalLayoutViewController())
                })
                
                section += Item(
                    DemoItem(text: "Width Customization"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(WidthCustomizationViewController())
                })

                section += Item(
                    DemoItem(text: "Spacing Customization"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(SpacingCustomizationViewController())
                })
            }
            
            list += Section(identifier: "selection-state") { section in
                
                section.header = HeaderFooter(
                    DemoHeader(title: "List View Selection")
                )

                section += Item(
                    DemoItem(text: "Tappable Row"),
                    selectionStyle: .tappable
                )
                
                section += Item(
                    DemoItem(text: "Tappable Row (Slow Is Selected)"),
                    selectionStyle: .tappable,
                    onSelect: { _ in
                        Thread.sleep(forTimeInterval: 0.5)
                    }
                )
            }
            
            list += Section(identifier: "collection-view") { section in
                
                section.header = HeaderFooter(
                    DemoHeader(title: "UICollectionViews")
                )

                section += Item(
                    DemoItem(text: "Flow Layout"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(FlowLayoutViewController())
                })
            }
            
            list += Section(identifier: "scroll-view") { section in
                
                section.header = HeaderFooter(
                    DemoHeader(title: "UIScrollViews")
                )
                
                section += Item(
                    DemoItem(text: "Edges Playground"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(ScrollViewEdgesPlaygroundViewController())
                })
            }
        }
    }
}

