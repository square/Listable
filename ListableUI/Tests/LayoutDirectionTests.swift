//
//  LayoutDirectionTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

import XCTest
@testable import ListableUI


class LayoutDirectionTests: XCTestCase
{
    func test_safeAreaInsetsFor() {
        
        XCTAssertEqual(
            LayoutDirection.vertical.safeAreaInsetsFor(
                itemFrame: CGRect(x: 0, y: 0, width: 100, height: 100),
                layoutBounds: CGRect(x: 0, y: 0, width: 100, height: 100),
                viewSafeArea: UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
            ),
            UIEdgeInsets(
                top: 0,
                left: 20,
                bottom: 0,
                right: 40
            )
        )
        
        XCTAssertEqual(
            LayoutDirection.horizontal.safeAreaInsetsFor(
                itemFrame: CGRect(x: 0, y: 0, width: 100, height: 100),
                layoutBounds: CGRect(x: 0, y: 0, width: 100, height: 100),
                viewSafeArea: UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
            ),
            UIEdgeInsets(
                top: 10,
                left: 0,
                bottom: 30,
                right: 0
            )
        )
    }
}
