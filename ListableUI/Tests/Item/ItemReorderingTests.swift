//
//  ItemReorderingTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 6/10/21.
//

@testable import ListableUI
import XCTest


class ItemReordering_ResultTests : XCTestCase {
    
    func test_allowed() {
        let section1 = Section("1") { section in
            section += TestItem()
            section += TestItem()
        }
        
        let section2 = Section("2") { section in
            section += TestItem()
            section += TestItem()
        }
        
        let result = ItemReordering.Result(
            from: IndexPath(item: 0, section: 0),
            fromSection: section1,
            to: IndexPath(item: 0, section: 1),
            toSection: section2
        )

        XCTAssertTrue(result.allowed(with: nil))
        XCTAssertTrue(result.allowed(with: { _ in true }))
        XCTAssertFalse(result.allowed(with: { _ in false }))
        XCTAssertFalse(result.allowed(with: { _ in throw TestError.testError }))
    }
    
    fileprivate enum TestError : Error {
        case testError
    }
}

class ItemReordering_SectionsTests : XCTestCase {
    
    func test_canMove() {
        
        let section1 = PresentationState.SectionState(
            Section("1") { section in
                section += TestItem()
                section += TestItem()
            }
        )
        
        let section2 = PresentationState.SectionState(
            Section("2") { section in
                section += TestItem()
                section += TestItem()
            }
        )
        
        self.testcase("all") {
            
            XCTAssertTrue(
                ItemReordering.Sections.all.canMove(
                    from: section1,
                    to: section1
                )
            )
            
            XCTAssertTrue(
                ItemReordering.Sections.all.canMove(
                    from: section1,
                    to: section2
                )
            )
        }
        
        self.testcase("current") {
            
            XCTAssertTrue(
                ItemReordering.Sections.current.canMove(
                    from: section1,
                    to: section1
                )
            )
            
            XCTAssertFalse(
                ItemReordering.Sections.current.canMove(
                    from: section1,
                    to: section2
                )
            )
        }
        
        let section3 = PresentationState.SectionState(
            Section("3") { section in
                section += TestItem()
                section += TestItem()
            }
        )
        
        self.testcase("specific") {
            
            self.testcase("allow current") {
                
                let section = ItemReordering.Sections.specific(current: true, IDs: [section3.model.identifier.value])
                
                XCTAssertTrue(
                    section.canMove(
                        from: section1,
                        to: section1
                    )
                )
                
                XCTAssertFalse(
                    section.canMove(
                        from: section1,
                        to: section2
                    )
                )
                
                XCTAssertTrue(
                    section.canMove(
                        from: section1,
                        to: section3
                    )
                )
            }
            
            self.testcase("don't allow current") {
                
                let section = ItemReordering.Sections.specific(current: false, IDs: [section3.model.identifier.value])
                
                XCTAssertFalse(
                    section.canMove(
                        from: section1,
                        to: section1
                    )
                )
                
                XCTAssertFalse(
                    section.canMove(
                        from: section1,
                        to: section2
                    )
                )
                
                XCTAssertTrue(
                    section.canMove(
                        from: section1,
                        to: section3
                    )
                )
            }
        }
    }
}


fileprivate struct TestItem : ItemContent, Equatable {
    
    var identifierValue: String {
        ""
    }
    
    typealias ContentView = UIView
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
    
    func apply(to views: ItemContentViews<TestItem>, for reason: ApplyReason, with info: ApplyItemContentInfo) {}
}
