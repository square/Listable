//
//  PresentationState.SectionStateTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 5/22/20.
//

import XCTest
@testable import ListableUI


class PresentationState_SectionStateTests : XCTestCase
{
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


fileprivate struct TestHeader1 : HeaderFooterContent, Equatable {

    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView()
    }
    
    func apply(
        to views: HeaderFooterContentViews<TestHeader1>,
        for reason: ApplyReason,
        with info: ApplyHeaderFooterContentInfo
    ) { }
}

fileprivate struct TestHeader2 : HeaderFooterContent, Equatable {

    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView()
    }
    
    func apply(
        to views: HeaderFooterContentViews<TestHeader2>,
        for reason: ApplyReason,
        with info: ApplyHeaderFooterContentInfo
    ) { }
}
