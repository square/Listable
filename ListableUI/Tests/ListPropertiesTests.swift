//
//  ListPropertiesTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

import ListableUI
import XCTest

class ListPropertiesTests : XCTestCase
{
    private func properties() -> ListProperties {
        ListProperties(
            animatesChanges: true,
            layout: .flow(),
            appearance: .init(),
            scrollIndicatorInsets: .zero,
            behavior: .init(),
            autoScrollAction: .none,
            onKeyboardFrameWillChange: nil,
            accessibilityIdentifier: "",
            debuggingIdentifier: "") { _ in }
    }
    
    func test_read_only_dynamic_member_lookup() {
        let properties = properties()
        // Ensure that this compiles. Previously we were missing the read-only KeyPath
        // dynamicMember subscript implementation which would lead to this error:
        // Cannot assign to property: 'lastItem' is a get-only property
        let item = properties.lastItem
        XCTAssertNil(item)
    }
    
    func test_writeable_dynamic_member_lookup() {
        var properties = properties()
        // Ensure that this compiles and writes through to the underlying content.
        properties.identifier = "Hello"
        XCTAssertEqual(properties.identifier, "Hello")
        XCTAssertEqual(properties.identifier, properties.content.identifier)
    }
}
