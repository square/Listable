import UIKit

/// Tracks horizontal pans that begin in a particular direction.
final class DirectionalPanGestureRecognizer: UIPanGestureRecognizer {
    
    /// A horizontal direction.
    enum Direction {
        case rightToLeft
        case leftToRight
    }
    
    /// The direction of the tracked pan gesture.
    public let direction: Direction
    
    init(direction: Direction, target: Any?, action: Selector?) {
        self.direction = direction
        super.init(target: target, action: action)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {

        super.touchesMoved(touches, with: event)

        if state == .began {

            let velocity = self.velocity(in: view)
            
            guard abs(velocity.y) <= abs(velocity.x) else {
                state = .cancelled
                return
            }
            
            switch direction {
            case .rightToLeft:
                
                if velocity.x > 0 {
                    state = .cancelled
                }
                
            case .leftToRight:
                
                if velocity.x < 0 {
                    state = .cancelled
                }
                
            }
        }
    }
}
