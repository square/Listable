import Foundation

extension CGRect {
    
    /// Returns the percentage from `0.0` to `1.0` that this rect overlaps `container`.
    func percentageVisible(inside container: CGRect) -> CGFloat {
        let overlap = intersection(container)
        return (overlap.width * overlap.height) / (width * height)
    }
}
