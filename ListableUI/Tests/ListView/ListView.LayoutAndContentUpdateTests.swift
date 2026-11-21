//
//  ListView.LayoutAndContentUpdateTests.swift
//  ListableUI-Unit-Tests
//

import XCTest

@testable import ListableUI


/// When one `configure(with:)` call changes both the layout and the content, the rebuild for the
/// new layout must not measure the old items and keep those sizes for the new content.
final class ListView_LayoutAndContentUpdateTests : XCTestCase
{
    func test_new_layout_and_new_context_measures_the_new_content()
    {
        let view = ListView(frame: CGRect(x: 0, y: 0, width: 300, height: 600))

        view.configure { list in
            list.layout = .table { $0.stickySectionHeaders = false }
            list.content.context = ContentContext("default")
            list("section") { section in
                section += Item(MeasuredContent(height: 50), sizing: .thatFits(.noConstraint))
            }
        }
        view.collectionView.layoutIfNeeded()

        XCTAssertEqual(view.heightOfFirstItem(), 50)

        view.configure { list in
            list.layout = .table { $0.stickySectionHeaders = true }
            list.content.context = ContentContext("large")
            list("section") { section in
                section += Item(MeasuredContent(height: 100), sizing: .thatFits(.noConstraint))
            }
        }
        view.collectionView.layoutIfNeeded()

        XCTAssertEqual(view.heightOfFirstItem(), 100)
    }

    func test_same_layout_and_new_context_measures_the_new_content()
    {
        let view = ListView(frame: CGRect(x: 0, y: 0, width: 300, height: 600))

        view.configure { list in
            list.layout = .table { $0.stickySectionHeaders = false }
            list.content.context = ContentContext("default")
            list("section") { section in
                section += Item(MeasuredContent(height: 50), sizing: .thatFits(.noConstraint))
            }
        }
        view.collectionView.layoutIfNeeded()

        view.configure { list in
            list.layout = .table { $0.stickySectionHeaders = false }
            list.content.context = ContentContext("large")
            list("section") { section in
                section += Item(MeasuredContent(height: 100), sizing: .thatFits(.noConstraint))
            }
        }
        view.collectionView.layoutIfNeeded()

        XCTAssertEqual(view.heightOfFirstItem(), 100)
    }
}


fileprivate extension ListView
{
    func heightOfFirstItem() -> CGFloat?
    {
        self.collectionViewLayout.layout.content.sections.first?.items.first?.size.height
    }
}


/// Stands in for content whose size depends on something outside the item, such as the text size,
/// which the list learns about through the content context instead of through equivalence.
fileprivate struct MeasuredContent : ItemContent
{
    var height : CGFloat

    var identifierValue : String {
        "measured"
    }

    func isEquivalent(to other : MeasuredContent) -> Bool {
        true
    }

    func apply(to views : ItemContentViews<Self>, for reason : ApplyReason, with info : ApplyItemContentInfo)
    {
        views.content.height = self.height
    }

    static func createReusableContentView(frame : CGRect) -> ContentView {
        ContentView(frame: frame)
    }

    final class ContentView : UIView
    {
        var height : CGFloat = 0

        override func sizeThatFits(_ size : CGSize) -> CGSize {
            CGSize(width: size.width, height: self.height)
        }
    }
}
