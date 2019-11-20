//
//  Tests.swift
//  Listable
//
//  Created by Kyle Van Essen on 6/17/19.
//

import XCTest


class Tests : XCTestCase
{
    func test_empty()
    {
        
    }
    
    func test_snapshots()
    {
        let test = SnapshotTest<UIImage>(config: .init(screens: SnapshotTest.Config.Screen.defaultScreens))
        
        try! test.run { (screen) -> UIImage in
            let view = UIView(frame: CGRect(origin: .zero, size: .init(width: 100.0, height: 100.0)))
            view.backgroundColor = .blue
            
            return view.toImage
        }
    }
}
