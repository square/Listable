//
//  Sizing.Calculator.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/29/21.
//

import Foundation


extension Sizing {
    

    final class Calculator {
        
        private(set) var item : AnyItem
        
        private var sizes : [CachedSizeKey : CGSize]
        
        func removeAll() {
            self.sizes.removeAll()
        }
        
        func measure(item : AnyItem, in constraint : CGSize) -> CGFloat {
            
            
            
        }
        
        struct CachedSizeKey : Hashable
        {
            let constraint : Constraint
            let layoutDirection : LayoutDirection
            let sizing : Sizing
            let contentType : ObjectIdentifier
            
            init<Content>(
                constraint: Constraint,
                layoutDirection: LayoutDirection,
                sizing: Sizing,
                contentType: Content.Type
            ) {
                self.constraint = constraint
                self.layoutDirection = layoutDirection
                self.sizing = sizing
                self.contentType = ObjectIdentifier(Content.self)
            }
            
            struct Constraint : Hashable {
                let width : CGFloat
                let height : CGFloat
                
                init(_ size : CGSize) {
                    self.width = size.width
                    self.height = size.height
                }
            }
        }
    }
}
