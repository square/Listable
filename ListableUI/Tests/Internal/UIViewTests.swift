//
//  UIView+AdditionsTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 12/10/20.
//

@testable import ListableUI
import XCTest

class UIViewTests: XCTestCase {
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

private final class View1: UIView {}

private final class View2: UIView {}

private final class View3: UIView {}

private final class View4: UIView {}
