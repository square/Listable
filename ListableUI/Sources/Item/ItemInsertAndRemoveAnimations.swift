//
//  ItemInsertAndRemoveAnimations.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/18/20.
//

import UIKit


public struct ItemInsertAndRemoveAnimations
{
    public typealias Prepare = (inout ListContentLayoutAttributes) -> ()
    
    public var onInsert : Prepare
    public var onRemoval : Prepare
    
    public init(
        onInsert : @escaping Prepare,
        onRemoval : @escaping Prepare
    ) {
        self.onInsert = onInsert
        self.onRemoval = onRemoval
    }
    
    public init(attributes : @escaping Prepare)
    {
        self.onInsert = attributes
        self.onRemoval = attributes
    }
}


public extension ItemInsertAndRemoveAnimations
{
    static var fade : Self {
                Self(
            onInsert: {
                $0.alpha = 0.0
            },
            onRemoval: {
                $0.alpha = 0.0
            }
        )
    }
    
    static var right : Self {
        Self(
            onInsert: {
                $0.frame.origin.x += $0.frame.width
                $0.alpha = 0.0
            },
            onRemoval: {
                $0.frame.origin.x += $0.frame.width
                $0.alpha = 0.0
            }
        )
    }
    
    static var left : Self {
        Self(
            onInsert: {
                $0.frame.origin.x -= $0.frame.width
                $0.alpha = 0.0
            },
            onRemoval: {
                $0.frame.origin.x -= $0.frame.width
                $0.alpha = 0.0
            }
        )
    }
    
    static var top : Self {
        Self(
            onInsert: {
                $0.frame.origin.y -= $0.frame.height
                $0.alpha = 0.0
            },
            onRemoval: {
                $0.frame.origin.y -= $0.frame.height
                $0.alpha = 0.0
            }
        )
    }
    
    static var bottom : Self {
        Self(
            onInsert: {
                $0.frame.origin.y += $0.frame.height
                $0.alpha = 0.0
            },
            onRemoval: {
                $0.frame.origin.y += $0.frame.height
                $0.alpha = 0.0
            }
        )
    }
    
    static var scaleDown : Self {
        Self(
            onInsert: {
                $0.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
                $0.alpha = 0.0
            },
            onRemoval: {
                $0.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
                $0.alpha = 0.0
            }
        )
    }
    
    static var scaleUp : Self {
        Self(
            onInsert: {
                $0.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
                $0.alpha = 0.0
            },
            onRemoval: {
                $0.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
                $0.alpha = 0.0
            }
        )
    }
}
