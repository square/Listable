//
//  LeftPanGestureRecognizer.swift
//  ListableUI
//
//  Created by Kyle Bashour on 4/21/20.
//

import UIKit.UIGestureRecognizerSubclass

/// `LeftPanGestureRecognizer` tracks horizontal swipes which begin to the left.
final class LeftPanGestureRecognizer: UIPanGestureRecognizer {

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {

        super.touchesMoved(touches, with: event)

        if state == .began {

            let velocity = self.velocity(in: view)

            if abs(velocity.y) > abs(velocity.x) {
                state = .cancelled
            }

            if velocity.x > 0 {
                state = .cancelled
            }
        }
    }
}
