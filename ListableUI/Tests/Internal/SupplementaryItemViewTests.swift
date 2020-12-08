//
//  SupplementaryContainerViewTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import XCTest

@testable import ListableUI


class SupplementaryContainerViewTests: XCTestCase
{
    func newHeaderFooter() -> AnyPresentationHeaderFooterState
    {
        let headerFooter = HeaderFooter(TestHeaderFooterContent())
        return PresentationState.HeaderFooterState(headerFooter, performsContentCallbacks: true)
    }
    
    func test_init()
    {
        let view = SupplementaryContainerView(frame: CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100.0)))
        
        XCTAssertEqual(view.backgroundColor, .clear)
        XCTAssertEqual(view.layer.masksToBounds, false)
    }
    
    func test_sizeThatFits()
    {
        let cache = ReusableViewCache()
        let view = SupplementaryContainerView(frame: CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100.0)))
        
        view.reuseCache = cache
        view.environment = .empty
        
        XCTAssertEqual(view.sizeThatFits(.zero), .zero)
        
        view.headerFooter = self.newHeaderFooter()
        
        XCTAssertEqual(view.sizeThatFits(.zero), CGSize(width: 100, height: 100))
    }
    
    func test_headerFooter()
    {
        let cache = ReusableViewCache()
        let view = SupplementaryContainerView(frame: .zero)
        
        view.reuseCache = cache
        view.environment = .empty
        
        XCTAssertEqual(view.content, nil)
        
        // Add a header
        
        view.headerFooter = self.newHeaderFooter()
        view.sizeToFit()
        
        // Make sure the view is set
        
        XCTAssertNotNil(view.content)
        
        let content = view.content!
        
        XCTAssertTrue(type(of: content) === HeaderFooterContentView<TestHeaderFooterContent>.self)
        XCTAssertEqual(view.frame.size, CGSize(width: 100, height: 100))
        
        // Unset the header footer, make sure the view is pushed back into the cache.
        
        view.headerFooter = nil
        
        XCTAssertNil(view.content)
        
        XCTAssertEqual(cache.count(for: ReuseIdentifier.identifier(for: TestHeaderFooterContent.self)), 1)
        
        // And now, let's set the header one more time to make sure it pulls from the cache.
        
        view.headerFooter = self.newHeaderFooter()
        
        XCTAssertEqual(cache.count(for: ReuseIdentifier.identifier(for: TestHeaderFooterContent.self)), 0)
    }
    
    func test_prepareForReuse()
    {
        let cache = ReusableViewCache()
        let view = SupplementaryContainerView(frame: .zero)
        
        view.reuseCache = cache
        view.environment = .empty
        
        view.headerFooter = self.newHeaderFooter()
        
        view.prepareForReuse()
        
        XCTAssertNil(view.headerFooter)
    }
}

fileprivate struct TestHeaderFooterContent : HeaderFooterContent, Equatable
{
    // MARK: HeaderFooterContent
    
    func apply(
        to views: HeaderFooterContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyHeaderFooterContentInfo
    ) {
        // Nothing.
    }
        
    typealias ContentView = View
    
    static func createReusableContentView(frame: CGRect) -> View
    {
        return View(frame: frame)
    }
    
    final class View : UIView
    {
        override func sizeThatFits(_ size: CGSize) -> CGSize
        {
            return CGSize(width: 100, height: 100)
        }
    }
}
