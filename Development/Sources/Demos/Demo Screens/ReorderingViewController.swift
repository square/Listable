//
//  ReorderingViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 11/13/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import UIKit

import ListableUI
import BlueprintUILists
import BlueprintUI
import BlueprintUICommonControls


final class ReorderingViewController : ListViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(reload))
    }
    
    @objc private func reload() {
        self.reload(animated: true)
    }
    
    override func configure(list: inout ListProperties) {
        
        list.appearance = .demoAppearance
        list.layout = .demoLayout
        
        list.stateObserver.onItemReordered { reordered in
            print("Moved: \(reordered.result.indexPathsDescription)")
            
            reordered.result.toSection.filtered(to: DemoItem.self) { items in
                print(items.map(\.text).joined(separator: "\n"))
            }
        }
        
        list += Section("1") { section in
            section.header = DemoHeader(title: "First Section")
            
            section.layouts.table.columns = .init(count: 2, spacing: 15.0)
            
            section += Item(DemoItem(text: "0,0 Row")) { item in
                item.reordering = ItemReordering(sections: .all)
            }
            
            section += Item(DemoItem(text: "0,1 Row")) { item in
                item.reordering = ItemReordering(sections: .all)
            }
            
            section += Item(DemoItem(text: "0,2 Row")) { item in
                item.reordering = ItemReordering(sections: .all)
            }
            
            section += Item(DemoItem(text: "0,3 Row")) { item in
                item.reordering = ItemReordering(sections: .all)
            }
        }
        
        list += Section("2") { section in
            section.header = DemoHeader(title: "Second Section")
            
            section += Item(DemoItem(text: "1,0  Row")) { item in
                item.reordering = ItemReordering(sections: .all)
                
            }
            
            section += Item(DemoItem(text: "1,1 Row")) { item in
                item.reordering = ItemReordering(sections: .all)
            }
        }
        
        list += Section("3") { section in
            section.header = DemoHeader(title: "Third Section")
            
            section += Item(DemoItem(text: "2,0  Row (Can't Move)")) { item in
                
                item.reordering = ItemReordering(sections: .all) { _ in
                    false
                }
            }
            
            section += Item(DemoItem(text: "2,1 Row (First Section Only)")) { item in
                item.reordering = ItemReordering(sections: .specific(current: false, IDs: ["1"]))
            }
            
            section += Item(DemoItem(text: "2,2 Row (Same Section Only)")) { item in
                item.reordering = ItemReordering(sections: .current)
            }
        }

        list += Section("4") { section in
            section.header = DemoHeader(title: "Long press")
            
            section += Item(DemoItem(text: "3,0 Row (long press)", requiresLongPress: true)) { item in
                item.reordering = ItemReordering(sections: .current)
            }

            section += Item(DemoItem(text: "3,1 Row (long press)", requiresLongPress: true)) { item in
                item.reordering = ItemReordering(sections: .current)
            }

            section += Item(DemoItem(text: "3,2 Row (long press)", requiresLongPress: true)) { item in
                item.reordering = ItemReordering(sections: .current)
            }
        }
        
        list += Section("5") { section in
            section.header = DemoHeader(title: "Tile Section")
            section.layouts.table.columns = .init(count: 2, spacing: 15.0)
            
            section += Item(DemoTile(text: "Item 0", secondaryText: "Section 4")) { item in
                item.reordering = ItemReordering(sections: .current)
            }
            section += Item(DemoTile(text: "Item 1", secondaryText: "Section 4")) { item in
                item.reordering = ItemReordering(sections: .current)
            }
            section += Item(DemoTile(text: "Item 2", secondaryText: "Section 4")) { item in
                item.reordering = ItemReordering(sections: .current)
            }
            section += Item(DemoTile(text: "Item 3", secondaryText: "Section 4")) { item in
                item.reordering = ItemReordering(sections: .current)
            }
        }
    }
}
