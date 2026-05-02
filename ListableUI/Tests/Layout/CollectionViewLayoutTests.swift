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
        weak var weakDelegate : CollectionViewLayoutDelegateMock?

        let layout : CollectionViewLayout = {
            let delegate = CollectionViewLayoutDelegateMock()
            weakDelegate = delegate

            return CollectionViewLayout(
                delegate: delegate,
                layoutDescription: .table(),
                appearance: Appearance(),
                behavior: Behavior()
            )
        }()

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
