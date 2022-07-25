//
//  PresentationState.SectionStateTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 5/22/20.
//

@testable import ListableUI
import XCTest

class PresentationState_SectionStateTests: XCTestCase {
    func test_headerFooterState() {
        // Ensure that passing the same type keeps the same state.

        let first = PresentationState.HeaderFooterState(HeaderFooter(TestHeader1()))

        let second = PresentationState.SectionState.headerFooterState(
            current: first,
            new: TestHeader1(),
            performsContentCallbacks: false
        )

        XCTAssertTrue(first === second)

        let third = PresentationState.SectionState.headerFooterState(
            current: first,
            new: HeaderFooter(TestHeader1()),
            performsContentCallbacks: false
        )

        XCTAssertTrue(second === third)

        // Changing the type changes the state instance.

        let fourth = PresentationState.SectionState.headerFooterState(
            current: first,
            new: TestHeader2(),
            performsContentCallbacks: false
        )

        XCTAssertTrue(third !== fourth)
    }
}

private struct TestHeader1: HeaderFooterContent, Equatable {
    static func createReusableContentView(frame _: CGRect) -> UIView {
        UIView()
    }

    func apply(
        to _: HeaderFooterContentViews<TestHeader1>,
        for _: ApplyReason,
        with _: ApplyHeaderFooterContentInfo
    ) {}
}

private struct TestHeader2: HeaderFooterContent, Equatable {
    static func createReusableContentView(frame _: CGRect) -> UIView {
        UIView()
    }

    func apply(
        to _: HeaderFooterContentViews<TestHeader2>,
        for _: ApplyReason,
        with _: ApplyHeaderFooterContentInfo
    ) {}
}
