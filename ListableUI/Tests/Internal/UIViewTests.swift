//
//  UIView+AdditionsTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 12/10/20.
//

import XCTest
@testable import ListableUI


class UIViewTests : XCTestCase {
    
    func test_firstSuperview() {
        
        let view1 = View1()
        let view2 = View2()
        let view3 = View3()
        
        view1.addSubview(view2)
        view2.addSubview(view3)
        
        XCTAssertEqual(view3.firstSuperview(ofType: UIView.self), view2)
        XCTAssertEqual(view3.firstSuperview(ofType: View3.self), nil)
        
        XCTAssertEqual(view3.firstSuperview(ofType: View2.self), view2)
        XCTAssertEqual(view3.firstSuperview(ofType: View1.self), view1)
        
        XCTAssertEqual(view3.firstSuperview(ofType: View4.self), nil)
    }
}


fileprivate final class View1 : UIView {}

fileprivate final class View2 : UIView {}

fileprivate final class View3 : UIView {}

fileprivate final class View4 : UIView {}
