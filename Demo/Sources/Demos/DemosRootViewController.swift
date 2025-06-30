//
//  TableViewDemosRootViewController.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/24/19.
//

import UIKit
import ListableUI


public final class DemosRootViewController : ListViewController
{
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Demos"
    }
    
    func push(_ viewController : UIViewController) {
        DemoNavigationController.setPushedDemo(viewController)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    public override func configure(list: inout ListProperties) {
        
        list.appearance = .demoAppearance
        list.layout = .demoLayout
        
        list.content.overscrollFooter = DemoHeader(title: "Thanks for using Listable!!")

        list.content.header = DemoHeader(title: "Sticky List Header")

        list.add {
            Section("list") { [weak self] in
                Item(
                    DemoItem(text: "Basic Demo"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(CollectionViewBasicDemoViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Blueprint Integration"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(BlueprintListDemoViewController())
                    }
                )

                Item(
                    DemoItem(text: "Auto Scrolling (Bottom Pin: scrollTo)"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(AutoScrollingViewController())
                    }
                )

                Item(
                    DemoItem(text: "Auto Scrolling2 (Bottom Pin: pin)"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(AutoScrollingViewController2())
                    }
                )

                Item(
                    DemoItem(text: "Auto Scrolling3 (Center Pin: scrollTo + bottom gravity)"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(ScrollToAutoscrollingViewController())
                    }
                )

                Item(
                    DemoItem(text: "Auto Scrolling3 (Center Pin: pin + bottom gravity)"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(PinAutoscrollingViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "scrollTo(item: ...) completion handler"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(ScrollToItemCompletionHandlerViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "scrollToSection(...) completion handler"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(ScrollToSectionCompletionHandlerViewController())
                    }
                )

                Item(
                    DemoItem(text: "List State & State Reader"),
                    selectionStyle: .selectable(),
                    onSelect: { _ in
                        self?.push(ListStateViewController())
                    }
                )

                Item(
                    DemoItem(text: "Itemization Editor"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(ItemizationEditorViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Chat App"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(ChatDemoViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "English Dictionary Search"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(SearchableDictionaryViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Keyboard Inset (Full Screen List)"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(KeyboardTestingViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Keyboard Inset (Appears Later)"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(ListAppearsAfterKeyboardViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Reordering"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(ReorderingViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Payment Types (Reordering)"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(PaymentTypesViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Multi-Select"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(MultiSelectViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Toggle Selection"),
                    selectionStyle: .toggles(),
                    onSelect : { _ in
                        print("Selected")
                    },
                    onDeselect: { _ in
                        print("Deselected")
                    }
                )
                
                Item(
                    DemoItem(text: "Invoices Payment Schedule"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(InvoicesPaymentScheduleDemoViewController())
                    }
                )

                Item(
                    DemoItem(text: "Refresh Control"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(RefreshControlOffsetAdjustmentViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Swipe Actions"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(SwipeActionsViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Localized Collation"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(LocalizedCollationViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Item Insert & Remove Animations"),
                    selectionStyle: .selectable(),
                    onSelect: { _ in
                        self?.push(ItemInsertAndRemoveAnimationsViewController())
                    }
                )

                Item(
                    DemoItem(text: "Manual Selection Management"),
                    selectionStyle: .selectable(),
                    onSelect: { _ in
                        self?.push(ManualSelectionManagementViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Accordion View"),
                    selectionStyle: .tappable,
                    onSelect: { _ in
                        self?.push(AccordionViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Using Autolayout"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(AutoLayoutDemoViewController())
                    }
                )
            } header: {
                DemoHeader(title: "List Views")
            }
            
            Section(
                "coordinator",
                layouts: .table {
                    $0.isHeaderSticky = false
                }
            ) { [weak self] in
                
                Item(
                    DemoItem(text: "Expand / Collapse Items"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(CoordinatorViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Animating On Tap"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(OnTapItemAnimationViewController())
                    }
                )
            } header: {
                DemoHeader(title: "Item Coordinator")
            }
            
            Section("layouts") { [weak self] in
                
                Item(
                    DemoItem(text: "Flow Layout"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(FlowLayoutViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Paged Layout"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(PagedViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Peeking Paged Layout"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(PeekingPagedViewController())
                    }
                )

                Item(
                    DemoItem(text: "Center-Snapping Table Layout"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(CenterSnappingTableViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Carousel-Style Layouts"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(CarouselLayoutViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Horizontal Layout"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(HorizontalLayoutViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Width Customization"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(WidthCustomizationViewController())
                    }
                )

                Item(
                    DemoItem(text: "Spacing Customization"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(SpacingCustomizationViewController())
                    }
                )
            } header: {
                DemoHeader(title: "Other Layouts")
            }
            
            Section("testing") { [weak self] in

                Item(
                    DemoItem(text: "Fuzz Testing"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(UpdateFuzzingViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Testing Header Association"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(SupplementaryTestingViewController())
                    }
                )
                
                Item(
                    DemoItem(text: "Verify Reuse Has No Animation"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(AnimatedReuseViewController())
                    }
                )
            } header: {
                DemoHeader(title: "Testing")
            }
            
            Section("selection-state") {

                Item(
                    DemoItem(text: "Tappable Row"),
                    selectionStyle: .tappable
                )
                
                Item(
                    DemoItem(text: "Tappable Row (Slow Is Selected)"),
                    selectionStyle: .tappable,
                    onSelect: { _ in
                        Thread.sleep(forTimeInterval: 0.5)
                    }
                )
            } header: {
                DemoHeader(title: "List View Selection")
            }
            
            Section("collection-view") { [weak self] in

                Item(
                    DemoItem(text: "System Flow Layout"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(SystemFlowLayoutViewController())
                    }
                )
            } header: {
                DemoHeader(title: "UICollectionViews")
            }
            
            Section("scroll-view") { [weak self] in
                
                Item(
                    DemoItem(text: "Edges Playground"),
                    selectionStyle: .selectable(),
                    onSelect : { _ in
                        self?.push(ScrollViewEdgesPlaygroundViewController())
                    }
                )
            } header: {
                DemoHeader(title: "UIScrollViews")
            }
        }
    }
}

