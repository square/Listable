//
//  SizingTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

import XCTest
@testable import ListableUI

class SizingTests: XCTestCase
{
    //  MARK: - CustomWidth Tests

    func test_customWidth_alignment_originWith() {
        // Given
        let parentWidth: CGFloat = 100
        let width: CGFloat = 80
        let padding = HorizontalPadding(leading: 7, trailing: 3)

        // When: Left
        do {
            let alignment = CustomWidth.Alignment.leading
            let origin = alignment.originWith(parentWidth: parentWidth, width: width, padding: padding)

            // Should align left edge with left padding
            XCTAssertEqual(origin, 7)
        }

        // When: Center
        do {
            let alignment = CustomWidth.Alignment.center
            let origin = alignment.originWith(parentWidth: parentWidth, width: width, padding: padding)

            // Should center within width minus padding then offset by left padding
            XCTAssertEqual(origin, 12)
        }

        // When: Right
        do {
            let alignment = CustomWidth.Alignment.trailing
            let origin = alignment.originWith(parentWidth: parentWidth, width: width, padding: padding)

            // Should align right edge with right edge of width minus right padding
            XCTAssertEqual(origin, 17)
        }
    }
}
