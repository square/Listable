//
//  ListScrollPositionInfoTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 5/4/20.
//

import XCTest
import UIKit
@testable import ListableUI


final class UIRectEdgeTests : XCTestCase
{
    func test_visibleScrollViewContentEdges()
    {
        do {
            // No offset + no safe area should mean all edges are visible.
            
            let edges = UIRectEdge.visibleScrollViewContentEdges(
                bounds: CGRect(origin: .zero, size: CGSize(width: 200, height: 100)),
                contentSize: CGSize(width: 100.0, height: 50.0),
                safeAreaInsets: .zero
            )
            
            XCTAssertEqual(edges, .all)
        }
        
        do {
            // No offset + safe area should mean the edges outside the safe area are not visible.
            
            let edges = UIRectEdge.visibleScrollViewContentEdges(
                bounds: CGRect(origin: .zero, size: CGSize(width: 200, height: 100)),
                contentSize: CGSize(width: 100.0, height: 50.0),
                safeAreaInsets: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 20.0, right: 10.0)
            )
            
            XCTAssertEqual(edges, [.bottom, .right])
        }

        do {
            // No offset + safe area should mean the edges outside the safe area are not visible.
            
            let edges = UIRectEdge.visibleScrollViewContentEdges(
                bounds: CGRect(origin: CGPoint(x: -100.0, y: -50.0), size: CGSize(width: 200, height: 100)),
                contentSize: CGSize(width: 100.0, height: 50.0),
                safeAreaInsets: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 20.0, right: 10.0)
            )
            
            XCTAssertEqual(edges, [.top, .left])
        }

    }
    
    func test_mostVisibleItem() {
        
        let items: Set<ListScrollPositionInfo.VisibleItem> = [
            .init(identifier: Identifier<TestingType, Int>(0), percentageVisible: 0.25),
            .init(identifier: Identifier<TestingType, Int>(1), percentageVisible: 0.5),
            .init(identifier: Identifier<TestingType, Int>(2), percentageVisible: 1.0),
            .init(identifier: Identifier<TestingType, Int>(3), percentageVisible: 0.0),
        ]
        
        let info = ListScrollPositionInfo(
            scrollView: UIScrollView(),
            visibleItems: items,
            isFirstItemVisible: true,
            isLastItemVisible: false
        )
        
        XCTAssertEqual(info.mostVisibleItem?.identifier.anyValue, 2)
        XCTAssertEqual(info.mostVisibleItem?.percentageVisible, 1.0)
    }
    
    func test_isApproachingBottom_withLastItemThreshold()
    {
        let info = makeInfo(
            contentHeight: 1000.0,
            boundsHeight: 400.0,
            contentOffsetY: 200.0,
            isLastItemVisible: true
        )
        
        XCTAssertTrue(info.isApproachingBottom(within: .lastItem))
    }
    
    func test_isApproachingBottom_withOffsetThreshold()
    {
        let info = makeInfo(
            contentHeight: 1000.0,
            boundsHeight: 400.0,
            contentOffsetY: 540.0
        )
        
        XCTAssertTrue(info.isApproachingBottom(within: .offset(60.0)))
        XCTAssertFalse(info.isApproachingBottom(within: .offset(59.0)))
    }
    
    func test_isApproachingBottom_withScreensThreshold()
    {
        let info = makeInfo(
            contentHeight: 1000.0,
            boundsHeight: 400.0,
            contentOffsetY: 300.0,
            safeAreaInsets: UIEdgeInsets(top: 20.0, left: 0.0, bottom: 30.0, right: 0.0)
        )
        
        XCTAssertTrue(info.isApproachingBottom(within: .screens(1.0)))
        XCTAssertFalse(info.isApproachingBottom(within: .screens(0.35)))
    }
    
    func test_contentSize()
    {
        let info = makeInfo(
            contentHeight: 1000.0,
            boundsHeight: 400.0,
            contentOffsetY: 200.0
        )
        
        XCTAssertEqual(info.contentSize, CGSize(width: 100.0, height: 1000.0))
    }
    
    private func makeInfo(
        contentHeight: CGFloat,
        boundsHeight: CGFloat,
        contentOffsetY: CGFloat,
        safeAreaInsets: UIEdgeInsets = .zero,
        isLastItemVisible: Bool = false
    ) -> ListScrollPositionInfo {
        let scrollView = TestScrollView()
        scrollView.bounds = CGRect(origin: .zero, size: CGSize(width: 100.0, height: boundsHeight))
        scrollView.contentSize = CGSize(width: 100.0, height: contentHeight)
        scrollView.contentOffset = CGPoint(x: 0.0, y: contentOffsetY)
        scrollView.contentInset = .zero
        scrollView.verticalScrollIndicatorInsets = .zero
        scrollView.testSafeAreaInsets = safeAreaInsets
        
        return ListScrollPositionInfo(
            scrollView: scrollView,
            visibleItems: Set(),
            isFirstItemVisible: false,
            isLastItemVisible: isLastItemVisible
        )
    }
    
    fileprivate struct TestingType { }
}

final class UIEdgeInsetsTests : XCTestCase
{
    func test_masked()
    {
        let insets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 30.0, right: 40.0)
        
        XCTAssertEqual(insets.masked(by: []), UIEdgeInsets())
        XCTAssertEqual(insets.masked(by: [.top]), UIEdgeInsets(top: 10.0, left: 0.0, bottom: 0.0, right: 0.0))
        XCTAssertEqual(insets.masked(by: [.top, .left]), UIEdgeInsets(top: 10.0, left: 20.0, bottom: 0.0, right: 0.0))
        XCTAssertEqual(insets.masked(by: [.top, .left, .bottom]), UIEdgeInsets(top: 10.0, left: 20.0, bottom: 30.0, right: 0.0))
        XCTAssertEqual(insets.masked(by: [.top, .left, .bottom, .right]), UIEdgeInsets(top: 10.0, left: 20.0, bottom: 30.0, right: 40.0))
    }
}

private final class TestScrollView : UIScrollView
{
    var testSafeAreaInsets: UIEdgeInsets = .zero
    
    override var safeAreaInsets: UIEdgeInsets {
        testSafeAreaInsets
    }
}
