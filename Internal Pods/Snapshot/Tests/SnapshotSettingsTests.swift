//
//  SnapshotSettingsTests.swift
//  Snapshot-Unit-Tests
//
//  Created by Kyle Van Essen on 6/14/20.
//

import XCTest

@testable import Snapshot


class SnapshotSettingsTests : XCTestCase
{
    func test_init()
    {
        let settings = SnapshotSettings()
        
        XCTAssertEqual(settings.savesBySystemVersion, .disabled)
    }
}

class SnapshotSettings_SavesBySystemVersionTests : XCTestCase
{
    func test_systemVersionDirectory()
    {
        let version = OperatingSystemVersion(majorVersion: 1, minorVersion: 2, patchVersion: 3)
        
        XCTAssertEqual("All", SnapshotSettings.SavesBySystemVersion.disabled.systemVersionDirectory(for: version))
        XCTAssertEqual("1", SnapshotSettings.SavesBySystemVersion.major.systemVersionDirectory(for: version))
        XCTAssertEqual("1.2", SnapshotSettings.SavesBySystemVersion.majorMinor.systemVersionDirectory(for: version))
        XCTAssertEqual("1.2.3", SnapshotSettings.SavesBySystemVersion.complete.systemVersionDirectory(for: version))
    }
}
