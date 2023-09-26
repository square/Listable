//
//  ListTests.swift
//  BlueprintUILists-Unit-Tests
//
//  Created by Kyle Van Essen on 10/26/20.
//

@testable import ListableUI

import XCTest
import BlueprintUI
import BlueprintUICommonControls


@testable import BlueprintUILists


class ListTests : XCTestCase {
    
    func test_environment_passthrough() {
        let view = BlueprintView(frame: CGRect(x: 0, y: 0, width: 200, height: 400))
        
        var callCount : Int = 0
        
        let callback = {
            callCount += 1
        }
        
        let onEnvRead = { (env:Environment) in
            XCTAssertTrue(env[TestingKey.self])
        }
        
        view.element = List { list in
            
            list.header = TestHeaderContent(wasCalled: callback, onEnvRead: onEnvRead)
            list.footer = TestHeaderContent(wasCalled: callback, onEnvRead: onEnvRead)
            
            list("section") { section in
                
                section.header = TestHeaderContent(wasCalled: callback, onEnvRead: onEnvRead)
                section.footer = TestHeaderContent(wasCalled: callback, onEnvRead: onEnvRead)
                
                section += TestItemContent(wasCalled: callback, onEnvRead: onEnvRead)
                section += TestItemContent(wasCalled: callback, onEnvRead: onEnvRead)
            }
        }.adaptedEnvironment { env in
            env[TestingKey.self] = true
        }
        
        // Should have no calls yet – we haven't laid out the view.
        XCTAssertEqual(callCount, 0)
        
        view.layoutIfNeeded()
        
        // Expecting one call for every header, footer, and item's content, background, and pressed background.
        XCTAssertEqual(callCount, 36)
    }
    
    func test_size() {
        let constraint = SizeConstraint(width: .atMost(1234), height: .atMost(1235))
        
        XCTAssertEqual(
            List.ListContent.size(
                with: .init(
                    contentSize: CGSize(width: 1200, height: 1000),
                    naturalWidth: 900,
                    layoutDirection: .vertical
                ),
                in: constraint,
                layoutMode: .default,
                horizontalFill: .fillParent,
                verticalFill: .fillParent
            ),
            CGSize(width: 1234, height: 1235)
        )
        
        XCTAssertEqual(
            List.ListContent.size(
                with: .init(
                    contentSize: CGSize(width: 1200, height: 1000),
                    naturalWidth: 900,
                    layoutDirection: .vertical
                ),
                in: constraint,
                layoutMode: .default,
                horizontalFill: .natural,
                verticalFill: .fillParent
            ),
            CGSize(width: 900, height: 1235)
        )
        
        XCTAssertEqual(
            List.ListContent.size(
                with: .init(
                    contentSize: CGSize(width: 1200, height: 1000),
                    naturalWidth: nil,
                    layoutDirection: .vertical
                ),
                in: constraint,
                layoutMode: .default,
                horizontalFill: .natural,
                verticalFill: .fillParent
            ),
            CGSize(width: 1200, height: 1235)
        )
        
        XCTAssertEqual(
            List.ListContent.size(
                with: .init(
                    contentSize: CGSize(width: 1200, height: 1000),
                    naturalWidth: 900,
                    layoutDirection: .vertical
                ),
                in: constraint,
                layoutMode: .default,
                horizontalFill: .natural,
                verticalFill: .natural
            ),
            CGSize(width: 900, height: 1000)
        )
    }
    
    func test_listContentContext() {
        let view = BlueprintView(frame: CGRect(x: 0, y: 0, width: 200, height: 400))
        
        func configure(list: inout ListProperties) {
            list.header = TestHeaderContent()
            list.footer = TestHeaderContent()
            
            list("section") { section in
                
                section.header = TestHeaderContent()
                section.footer = TestHeaderContent()
                
                section += TestItemContent()
                section += TestItemContent()
            }
        }
        
        view.element = List { list in
            configure(list: &list)
        }.adaptedEnvironment(keyPath: \.listContentContext, value: .init(false))
        
        view.layoutIfNeeded()
        
        let listView = view.findListView()!
        
        var didResetSizesCount = 0
        
        listView.storage.presentationState.onResetCachedSizes = {
            didResetSizesCount += 1
        }
        
        // Do it twice, should only be called once since the value is the same.

        for _ in 1...2 {
            view.element = List { list in
                configure(list: &list)
            }.adaptedEnvironment(keyPath: \.listContentContext, value: .init(true))
        }
        
        view.layoutIfNeeded()
        
        XCTAssertEqual(didResetSizesCount, 1)
    }
}


fileprivate struct TestHeaderContent : BlueprintHeaderFooterContent {
    
    var wasCalled : () -> () = {}
    
    var onEnvRead : (Environment) -> () = { _ in }
    
    var elementRepresentation: Element {
        self.wasCalled()
        
        return EnvironmentReader { env in
            onEnvRead(env)
            return Box(backgroundColor: .red).constrainedTo(height: .absolute(60))
        }
    }
    
    var background: Element? {
        self.wasCalled()
        
        return EnvironmentReader { env in
            onEnvRead(env)
            return Empty()
        }
    }
    
    var pressedBackground: Element? {
        self.wasCalled()
        
        return EnvironmentReader { env in
            onEnvRead(env)
            return Empty()
        }
    }
    
    func isEquivalent(to other: TestHeaderContent) -> Bool {
        true
    }
}


fileprivate struct TestItemContent : BlueprintItemContent {
        
    var wasCalled : () -> () = {}
    
    var onEnvRead : (Environment) -> () = { _ in }
    
    var identifierValue: String {
        ""
    }
    
    func element(with info: ApplyItemContentInfo) -> Element {
        self.wasCalled()
        
        return EnvironmentReader { env in
            onEnvRead(env)
            return Box(backgroundColor: .blue).constrainedTo(height: .absolute(40))
        }
    }
    
    func backgroundElement(with info: ApplyItemContentInfo) -> Element? {
        self.wasCalled()
        
        return EnvironmentReader { env in
            onEnvRead(env)
            return Empty()
        }
    }
    
    func selectedBackgroundElement(with info: ApplyItemContentInfo) -> Element? {
        self.wasCalled()
        
        return EnvironmentReader { env in
            onEnvRead(env)
            return Empty()
        }
    }
    
    func isEquivalent(to other: TestItemContent) -> Bool {
        true
    }
}


fileprivate struct TestingKey : EnvironmentKey {
    static var defaultValue: Bool {
        false
    }
}


fileprivate extension UIView {
    
    func findListView() -> ListView? {
        if let list = self as? ListView {
            return list
        }
        
        for subview in subviews {
            return subview.findListView()
        }
        
        return nil
    }
}
