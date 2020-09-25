//
//  ItemPreviewViewTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 6/14/20.
//

import UIKit
import Snapshot
import XCTest
@testable import ListableUI


class ItemPreviewViewTests : XCTestCase
{
    func test_init()
    {
        let view = ItemPreviewView()
        
        XCTAssertEqual(view.contentHuggingPriority(for: .vertical), .defaultHigh)
        XCTAssertEqual(view.contentHuggingPriority(for: .horizontal), .defaultHigh)
    }
    
    func test_set()
    {
        let view = ItemPreviewView()
                
        view.update(
            with: 300.0,
            state: .init(isSelected: false, isHighlighted: false),
            item: Item(TestContent(height: 50.0))
        )
        
        XCTAssertEqual(view.frame, CGRect(x: 0.0, y: 0.0, width: 300.0, height: 90.0))
        Snapshot(for: [ViewIteration(name: "false,false")]) { _ in view }.test(output: ViewImageSnapshot.self)
        
        view.update(
            with: 300.0,
            state: .init(isSelected: false, isHighlighted: true),
            item: Item(TestContent(height: 50.0))
        )
        
        XCTAssertEqual(view.frame, CGRect(x: 0.0, y: 0.0, width: 300.0, height: 90.0))
        Snapshot(for: [ViewIteration(name: "false,true")]) { _ in view }.test(output: ViewImageSnapshot.self)
        
        view.update(
            with: 300.0,
            state: .init(isSelected: true, isHighlighted: false),
            item: Item(TestContent(height: 50.0))
        )
        
        XCTAssertEqual(view.frame, CGRect(x: 0.0, y: 0.0, width: 300.0, height: 90.0))
        Snapshot(for: [ViewIteration(name: "true,false")]) { _ in view }.test(output: ViewImageSnapshot.self)
        
        view.update(
            with: 300.0,
            state: .init(isSelected: true, isHighlighted: true),
            item: Item(TestContent(height: 50.0))
        )
        
        XCTAssertEqual(view.frame, CGRect(x: 0.0, y: 0.0, width: 300.0, height: 90.0))
        Snapshot(for: [ViewIteration(name: "true,true")]) { _ in view }.test(output: ViewImageSnapshot.self)
    }
}


fileprivate struct TestContent : ItemContent, Equatable
{
    var height : CGFloat
    
    var identifier: Identifier<TestContent> {
        .init(self.height)
    }
    
    func apply(to views: ItemContentViews<TestContent>, for reason: ApplyReason, with info: ApplyItemContentInfo) {
        views.content.height = self.height
        
        views.content.backgroundColor = .init(white: 1.0, alpha: 0.5)
        
        views.background.backgroundColor = .red
        views.selectedBackground.backgroundColor = info.state.isHighlighted ? .green : .blue
    }
    
    static func createReusableContentView(frame: CGRect) -> View {
        View(frame: frame)
    }
    
    typealias BackgroundView = UIView
    
    static func createReusableBackgroundView(frame: CGRect) -> BackgroundView {
        UIView(frame: frame)
    }
    
    final class View : UIView
    {
        var height : CGFloat = 0.0
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = .red
        }
        
        required init?(coder: NSCoder) { fatalError() }
        
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            CGSize(width: size.width, height: self.height)
        }
    }
}
