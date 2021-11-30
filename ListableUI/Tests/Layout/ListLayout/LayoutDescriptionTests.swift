//
//  LayoutDescriptionTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 6/17/20.
//

import XCTest
@testable import ListableUI


final class LayoutDescriptionTests : XCTestCase
{
    func test_createPopulatedLayout()
    {
        let listView = ListView()
        
        var describeCallCount : Int = 0
        
        let description = TestLayout.describe {
            describeCallCount += 1
            $0.anotherValue = "Hello"
        }
        
        let populated = description.configuration.createPopulatedLayout(
            appearance: listView.appearance,
            behavior: listView.behavior,
            content: {
                listView.delegate.listLayoutContent(defaults: $0)
            }
        )
        
        XCTAssertEqual(describeCallCount, 1)
        XCTAssertEqual((populated as! TestLayout).layoutAppearance.anotherValue, "Hello")
    }
    
    func test_shouldRebuild()
    {
        let layout = TestLayout(
            layoutAppearance: TestLayoutAppearance(anotherValue: "Hello 1"),
            appearance: Appearance(),
            behavior: Behavior(),
            content: .init()
        )
        
        let description1 = TestLayout.describe {
            $0.anotherValue = "Hello 1"
        }
        
        let description2 = TestLayout.describe {
            $0.anotherValue = "Hello 2"
        }
        
        XCTAssertEqual(description1.configuration.shouldRebuild(layout: layout), false)
        XCTAssertEqual(description2.configuration.shouldRebuild(layout: layout), true)
    }
    
    func test_layoutAppearanceProperties()
    {
        let description = TestLayout.describe {
            $0.direction = .horizontal
            
            $0.stickySectionHeaders = false
        }
        
        XCTAssertEqual(
            description.layoutAppearanceProperties,
            
            ListLayoutAppearanceProperties(
                direction: .horizontal,
                bounds: nil,
                stickySectionHeaders: false,
                pagingBehavior: .none,
                scrollViewProperties: .init(
                    isPagingEnabled: false,
                    contentInsetAdjustmentBehavior: .automatic,
                    allowsBounceVertical: true,
                    allowsBounceHorizontal: true,
                    allowsVerticalScrollIndicator: true,
                    allowsHorizontalScrollIndicator: true
                )
            )
        )
    }
    
    func test_isSameLayoutType()
    {
        let description1 = TableListLayout.describe()
        let description2 = PagedListLayout.describe()
        
        XCTAssertEqual(description1.configuration.isSameLayoutType(as: description1.configuration), true)
        XCTAssertEqual(description1.configuration.isSameLayoutType(as: description2.configuration), false)
    }
}


private struct TestLayoutAppearance : ListLayoutAppearance
{
    static var `default`: TestLayoutAppearance {
        self.init(anotherValue: "")
    }
    
    var direction: LayoutDirection = .vertical
    
    var stickySectionHeaders: Bool = true
    
    var pagingBehavior: ListPagingBehavior = .none
    
    var scrollViewProperties: ListLayoutScrollViewProperties = .init(
        isPagingEnabled: false,
        contentInsetAdjustmentBehavior: .automatic,
        allowsBounceVertical: true,
        allowsBounceHorizontal: true,
        allowsVerticalScrollIndicator: true,
        allowsHorizontalScrollIndicator: true
    )
    
    var bounds: ListContentBounds? {
        nil
    }
    
    var anotherValue : String
}

private final class TestLayout : ListLayout
{
    typealias LayoutAppearance = TestLayoutAppearance
    
    static var defaults: ListLayoutDefaults {
        .init(itemInsertAndRemoveAnimations: .fade)
    }
    
    var layoutAppearance: TestLayoutAppearance
        
    var appearance: Appearance
    
    var behavior: Behavior
    
    var content: ListLayoutContent

    init(
        layoutAppearance: TestLayoutAppearance,
        appearance: Appearance,
        behavior: Behavior,
        content: ListLayoutContent
    ) {
        self.layoutAppearance = layoutAppearance
        
        self.appearance = appearance
        self.behavior = behavior
        
        self.content = content
    }
    
    func updateLayout(in context : ListLayoutLayoutContext) { }
    
    func layout(delegate: CollectionViewLayoutDelegate?, in context: ListLayoutLayoutContext) {}
}
