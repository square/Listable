//
//  ColorTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 1/6/21.
//

import ListableUI
import UIKit
import XCTest

class ColorTests: XCTestCase {
    func test_equatable() {
        testcase("Regular colors") {
            XCTAssertEqual(Color(.black), Color(.black))
            XCTAssertNotEqual(Color(.black), Color(.blue))
        }

        if #available(iOS 13.0, *) {
            self.testcase("Dynamic colors") {
                XCTAssertEqual(
                    Color(.init(dynamicProvider: { _ in .black })),
                    Color(.init(dynamicProvider: { _ in .black }))
                )

                XCTAssertNotEqual(
                    Color(.init(dynamicProvider: { _ in .black })),
                    Color(.init(dynamicProvider: { _ in .blue }))
                )
            }
        }
    }
}
