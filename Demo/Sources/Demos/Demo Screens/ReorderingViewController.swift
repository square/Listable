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
    fileprivate var reorderingStorage: ReorderingStorage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(reload))
        
        reorderingStorage = .init()
    }
    
    @objc private func reload() {
        self.reload(animated: true)
    }
    
    override func configure(list: inout ListProperties) {
        
        list.appearance = .demoAppearance
        list.layout = .demoLayout
        
        list.stateObserver.onItemReordered { [weak self] reordered in
            print("Moved: \(reordered.result.indexPathsDescription)")
            
            reordered.result.toSection.filtered(to: DemoItem.self) { items in
                print(items.map(\.text).joined(separator: "\n"))
            }
            
            self?.reorderingStorage.reset()
            self?.reload()
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
            
            reorderingStorage.rows.forEach {
                section += Item($0) { item in
                    item.reordering = ItemReordering(sections: .current)
                    item.onStartReorder = { [weak self] item in
                        self?.reorderingStorage.setDragging(item.identifier.value, dragging: true)
                        DispatchQueue.main.async {
                            self?.reload()
                        }
                    }
                }
            }
        }
    }
}

private final class ReorderingStorage {
    
    var rows: [DemoItem] {
        allRows.values.sorted {
            $0.identifierValue < $1.identifierValue
        }
    }

    private var allRows : [String: DemoItem] = {
        [
            "Row 1": DemoItem(text: "Row 1", requiresLongPress: true),
            "Row 2": DemoItem(text: "Row 2", requiresLongPress: true),
            "Row 3": DemoItem(text: "Row 3", requiresLongPress: true)
        ]
    }()

    func setDragging(_ id: String, dragging: Bool) {
        var row = allRows[id]
        row?.dragging = dragging
        if let row = row {
            allRows[id] = row
        }
    }

    func reset() {
        allRows.forEach { (key, _) in
            setDragging(key, dragging: false)
        }
    }
}
