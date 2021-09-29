//
//  ReappliesToVisibleViewTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 7/31/21.
//

@testable import ListableUI
import XCTest


class ReappliesToVisibleViewTests : XCTestCase {
    
    func test_shouldReapply() {

        let always = ReappliesToVisibleView.always
        let ifNotEquivalent = ReappliesToVisibleView.ifNotEquivalent
        
        XCTAssertTrue(always.shouldReapply(comparing: .always, isEquivalent: true))
        XCTAssertTrue(always.shouldReapply(comparing: .always, isEquivalent: false))
        
        XCTAssertTrue(always.shouldReapply(comparing: .ifNotEquivalent, isEquivalent: true))
        XCTAssertTrue(always.shouldReapply(comparing: .ifNotEquivalent, isEquivalent: false))
        
        XCTAssertFalse(ifNotEquivalent.shouldReapply(comparing: .ifNotEquivalent, isEquivalent: true))
        XCTAssertTrue(ifNotEquivalent.shouldReapply(comparing: .ifNotEquivalent, isEquivalent: false))
    }
}
