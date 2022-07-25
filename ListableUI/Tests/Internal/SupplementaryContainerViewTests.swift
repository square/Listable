//
//  SupplementaryContainerViewTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import XCTest

@testable import ListableUI

class SupplementaryContainerViewTests: XCTestCase {
    func newHeaderFooter() -> AnyPresentationHeaderFooterState {
        let headerFooter = HeaderFooter(TestHeaderFooterContent())
        return PresentationState.HeaderFooterState(headerFooter, performsContentCallbacks: true)
    }

    func test_init() {
        let view = SupplementaryContainerView(frame: CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100.0)))

        XCTAssertEqual(view.backgroundColor, .clear)
        XCTAssertEqual(view.layer.masksToBounds, false)
    }

    func test_sizeThatFits() {
        let cache = ReusableViewCache()
        let view = SupplementaryContainerView(frame: .zero)

        view.reuseCache = cache
        view.environment = .empty

        XCTAssertEqual(view.sizeThatFits(.zero), .zero)

        view.setHeaderFooter(newHeaderFooter(), animated: false)

        XCTAssertEqual(view.sizeThatFits(.zero), CGSize(width: 50, height: 40))
    }

    func test_systemLayoutSizeFitting() {
        let cache = ReusableViewCache()
        let view = SupplementaryContainerView(frame: .zero)

        view.reuseCache = cache
        view.environment = .empty

        XCTAssertEqual(view.sizeThatFits(.zero), .zero)

        view.setHeaderFooter(newHeaderFooter(), animated: false)

        XCTAssertEqual(view.systemLayoutSizeFitting(.zero), CGSize(width: 51, height: 41))
    }

    func test_systemLayoutSizeFitting_withHorizontalFittingPriority_verticalFittingPriority() {
        let cache = ReusableViewCache()
        let view = SupplementaryContainerView(frame: .zero)

        view.reuseCache = cache
        view.environment = .empty

        XCTAssertEqual(view.sizeThatFits(.zero), .zero)

        view.setHeaderFooter(newHeaderFooter(), animated: false)

        XCTAssertEqual(
            view.systemLayoutSizeFitting(
                .zero,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .defaultLow
            ),

            CGSize(width: 52, height: 42)
        )
    }

    func test_headerFooter() {
        let cache = ReusableViewCache()
        let view = SupplementaryContainerView(frame: .zero)

        view.reuseCache = cache
        view.environment = .empty

        XCTAssertEqual(view.content, nil)

        // Add a header

        let header = newHeaderFooter()

        view.setHeaderFooter(header, animated: false)
        view.sizeToFit()

        // Make sure the view is set

        XCTAssertNotNil(view.content)

        let content = view.content!

        XCTAssertTrue(type(of: content) === HeaderFooterContentView<TestHeaderFooterContent>.self)
        XCTAssertEqual(view.frame.size, CGSize(width: 50, height: 40))

        // Unset the header footer, make sure the view is pushed back into the cache.

        view.setHeaderFooter(nil, animated: false)

        XCTAssertNil(view.content)

        XCTAssertEqual(cache.count(for: ReuseIdentifier.identifier(for: TestHeaderFooterContent.self)), 1)

        // And now, let's set the header one more time to make sure it pulls from the cache.

        view.setHeaderFooter(newHeaderFooter(), animated: false)

        XCTAssertEqual(cache.count(for: ReuseIdentifier.identifier(for: TestHeaderFooterContent.self)), 0)
    }

    func test_prepareForReuse() {
        let cache = ReusableViewCache()
        let view = SupplementaryContainerView(frame: .zero)

        view.reuseCache = cache
        view.environment = .empty

        view.setHeaderFooter(newHeaderFooter(), animated: false)

        view.prepareForReuse()

        XCTAssertNil(view.headerFooter)
    }
}

private struct TestHeaderFooterContent: HeaderFooterContent, Equatable {
    // MARK: HeaderFooterContent

    func apply(
        to _: HeaderFooterContentViews<Self>,
        for _: ApplyReason,
        with _: ApplyHeaderFooterContentInfo
    ) {
        // Nothing.
    }

    typealias ContentView = View

    static func createReusableContentView(frame: CGRect) -> View {
        View(frame: frame)
    }

    final class View: UIView {
        override func sizeThatFits(_: CGSize) -> CGSize {
            CGSize(width: 50, height: 40)
        }

        override func systemLayoutSizeFitting(_: CGSize) -> CGSize {
            CGSize(width: 51, height: 41)
        }

        override func systemLayoutSizeFitting(
            _: CGSize,
            withHorizontalFittingPriority _: UILayoutPriority,
            verticalFittingPriority _: UILayoutPriority
        ) -> CGSize {
            CGSize(width: 52, height: 42)
        }
    }
}
