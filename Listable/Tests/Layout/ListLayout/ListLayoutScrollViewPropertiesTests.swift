//
//  ListLayoutScrollViewPropertiesTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 7/16/20.
//

import UIKit
import XCTest
@testable import Listable


class ListLayoutScrollViewPropertiesTests : XCTestCase
{
    func test_apply()
    {
        self.testcase("isPagingEnabled") {
     
            let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            scrollView.isPagingEnabled = false
            
            let properties1 = ListLayoutScrollViewProperties(
                isPagingEnabled: true,
                contentInsetAdjustmentBehavior: .automatic,
                allowsBounceVertical: false,
                allowsBounceHorizontal: false,
                allowsVerticalScrollIndicator: false,
                allowsHorizontalScrollIndicator: false
            )
            
            var behavior1 = Behavior()
            behavior1.isPagingEnabled = false
            
            properties1.apply(to: scrollView, behavior: behavior1, direction: .vertical, showsScrollIndicators: true)
            
            XCTAssertEqual(scrollView.isPagingEnabled, true)
            scrollView.isPagingEnabled = false
            
            let properties2 = ListLayoutScrollViewProperties(
                isPagingEnabled: false,
                contentInsetAdjustmentBehavior: .automatic,
                allowsBounceVertical: false,
                allowsBounceHorizontal: false,
                allowsVerticalScrollIndicator: false,
                allowsHorizontalScrollIndicator: false
            )
            
            var behavior2 = Behavior()
            behavior2.isPagingEnabled = true
            
            properties2.apply(to: scrollView, behavior: behavior2, direction: .vertical, showsScrollIndicators: true)
            
            XCTAssertEqual(scrollView.isPagingEnabled, true)
            
            let properties3 = ListLayoutScrollViewProperties(
                isPagingEnabled: false,
                contentInsetAdjustmentBehavior: .automatic,
                allowsBounceVertical: false,
                allowsBounceHorizontal: false,
                allowsVerticalScrollIndicator: false,
                allowsHorizontalScrollIndicator: false
            )
            
            var behavior3 = Behavior()
            behavior3.isPagingEnabled = false
            
            properties3.apply(to: scrollView, behavior: behavior3, direction: .vertical, showsScrollIndicators: true)
            
            XCTAssertEqual(scrollView.isPagingEnabled, false)
        }
        
        if #available(iOS 11.0, *) {
            self.testcase("contentInsetAdjustmentBehavior") {
                let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                scrollView.contentInsetAdjustmentBehavior = .never
                
                let properties = ListLayoutScrollViewProperties(
                    isPagingEnabled: false,
                    contentInsetAdjustmentBehavior: .automatic,
                    allowsBounceVertical: false,
                    allowsBounceHorizontal: false,
                    allowsVerticalScrollIndicator: false,
                    allowsHorizontalScrollIndicator: false
                )
                
                properties.apply(to: scrollView, behavior: Behavior(), direction: .vertical, showsScrollIndicators: true)
                
                XCTAssertEqual(scrollView.contentInsetAdjustmentBehavior, .automatic)
            }
        }
        
        self.testcase("alwaysBounceVertical & alwaysBounceHorizontal") {
            
            let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            scrollView.alwaysBounceVertical = false
            scrollView.alwaysBounceHorizontal = false
            
            var properties = ListLayoutScrollViewProperties(
                isPagingEnabled: false,
                contentInsetAdjustmentBehavior: .automatic,
                allowsBounceVertical: true,
                allowsBounceHorizontal: true,
                allowsVerticalScrollIndicator: false,
                allowsHorizontalScrollIndicator: false
            )
            
            // Enabled
            
            var behavior = Behavior()
            behavior.underflow.alwaysBounce = true
            
            properties.apply(to: scrollView, behavior: behavior, direction: .vertical, showsScrollIndicators: true)
            
            XCTAssertEqual(scrollView.alwaysBounceVertical, true)
            XCTAssertEqual(scrollView.alwaysBounceHorizontal, false)
            
            scrollView.alwaysBounceVertical = false
            scrollView.alwaysBounceHorizontal = false
            
            properties.apply(to: scrollView, behavior: behavior, direction: .horizontal, showsScrollIndicators: true)
            
            XCTAssertEqual(scrollView.alwaysBounceVertical, false)
            XCTAssertEqual(scrollView.alwaysBounceHorizontal, true)
            
            scrollView.alwaysBounceVertical = true
            scrollView.alwaysBounceHorizontal = true
            
            // Disabled
            
            properties.allowsBounceVertical = false
            properties.allowsBounceHorizontal = false
            
            properties.apply(to: scrollView, behavior: behavior, direction: .vertical, showsScrollIndicators: true)
            
            XCTAssertEqual(scrollView.alwaysBounceVertical, false)
            XCTAssertEqual(scrollView.alwaysBounceHorizontal, false)
            
            scrollView.alwaysBounceVertical = true
            scrollView.alwaysBounceHorizontal = true
            
            properties.apply(to: scrollView, behavior: behavior, direction: .horizontal, showsScrollIndicators: true)
            
            XCTAssertEqual(scrollView.alwaysBounceVertical, false)
            XCTAssertEqual(scrollView.alwaysBounceHorizontal, false)
            
            scrollView.alwaysBounceVertical = true
            scrollView.alwaysBounceHorizontal = true
        }

        self.testcase("showsVerticalScrollIndicator & showsHorizontalScrollIndicator") {
            
            let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            
            let properties = ListLayoutScrollViewProperties(
                isPagingEnabled: false,
                contentInsetAdjustmentBehavior: .automatic,
                allowsBounceVertical: true,
                allowsBounceHorizontal: true,
                allowsVerticalScrollIndicator: true,
                allowsHorizontalScrollIndicator: true
            )
            
            properties.apply(to: scrollView, behavior: Behavior(), direction: .vertical, showsScrollIndicators: true)
            
            XCTAssertEqual(scrollView.showsVerticalScrollIndicator, true)
            XCTAssertEqual(scrollView.showsVerticalScrollIndicator, true)
            
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            
            properties.apply(to: scrollView, behavior: Behavior(), direction: .horizontal, showsScrollIndicators: true)
            
            XCTAssertEqual(scrollView.showsVerticalScrollIndicator, true)
            XCTAssertEqual(scrollView.showsVerticalScrollIndicator, true)
            
            scrollView.showsHorizontalScrollIndicator = true
            scrollView.showsVerticalScrollIndicator = true

            properties.apply(to: scrollView, behavior: Behavior(), direction: .horizontal, showsScrollIndicators: false)
            
            XCTAssertEqual(scrollView.showsVerticalScrollIndicator, false)
            XCTAssertEqual(scrollView.showsVerticalScrollIndicator, false)
        }
    }
}
