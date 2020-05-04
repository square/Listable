//
//  ListScrollPositionInfoTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 5/4/20.
//

import XCTest
import UIKit
@testable import Listable


final class UIRectEdgeTests : XCTestCase
{
    func test_visibleScrollViewContentEdges()
    {
        do {
            // No offset + no safe area should mean all edges are visible.
            
            let edges = UIRectEdge.visibleScrollViewContentEdges(
                bounds: CGRect(origin: .zero, size: CGSize(width: 200, height: 100)),
                contentSize: CGSize(width: 100.0, height: 50.0),
                safeAreaInsets: .zero
            )
            
            XCTAssertEqual(edges, UIRectEdge(edges: .all))
        }
        
        do {
            // No offset + safe area should mean the edges outside the safe area are not visible.
            
            let edges = UIRectEdge.visibleScrollViewContentEdges(
                bounds: CGRect(origin: .zero, size: CGSize(width: 200, height: 100)),
                contentSize: CGSize(width: 100.0, height: 50.0),
                safeAreaInsets: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 20.0, right: 10.0)
            )
            
            XCTAssertEqual(edges, UIRectEdge(edges: .bottom, .right))
        }

        do {
            // No offset + safe area should mean the edges outside the safe area are not visible.
            
            let edges = UIRectEdge.visibleScrollViewContentEdges(
                bounds: CGRect(origin: CGPoint(x: -100.0, y: -50.0), size: CGSize(width: 200, height: 100)),
                contentSize: CGSize(width: 100.0, height: 50.0),
                safeAreaInsets: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 20.0, right: 10.0)
            )
            
            XCTAssertEqual(edges, UIRectEdge(edges: .top, .left))
        }

    }
}

fileprivate extension UIRectEdge
{
    init(edges : UIRectEdge...)
    {
        self = UIRectEdge(rawValue: 0)
        
        for edge in edges {
            self.formUnion(edge)
        }
    }
}
