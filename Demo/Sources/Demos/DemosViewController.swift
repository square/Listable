//
//  DemosViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 6/24/19.
//

import UIKit
import Listable


public final class DemosViewController : ListViewController
{
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Listable"
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
                DemoHeader(
                    title: "Getting Started",
                    detail: "Examples of general usage of a ListView and its features."
                )
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
            
            section += Item(
                DemoTextItem(text: "Basic Demo"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(CollectionViewBasicDemoViewController())
                }
            )
            
            section += Item(
                DemoTextItem(text: "English Dictionary Search"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(CollectionViewDictionaryDemoViewController())
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
                DemoTextItem(text: "Keyboard Testing"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(KeyboardTestingViewController())
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
        
        list("list layout") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "List Layout (Default)")
            )
            
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
        
        list("paged layout") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "Paged Layout")
            )
            
            section += Item(
                DemoTextItem(text: "Paged Layout"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(PagedViewController())
            })
        }
        
        list("grid layout") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "Grid Layout")
            )
            
            section += Item(
                DemoTextItem(text: "Grid Layout"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(CustomLayoutsViewController())
            })
        }
        
        list("nested lists") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "Nested Lists")
            )
            
            section += Item(
                DemoTextItem(text: "Horizontal Layout"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(HorizontalLayoutViewController())
            })
        }
        
        list("selection-state") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "List View Selection")
            )

            section += Item(
                DemoTextItem(text: "Tappable Row"),
                selectionStyle: .tappable
            )
            
            section += Item(
                DemoTextItem(text: "Tappable Row (Slow Is Selected)"),
                selectionStyle: .tappable,
                onSelect: { _ in
                    Thread.sleep(forTimeInterval: 0.5)
                }
            )
        }
        
        list("experimental") { section in
            section += Item(
                DemoTextItem(text: "Reordering (Experimental)"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(ReorderingViewController())
            })
        }
        
        list("uikit") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "UIKit Example Screens")
            )

            section += Item(
                DemoTextItem(text: "Flow Layout"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(FlowLayoutViewController())
            })
            
            section += Item(
                DemoTextItem(text: "Edges Playground"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(ScrollViewEdgesPlaygroundViewController())
            })
        }
    }
}
