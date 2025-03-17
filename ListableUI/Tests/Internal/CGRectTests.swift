@testable import ListableUI
import XCTest

final class CGRectTests: XCTestCase {

    func test_percentageVisible_noOverlap() {
        let containerRect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let itemRect = CGRect(x: 200, y: 200, width: 10, height: 10)
        
        XCTAssertEqual(
            itemRect.percentageVisible(inside: containerRect),
            0
        )
    }
    
    func test_percentageVisible_partialOverlap() {
        let containerRect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let itemRect = CGRect(x: 50, y: 0, width: 100, height: 100)
        
        XCTAssertEqual(
            itemRect.percentageVisible(inside: containerRect),
            0.5
        )
    }
    
    func test_percentageVisible_fullOverlap() {
        let containerRect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let itemRect = CGRect(x: 10, y: 10, width: 25, height: 25)
        
        XCTAssertEqual(
            itemRect.percentageVisible(inside: containerRect),
            1.0
        )
    }
}
