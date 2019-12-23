//
//  ListIntegrationTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 12/23/19.
//

import XCTest
import Snapshot

@testable import Listable


class ListIntegrationTests : XCTestCase
{
    func test_empty()
    {
        self.testEach { view in
            
            
            self.snapshot(view)
        }
    }
    
    func test_underflow()
    {
        self.testEach { view in
            
            
            self.snapshot(view)
        }
    }
    
    func test_overflow()
    {
        self.testEach { view in
            
            
            self.snapshot(view)
        }
    }
    
    func test_overscroll()
    {
        self.testEach { view in
            
            
            self.snapshot(view)
        }
    }
    
    private func testEach(_ test : (ListView) -> ())
    {
        let views : [ListView] = [
            ListView(frame: .zero, appearance: self.plainAppearance),
            ListView(frame: .zero, appearance: self.groupedAppearance),
        ]
        
        for view in views {
            test(view)
        }
    }
    
    private var plainAppearance : Appearance
    {
        var appearance = Appearance()
        
        appearance.set { _ in
            
        }
        
        return appearance
    }
    
    private var groupedAppearance : Appearance
    {
        var appearance = Appearance()
        
        appearance.set { _ in
            
        }
        
        return appearance
    }
    
    private func snapshot(_ view : UIView)
    {
        let snapshot = Snapshot(
            with: SizedViewIteration(size: CGSize(width: 300, height: 600)),
            test: { _ in return view }
        )
        
        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: ViewHierarchySnapshot.self)
    }
}
