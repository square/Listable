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
                DemoTitleDetailItem(
                    title: "Blueprint Lists",
                    detail: "Shows how to create a simple ListView in Blueprint."
                ),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(BlueprintListDemoViewController())
            })
            
            section += Item(
                DemoTitleDetailItem(
                    title: "Auto Scrolling (Bottom Pin)",
                    detail: "Shows how to leverage auto scrolling to keep a specific item visible as content is added or removed from the list."
                ),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(AutoScrollingViewController())
            })

            if #available(iOS 13.0, *) {
                section += Item(
                    DemoTitleDetailItem(
                        title: "List State & State Reader",
                        detail: "How to listen for changes to a list using ListStateObserver, and how to manage the list using ListActions."
                    ),
                    selectionStyle: .selectable(),
                    onSelect: { _ in
                        self.push(ListStateViewController())
                    }
                )
            }
                        
            section += Item(
                DemoTitleDetailItem(
                    title: "Keyboard Configuration",
                    detail: "How to set up a list to respect the positioning of the keyboard (or not)."
                ),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(KeyboardTestingViewController())
            })

            section += Item(
                DemoTitleDetailItem(
                    title: "Swipe Actions",
                    detail: "Set up swipe actions on items in a list, similar to what you would see in a UITableView in Mail.app or other apps."
                ),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(SwipeActionsViewController())
            })

            section += Item(
                DemoTitleDetailItem(
                    title: "Item Insert & Remove Animations",
                    detail: "Listable defaults to .top for insert and removal animations. You can customize this animation using any of the options shown in this list, or create your own."
                ),
                selectionStyle: .selectable(),
                onSelect: { _ in
                    self.push(ItemInsertAndRemoveAnimationsViewController())
            })
        }
        
        list("list layout") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "List Layouts")
            )
            
            section += Item(
                DemoTitleDetailItem(
                    title: "Layout Customization",
                    detail: "How to customize the layout of Items in a list, changing their alignment and fill from the default."
                ),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(WidthCustomizationViewController())
            })

            section += Item(
                DemoTitleDetailItem(
                    title: "Spacing Customization",
                    detail: "How to customize the spacing between content in a list, with examples."
                ),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(SpacingCustomizationViewController())
            })
        }
        
        list("paged layout") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "Paged Layouts")
            )
            
            section += Item(
                DemoTitleDetailItem(
                    title: "Paged Layout",
                    detail: "Setting up a basic paged layout to represent content, similar to a UIPageViewController."
                ),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(PagedViewController())
            })
        }
        
        list("grid layout") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "Grid Layouts")
            )
            
            section += Item(
                DemoTitleDetailItem(
                    title: "Grid Layout",
                    detail: "Setting up a basic grid layout to represent content."
                ),
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
                DemoTitleDetailItem(
                    title: "Horizontal Layout",
                    detail: "Shows how to nest a horiztonally scrolling list into a vertically scrolling list."
                ),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(HorizontalLayoutViewController())
            })
        }
        
        list("demo screens") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "Demo Screens")
            )
            
            section += Item(
                DemoTitleDetailItem(
                    title: "Itemization Editor",
                    detail: "Create an column-based editor UI similar to the one in Square Point of Sale."
                ),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(ItemizationEditorViewController())
            })
            
            section += Item(
                DemoTitleDetailItem(
                    title: "English Dictionary Search",
                    detail: "A searchable English dictionary, rendering words and their definitions."
                ),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(CollectionViewDictionaryDemoViewController())
            })
            
            section += Item(
                DemoTitleDetailItem(
                    title: "Accordion View",
                    detail: "Create an accordian-based UI, where sections expand and collapse their items based on an onTap handler."
                ),
                selectionStyle: .tappable,
                onSelect: { _ in
                    self.push(AccordionViewController())
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
            
            section.header = HeaderFooter(
                DemoHeader(
                    title: "Experimental",
                    detail: "Features which aren't quite ready for prime time yet."
                )
            )
            
            section += Item(
                DemoTextItem(text: "Reordering (Experimental)"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(ReorderingViewController())
            })
            
            section += Item(
                DemoTextItem(text: "Item Content Coordinator"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(CoordinatorViewController())
            })
        }
        
        list("internal") { section in
            
            section.header = HeaderFooter(
                DemoHeader(
                    title: "Internal Demos",
                    detail: "Demos mainly meant for developers of Listable, with specific implementations to test for or trigger bugs or specific behaviors."
                )
            )
            
            section += Item(
                DemoTextItem(text: "Basic Demo"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(CollectionViewBasicDemoViewController())
                }
            )
            
            section += Item(
                DemoTextItem(text: "Invoices Payment Schedule"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(InvoicesPaymentScheduleDemoViewController())
            })
            
            section += Item(
                DemoTextItem(text: "Manual Selection Management"),
                selectionStyle: .selectable(),
                onSelect: { _ in
                    self.push(ManualSelectionManagementViewController())
                }
            )
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
