//
//  InternalDemosViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 6/24/19.
//

import UIKit
import Listable


public final class InternalDemosViewController : ListViewController
{
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Demos"
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    func push(_ viewController : UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    public override func configure(list: inout ListProperties) {
        
        list.appearance = .demoAppearance
        list.layout = .demoLayout
        
        list.content.overscrollFooter = HeaderFooter(
            DemoHeader(title: "Thanks for using Listable!!")
        )
        
        list("list-view") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "List Views")
            )
            
            section += Item(
                DemoTextItem(text: "Basic Demo"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(CollectionViewBasicDemoViewController())
                }
            )
            
            section += Item(
                DemoTextItem(text: "Blueprint Integration"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(BlueprintListDemoViewController())
            })

            section += Item(
                DemoTextItem(text: "Auto Scrolling (Bottom Pin)"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(AutoScrollingViewController())
            })
            
            if #available(iOS 13.0, *) {
                section += Item(
                    DemoTextItem(text: "List State & State Reader"),
                    selectionStyle: .selectable(),
                    onSelect: { _ in
                        self.push(ListStateViewController())
                    }
                )
            }

            section += Item(
                DemoTextItem(text: "Itemization Editor"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(ItemizationEditorViewController())
            })
            
            section += Item(
                DemoTextItem(text: "English Dictionary Search"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(CollectionViewDictionaryDemoViewController())
            })
            
            section += Item(
                DemoTextItem(text: "Keyboard Testing"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(KeyboardTestingViewController())
            })
            
            section += Item(
                DemoTextItem(text: "Reordering (Experimental)"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(ReorderingViewController())
            })
            
            section += Item(
                DemoTextItem(text: "Invoices Payment Schedule"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(InvoicesPaymentScheduleDemoViewController())
            })
            
            section += Item(
                DemoTextItem(text: "Swipe Actions"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(SwipeActionsViewController())
            })
            
            section += Item(
                DemoTextItem(text: "Item Content Coordinator"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(CoordinatorViewController())
            })
            
            section += Item(
                DemoTextItem(text: "Item Insert & Remove Animations"),
                selectionStyle: .selectable(),
                onSelect: { _ in
                    self.push(ItemInsertAndRemoveAnimationsViewController())
            })

            section += Item(
                DemoTextItem(text: "Manual Selection Management"),
                selectionStyle: .selectable(),
                onSelect: { _ in
                    self.push(ManualSelectionManagementViewController())
                }
            )
            
            section += Item(
                DemoTextItem(text: "Accordion View"),
                selectionStyle: .tappable,
                onSelect: { _ in
                    self.push(AccordionViewController())
            })
        }
        
        list("layouts") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "Other Layouts")
            )
            
            section += Item(
                DemoTextItem(text: "Grid Layout"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(CustomLayoutsViewController())
            })
            
            section += Item(
                DemoTextItem(text: "Paged Layout"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(PagedViewController())
            })
            
            section += Item(
                DemoTextItem(text: "Horizontal Layout"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(HorizontalLayoutViewController())
            })
            
            section += Item(
                DemoTextItem(text: "Width Customization"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(WidthCustomizationViewController())
            })

            section += Item(
                DemoTextItem(text: "Spacing Customization"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(SpacingCustomizationViewController())
            })
        }
        
        list("selection-state") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "List View Selection")
            )

            section += Item(
                DemoTextItem(text: "Tappable Row"),
                selectionStyle: .selectable()
            )
            
            section += Item(
                DemoTextItem(text: "Tappable Row (Slow Is Selected)"),
                selectionStyle: .selectable(),
                onSelect: { _ in
                    Thread.sleep(forTimeInterval: 0.5)
                }
            )
        }
        
        list("collection-view") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "UICollectionViews")
            )

            section += Item(
                DemoTextItem(text: "Flow Layout"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(FlowLayoutViewController())
            })
        }
        
        list("scroll-view") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "UIScrollViews")
            )
            
            section += Item(
                DemoTextItem(text: "Edges Playground"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(ScrollViewEdgesPlaygroundViewController())
            })
        }
    }
}

