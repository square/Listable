//
//  TouchDownGestureRecognizer.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 7/30/22.
//

import Foundation
import UIKit


final class TouchDownGestureRecognizer : UIGestureRecognizer {
    
    var shouldRecognize : (UITouch) -> Bool = { _ in false }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        
        if shouldRecognize(touch) {
            self.state = .recognized
        } else {
            self.state = .failed
        }
    }
    
    override func canPrevent(_ gesture: UIGestureRecognizer) -> Bool {
        
        // We want to allow the pan gesture of our containing scroll view to continue to track
        // when the user moves their finger vertically or horizontally, when we are cancelled.
        if let panGesture = gesture as? UIPanGestureRecognizer, panGesture.view is UIScrollView {
            return false
        }

        // We want to allow other pan gesture recognizers for swipe actions to continue to work
        if gesture is DirectionalPanGestureRecognizer {
            return false
        }


        return super.canPrevent(gesture)
    }
}
