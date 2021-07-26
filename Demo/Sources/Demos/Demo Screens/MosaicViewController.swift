//
//  MosaicViewController.swift
//  Demo
//
//  Created by Gabriel Hernandez Ontiveros on 2021-07-23.
//  Copyright © 2021 Kyle Van Essen. All rights reserved.
//

import UIKit

import ListableUI
import BlueprintUILists


final class MosaicViewController : UIViewController
{
    let listView = ListView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Switch scrolling", style: .plain, target: self, action: #selector(swapLayout))

        view.addSubview(listView)
        
        NSLayoutConstraint.activate([
            listView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            listView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            listView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            listView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        setupList()
    }
    
    func setupList() {
        self.listView.translatesAutoresizingMaskIntoConstraints = false
        self.listView.appearance = .demoAppearance
        self.listView.layout = .mosaicDemo(columns: 5, rows: .rows(5))
        
        self.listView.configure { list in
            
            list += Section("default") { section in
                
                section += Item(DemoItem(text: "Single")) { item in
                    item.layouts.mosaic = MosaicAppearance.ItemLayout(
                        origin: .init(x: 0, y: 0), size: .single
                    )
                }

                section += Item(DemoItem(text: "Wide")) { item in
                    item.layouts.mosaic = MosaicAppearance.ItemLayout(
                        origin: .init(x: 1, y: 0), size: .wide
                    )
                }

                section += Item(DemoItem(text: "Tall")) { item in
                    item.layouts.mosaic = MosaicAppearance.ItemLayout(
                        origin: .init(x: 3, y: 0), size: .tall
                    )
                }

                section += Item(DemoItem(text: "Big")) { item in
                    item.layouts.mosaic = MosaicAppearance.ItemLayout(
                        origin: .init(x: 1, y: 1), size: .big
                    )
                }

                section += Item(DemoItem(text: "Single")) { item in
                    item.layouts.mosaic = MosaicAppearance.ItemLayout(
                        origin: .init(x: 4, y: 4), size: .single
                    )
                }

                section += Item(DemoItem(text: "Single")) { item in
                    item.layouts.mosaic = MosaicAppearance.ItemLayout(
                        origin: .init(x: 0, y: 1), size: .single
                    )
                }

                section += Item(DemoItem(text: "Single")) { item in
                    item.layouts.mosaic = MosaicAppearance.ItemLayout(
                        origin: .init(x: 0, y: 2), size: .single
                    )
                }

                section += Item(DemoItem(text: "Single")) { item in
                    item.layouts.mosaic = MosaicAppearance.ItemLayout(
                        origin: .init(x: 0, y: 3), size: .single
                    )
                }

                section += Item(DemoItem(text: "Single")) { item in
                    item.layouts.mosaic = MosaicAppearance.ItemLayout(
                        origin: .init(x: 0, y: 4), size: .single
                    )
                }

                section += Item(DemoItem(text: "Single")) { item in
                    item.layouts.mosaic = MosaicAppearance.ItemLayout(
                        origin: .init(x: 4, y: 0), size: .single
                    )
                }

                section += Item(DemoItem(text: "Single")) { item in
                    item.layouts.mosaic = MosaicAppearance.ItemLayout(
                        origin: .init(x: 0, y: 5), size: .single
                    )
                }

                section += Item(DemoItem(text: "Single")) { item in
                    item.layouts.mosaic = MosaicAppearance.ItemLayout(
                        origin: .init(x: 1, y: 5), size: .single
                    )
                }

                section += Item(DemoItem(text: "Single")) { item in
                    item.layouts.mosaic = MosaicAppearance.ItemLayout(
                        origin: .init(x: 0, y: 10), size: .single
                    )
                }
                
                section += Item(DemoItem(text: "Single")) { item in
                    item.layouts.mosaic = MosaicAppearance.ItemLayout(
                        origin: .init(x: 1, y: 10), size: .single
                    )
                }
            }
        }
    }
    
    private var infiniteScollOn : Bool = false
    
    @objc func swapLayout()
    {
        self.infiniteScollOn.toggle()
        
        if self.infiniteScollOn {
            self.listView.set(layout: .mosaicDemo(columns: 5, rows: .infinite), animated: true)
        } else {
            self.listView.set(layout: .mosaicDemo(columns: 5, rows: .rows(5)), animated: true)
        }
    }
}
