//
//  PositioningTransformViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 5/17/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import Listable
import UIKit


final class PositioningTransformViewController : UIViewController
{
    let listView = ListView()
    
    override func loadView() {
        
        self.listView.appearance = demoAppearance
        
        let positioningTransform : PositioningTransformation.Provider = { input in
            
            let fromBottom = input.listBounds.maxY - input.itemFrame.minY
            let maxFromBottom : CGFloat = 100.0
            
            let maxDistance = input.listSafeAreaInsets.bottom + input.itemFrame.height
            
            if fromBottom < maxFromBottom {
                let scale = (0.75...1.0).containedValue(for: fromBottom, in: 0...maxDistance)
                let alpha = (0.25...1.0).containedValue(for: fromBottom, in: 0...maxDistance)
                
                let transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)

                return .init(alpha: alpha, transform: .affine(transform))
            }
            
            return .none
        }
        
        self.listView.setContent { list in
            list += Section(identifier: "section-1") { section in
                
                section.header = HeaderFooter(
                    DemoHeader(title: "Section 1")
                )
                
                section += (1...50).map { index in
                    Item(
                        DemoItem(text: "Item #\(index)"),
                        positioningTransformation: positioningTransform
                    )
                }
            }
        }
        
        self.view = self.listView
    }
}
