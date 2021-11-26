//
//  FlowLayoutViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 11/25/21.
//  Copyright © 2021 Kyle Van Essen. All rights reserved.
//

@testable import ListableUI

import BlueprintUILists
import BlueprintUICommonControls


final class FlowLayoutViewController : ListViewController
{
    var isHorizontal : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Toggle Direction",
            style: .plain,
            target: self,
            action: #selector(toggleDirection)
        )
    }
    
    @objc private func toggleDirection() {
        self.isHorizontal.toggle()
        
        self.reload(animated: true)
    }
    
    override func configure(list: inout ListProperties) {
        
        list.appearance = .demoAppearance
        
        list.layout = .flow { flow in
                        
            flow.direction = isHorizontal ? .horizontal : .vertical
            
            flow.bounds = .init(
                padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                width: .atMost(900)
            )
            
            flow.spacings = .init(
                headerToFirstSectionSpacing: 20,
                interSectionSpacing: .init(30),
                sectionHeaderBottomSpacing: 10,
                itemSpacing: 10,
                rowSpacing: 10,
                rowToSectionFooterSpacing: 10,
                lastSectionToFooterSpacing: 20
            )
        }
        
        list.header = DemoHeader(title: "Flow Layout Demo")
        list.footer = DemoHeader(title: "Flow Layout Footer")
        
        let ipsums : [String] = [
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus non efficitur elit",
            "Maecenas at ligula vitae nisl blandit pulvinar id at nibh. Mauris consequat vitae turpis id finibus. Nam eget massa ac augue commodo auctor",
            "Morbi metus urna, ullamcorper in dapibus quis, ultricies id sem. Donec sodales efficitur odio, id pharetra ligula ornare vitae. Praesent lacinia mollis ipsum viverra molestie. Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            "Mauris a nisi efficitur sem aliquet efficitur. Aenean nec mollis turpis. Integer erat risus, laoreet tincidunt aliquet quis, vestibulum non felis.",
            "Donec urna magna, egestas et eros eu, pellentesque fringilla dui.",
            "Nunc tempor interdum lectus, a pellentesque lorem consectetur non. Maecenas ullamcorper dapibus odio interdum ullamcorper.",
            "Fusce aliquam tortor sit amet neque consequat faucibus. Nulla sem lorem, vehicula eget porta vitae, ultricies et sapien.",
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus non efficitur elit",
        ]
        
        list.add {
            for (alignment, description) in FlowAppearance.RowItemsAlignment.allTestCases {
                Section("\(alignment)") { section in
                    
                    section.header = DemoHeader(
                        title: description,
                        detail: """
                        The item alignment controls what happens when the items in the current \
                        row are not the same height, allowing you to control the vertical alignment.
                        """,
                        useMonospacedTitleFont: true
                    )
                    
                    section.layouts.flow.rowItemsAlignment = alignment
                    section.layouts.flow.itemSizing = .columns(3)
                    
                    section.add {
                        for ipsum in ipsums {
                            FlowItem(text: ipsum)
                        }
                    }
                }
            }
            
            for (underflow, description) in FlowAppearance.RowUnderflowAlignment.allTestCases {
                Section("\(underflow)") { section in
                    
                    section.header = DemoHeader(
                        title: description,
                        detail: """
                        The underflow alignment controls what happens when the items in the current \
                        row do not take up the full width of the layout; allowing you to align the results.
                        """,
                        useMonospacedTitleFont: true
                    )
                    
                    section.layouts.flow.rowUnderflowAlignment = underflow
                    section.layouts.flow.itemSizing = .fixed(200)
                    
                    section.add {
                        for ipsum in ipsums {
                            FlowItem(text: ipsum)
                        }
                    }
                }
            }
        }
    }
}


fileprivate struct FlowItem : BlueprintItemContent, Equatable {
    
    var text : String
    
    var identifierValue : String {
        text
    }
    
    func element(with info: ApplyItemContentInfo) -> Element {
        Label(text: text) {
            $0.numberOfLines = 0
            $0.color = .darkGray
        }
        .inset(uniform: 20.0)
        .box(background: .white, corners: .rounded(radius: 10))
    }
}
