//
//  SupplementaryItemViewTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import XCTest

@testable import Listable


class SupplementaryItemViewTests: XCTestCase
{
    func test_init()
    {
        let view = SupplementaryItemView<TestHeaderFooterElement>(frame: CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100.0)))
        
        XCTAssertEqual(view.backgroundColor, .clear)
        XCTAssertEqual(view.layer.masksToBounds, false)
        
        XCTAssertEqual(view.content.superview, view)
    }
    
    func test_sizeThatFits()
    {
        // The default implementation of size that fits on UIView returns the existing size of the view.
        // Make sure that value is returned from the cell.
        
        let view1 = SupplementaryItemView<TestHeaderFooterElement>(frame: CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100.0)))
        XCTAssertEqual(view1.sizeThatFits(.zero), CGSize(width: 100.0, height: 100.0))
        
        let view2 = SupplementaryItemView<TestHeaderFooterElement>(frame: CGRect(origin: .zero, size: CGSize(width: 150.0, height: 150.0)))
        XCTAssertEqual(view2.sizeThatFits(.zero), CGSize(width: 150.0, height: 150.0))
    }
}

fileprivate struct TestHeaderFooterElement : HeaderFooterElement, Equatable
{
    // MARK: HeaderFooterElement
    
    func apply(to view: UIView, reason: ApplyReason) {}
        
    struct Appearance : HeaderFooterElementAppearance, Equatable
    {
        typealias ContentView = UIView
        
        static func createReusableHeaderFooterView(frame: CGRect) -> UIView
        {
            return UIView(frame: frame)
        }
        
        func apply(to view: UIView) {}
    }
}
