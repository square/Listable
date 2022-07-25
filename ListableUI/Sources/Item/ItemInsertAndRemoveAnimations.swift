//
//  ItemInsertAndRemoveAnimations.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/18/20.
//

import UIKit

/// Controls the animations that are displayed when an item is inserted into, or removed from, a list.
///
/// ### Note
/// If `UIAccessibility.isReduceMotionEnabled` is `true`, animations will fall
/// back to a `.fade` style animation when displayed by the list view.
public struct ItemInsertAndRemoveAnimations {
    public typealias Prepare = (inout ListContentLayoutAttributes) -> Void

    public var name: String

    public var onInsert: Prepare
    public var onRemoval: Prepare

    public init(
        name: String,
        onInsert: @escaping Prepare,
        onRemoval: @escaping Prepare
    ) {
        self.name = name
        self.onInsert = onInsert
        self.onRemoval = onRemoval
    }

    public init(
        name: String,
        attributes: @escaping Prepare
    ) {
        self.name = name

        onInsert = attributes
        onRemoval = attributes
    }
}

public extension ItemInsertAndRemoveAnimations {
    static var fade: Self {
        Self(
            name: "fade",
            onInsert: {
                $0.alpha = 0.0
            },
            onRemoval: {
                $0.alpha = 0.0
            }
        )
    }

    static var right: Self {
        Self(
            name: "right",
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

    static var left: Self {
        Self(
            name: "left",
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

    static var top: Self {
        Self(
            name: "top",
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

    static var bottom: Self {
        Self(
            name: "bottom",
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

    static var scaleDown: Self {
        Self(
            name: "scaleDown",
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

    static var scaleUp: Self {
        Self(
            name: "scaleUp",
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
