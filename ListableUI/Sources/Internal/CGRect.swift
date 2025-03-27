import Foundation

extension CGRect {
    
    /// Returns the percentage from `0.0` to `1.0` that this rect overlaps `container`.
    func percentageVisible(inside container: CGRect) -> CGFloat {
        let overlap = intersection(container)
        let area = (width * height)
        guard area != 0 else { return 0 }
        return (overlap.width * overlap.height) / area
    }
}
