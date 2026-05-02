//
//  CollectionViewLayoutTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Alex Odawa on 5/2/26.
//

import XCTest
@testable import ListableUI


final class CollectionViewLayoutTests : XCTestCase
{
    func test_prepare_whenDelegateHasBeenDeallocated()
    {
        var delegate : CollectionViewLayoutDelegateMock? = CollectionViewLayoutDelegateMock()
        weak var weakDelegate = delegate

        let layout = CollectionViewLayout(
            delegate: delegate!,
            layoutDescription: .table(),
            appearance: Appearance(),
            behavior: Behavior()
        )

        delegate = nil

        XCTAssertNil(weakDelegate)
        XCTAssertNil(layout.delegate)

        layout.prepare()
    }
}


private final class CollectionViewLayoutDelegateMock : CollectionViewLayoutDelegate
{
    func listViewLayoutUpdatedItemPositions() {}

    func listLayoutContent(
        defaults: ListLayoutDefaults
    ) -> ListLayoutContent {
        ListLayoutContent()
    }

    func listViewLayoutCurrentEnvironment() -> ListEnvironment {
        .empty
    }

    func listViewLayoutDidLayoutContents() {}

    func listViewShouldEndQueueingEditsForReorder() {}
}
