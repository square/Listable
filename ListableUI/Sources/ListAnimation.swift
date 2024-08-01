//
//  ListAnimation.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 7/15/24.
//

import Foundation
import UIKit


/// Controls the animation to use when updating the content of a list.
public struct ListAnimation {
    
    /// The animation block.
    public typealias Animations = () -> ()
    
    /// The block which is invoked to perform the animaton.
    var perform : (@escaping Animations) -> ()
    
    /// Creates a new animation. in your custom animation, you _must_ invoke the passed
    /// in `Animations` block within `UIView.animate(...)` or other animation such as a `UIViewPropertyAnimator`.
    public init(_ perform : @escaping (@escaping Animations) -> ()) {
        self.perform = perform
    }
    
    /// The default animation provided by `UICollectionView`.
    public static let `default` : Self = .init { animations in
        animations()
    }
    
    /// A faster animation than the default `UICollectionView` animation.
    public static let fast : Self = .init { animations in
        UIView.animate(withDuration: 0.15, animations: animations)
    }
}
