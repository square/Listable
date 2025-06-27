import Foundation

extension CGRect {
    
    /// Returns the percentage from `0.0` to `1.0` that this rect overlaps `container`.
    func percentageVisible(inside container: CGRect) -> CGFloat {
        
        // Smooth out the container rect for edge cases:
        // - Sometimes viewport coordinates can be a fraction, like a viewport origin.y
        // coordinate of 71.00000000000003.
        // - In other cases, a programmatic scroll to an item that overhangs the screen
        // edge by less than 1.0 pts may execute its completion handler without the
        // viewport moving.
        let container = CGRect(
            x: floor(container.origin.x),
            y: floor(container.origin.y),
            width: ceil(container.width),
            height: ceil(container.height)
        )
        let overlap = intersection(container)
        let area = (width * height)
        guard area != 0 else { return 0 }
        return (overlap.width * overlap.height) / area
    }
}
