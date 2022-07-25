//
//  ViewAnimation.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 10/29/20.
//

import Foundation
import UIKit

/// Specifies the kind of animation to use when updating various parts of a list,
/// such as updating an item or scrolling to a given position.
public enum ViewAnimation {
    /// No animation is performed.
    case none

    /// The current animation is inherited from the superview's animation context.
    case inherited

    /// A default animation is performed. This is the same as `.animated()`.
    public static var `default`: Self = .animated()

    /// A `UIView.animate(...)` animation is performed.
    /// The default parameters are 0.25 seconds and `.curveEaseInOut` animation curve.
    case animated(TimeInterval = 0.25, options: Set<AnimationOptions> = .default)

    /// A spring based animation is performed.
    /// The default value is `UISpringTimingParameters()`.
    case spring(UISpringTimingParameters = .init())

    /// Ands the animation with the provided bool, returning the animation if true, and `.none` if false.
    public func and(with animated: Bool) -> ViewAnimation {
        if animated {
            return self
        } else {
            return .none
        }
    }

    /// Performs the provided animations for the `ViewAnimation`.
    public func perform(
        animations: @escaping () -> Void,
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        switch self {
        case .none:
            UIView.performWithoutAnimation {
                animations()
                completion(true)
            }

        case .inherited:
            animations()
            completion(true)

        case let .animated(duration, options):
            UIView.animate(
                withDuration: duration,
                delay: 0.0,
                options: options.toSystem,
                animations: {
                    animations()
                },
                completion: { finished in
                    completion(finished)
                }
            )

        case let .spring(timing):
            let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timing)

            animator.addAnimations(animations)

            animator.addCompletion {
                completion($0 == .end)
            }

            animator.startAnimation()
        }
    }
}

public extension ViewAnimation {
    /// The animations options available for the `ViewAnimation`.
    enum AnimationOptions: Hashable {
        case curveEaseInOut
        case curveEaseIn
        case curveEaseOut
        case curveLinear
    }
}

extension Set where Element == ViewAnimation.AnimationOptions {
    public static var `default`: Self { [
        .curveEaseInOut,
    ] }

    var toSystem: UIView.AnimationOptions {
        var options: UIView.AnimationOptions = []

        if contains(.curveEaseInOut) {
            options.formUnion(.curveEaseInOut)
        }

        if contains(.curveEaseIn) {
            options.formUnion(.curveEaseIn)
        }

        if contains(.curveEaseOut) {
            options.formUnion(.curveEaseOut)
        }

        if contains(.curveLinear) {
            options.formUnion(.curveLinear)
        }

        return options
    }
}
