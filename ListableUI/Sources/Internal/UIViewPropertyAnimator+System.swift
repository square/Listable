//
//  UIViewPropertyAnimator+System.swift
//  ListableUI
//
//  Created by Kyle Bashour on 4/17/20.
//

import UIKit

extension UIViewPropertyAnimator {

    /// Create a UIViewPropertyAnimator with the same animation curve as most system animations
    /// (including view controller presentation and navigation controller pushes).
    ///
    /// This is a critically damped spring, and the duration is based on the spring physics.
    convenience init(system animations: @escaping () -> Void) {
        let params = UISpringTimingParameters()
        // When using UISpringTimingParameters, UIViewPropertyAnimator ignores the duration value.
        // Unfortunately, the init requires one, but 1 has no meaning.
        self.init(duration: 1, timingParameters: params)
        addAnimations(animations)
    }
}
