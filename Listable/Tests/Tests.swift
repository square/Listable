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
        let snapshotTest = SnapshotTest(config: SnapshotTest.Config(screens: SnapshotTest.Config.Screen.defaultScreens))
        
        try! snapshotTest.run { screen -> UIImage in
            let view = UIView(frame: .init(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
            view.backgroundColor = .red
            
            return view.toImage
        }
    }
}
