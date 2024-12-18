import XCTest
@testable @_spi(CacheManagement) import ListableUI

class CacheClearerTests: XCTestCase {

    func test_clearStaticCaches() {

        ListProperties.headerFooterMeasurementCache.push(UIView(), with: .identifier(for: UIView.self))
        ListProperties.itemMeasurementCache.push(UIView(), with: .identifier(for: UIView.self))

        XCTAssertGreaterThanOrEqual(ListProperties.headerFooterMeasurementCache.cachedViewCount, 1)
        XCTAssertGreaterThanOrEqual(ListProperties.itemMeasurementCache.cachedViewCount, 1)

        CacheClearer.clearStaticCaches()
        
        XCTAssertEqual(ListProperties.headerFooterMeasurementCache.cachedViewCount, 0)
        XCTAssertEqual(ListProperties.itemMeasurementCache.cachedViewCount, 0)
    }
}
