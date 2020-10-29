//
//  ScrollAnimation.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 10/29/20.
//

import Foundation


/// Specifies the kind of animation to use when scrolling a list view.
public enum ScrollAnimation {
    
    /// No animation is performed.
    case none
    
    /// A default animation is performed. This is the same as `.custom()`.
    case `default`
    
    /// A custom animation is performed.
    /// The default parameters are 0.25 seconds and `.curveEaseInOut` animation curve.
    case custom(duration : TimeInterval = 0.25, options : Set<AnimationOptions> = .default)
    
    case spring(duration : TimeInterval = 0.25, timing : UISpringTimingParameters = .init())
    
    /// Ands the animation with the provided bool, returning the animation if true, and `.none` if false.
    public func and(with animated : Bool) -> ScrollAnimation {
        if animated {
            return self
        } else {
            return .none
        }
    }
    
    /// Performs the provided animations for the `ScrollAnimation`.
    public func perform(animations : @escaping () -> (), completion : @escaping (Bool) -> () = { _ in })
    {
        switch self {
        case .none:
            animations()
            completion(true)
            
        case .default:
            Self.custom().perform(
                animations: animations,
                completion: completion
            )
            
        case .custom(let duration, let options):
            UIView.animate(withDuration: duration, delay: 0.0, options: options.toSystem) {
                animations()
            } completion: { finished in
                completion(finished)
            }
            
        case .spring(let duration, let timing):
            let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timing)
            
            animator.addAnimations(animations)
            
            animator.addCompletion {
                completion($0 == .end)
            }
            
            animator.startAnimation()
        }
    }
}


extension ScrollAnimation {
    
    /// The animations options available for the `ScrollAnimation`.
    public enum AnimationOptions : Hashable {
        case curveEaseInOut
        case curveEaseIn
        case curveEaseOut
        case curveLinear
    }
}


extension Set where Element == ScrollAnimation.AnimationOptions {
    
    public static var `default` : Self {[
        .curveEaseInOut
    ]}
    
    var toSystem : UIView.AnimationOptions {
        var options : UIView.AnimationOptions = []
        
        if self.contains(.curveEaseInOut) {
            options.formUnion(.curveEaseInOut)
        }
        
        if self.contains(.curveEaseIn) {
            options.formUnion(.curveEaseIn)
        }
        
        if self.contains(.curveEaseOut) {
            options.formUnion(.curveEaseOut)
        }
        
        if self.contains(.curveLinear) {
            options.formUnion(.curveLinear)
        }
        
        return options
    }
}
