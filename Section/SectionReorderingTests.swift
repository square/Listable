//
//  SectionReorderingTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 6/12/21.
//

@testable import ListableUI
import XCTest


class SectionReorderingTests : XCTestCase {
    
    func test_canReorderIn() {
        
        self.testcase("max item count") {
            let state = PresentationState { content in
                content += Section("1") { section in
                    section.reordering = .init(maxItemCount: 1)
                    
                    section += TestItem()
                }
                
                content += Section("2") { section in
                    section.reordering = .init(maxItemCount: 2)
                    section += TestItem()
                }
            }
            
            XCTAssertFalse(state.sections[0].model.reordering.canReorderIn(
                with: .init(
                    from: IndexPath(item: 0, section: 1),
                    fromSection: state.sections[1].model,
                    to: IndexPath(item: 1, section: 0),
                    toSection: state.sections[0].model
                )
            ))
            
            XCTAssertTrue(state.sections[1].model.reordering.canReorderIn(
                with: .init(
                    from: IndexPath(item: 1, section: 0),
                    fromSection: state.sections[0].model,
                    to: IndexPath(item: 0, section: 1),
                    toSection: state.sections[1].model
                )
            ))
        }
        
        self.testcase("can reorder in") {
            let state = PresentationState { content in
                content += Section("1") { section in
                    section.reordering = .init(canReorderIn: { _ in
                        false
                    })
                    
                    section += TestItem()
                }
                
                content += Section("2") { section in
                    section += TestItem()
                }
            }
            
            XCTAssertFalse(state.sections[0].model.reordering.canReorderIn(
                with: .init(
                    from: IndexPath(item: 0, section: 1),
                    fromSection: state.sections[1].model,
                    to: IndexPath(item: 1, section: 0),
                    toSection: state.sections[0].model
                )
            ))
        }
    }
    
    func test_canReorderOut() {
        
        self.testcase("min item count") {
            let state = PresentationState { content in
                content += Section("1") { section in
                    section.reordering = .init(minItemCount: 1)
                    
                    section += TestItem()
                }
                
                content += Section("2") { section in
                    section.reordering = .init(minItemCount: 0)
                    section += TestItem()
                }
            }
            
            XCTAssertFalse(state.sections[0].model.reordering.canReorderOut(
                with: .init(
                    from: IndexPath(item: 0, section: 1),
                    fromSection: state.sections[1].model,
                    to: IndexPath(item: 1, section: 0),
                    toSection: state.sections[0].model
                )
            ))
            
            XCTAssertTrue(state.sections[1].model.reordering.canReorderOut(
                with: .init(
                    from: IndexPath(item: 1, section: 0),
                    fromSection: state.sections[0].model,
                    to: IndexPath(item: 0, section: 1),
                    toSection: state.sections[1].model
                )
            ))
        }
        
        self.testcase("can reorder out") {
            let state = PresentationState { content in
                content += Section("1") { section in
                    section += TestItem()
                }
                
                content += Section("2") { section in
                    section.reordering = .init(canReorderOut: { _ in
                        false
                    })
                    
                    section += TestItem()
                }
            }
            
            XCTAssertFalse(state.sections[0].model.reordering.canReorderOut(
                with: .init(
                    from: IndexPath(item: 0, section: 1),
                    fromSection: state.sections[1].model,
                    to: IndexPath(item: 1, section: 0),
                    toSection: state.sections[0].model
                )
            ))
        }
    }
}


fileprivate struct TestItem : ItemContent, Equatable {
    
    var identifier: String {
        ""
    }
    
    typealias ContentView = UIView
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
    
    func apply(to views: ItemContentViews<TestItem>, for reason: ApplyReason, with info: ApplyItemContentInfo) {}
}
