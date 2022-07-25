//
//  SnapshotSettings.swift
//  Snapshot
//
//  Created by Kyle Van Essen on 6/14/20.
//

import Foundation

public struct SnapshotSettings: Equatable {
    public var savesBySystemVersion: SavesBySystemVersion

    public init(
        savesBySystemVersion: SavesBySystemVersion = .disabled
    ) {
        self.savesBySystemVersion = savesBySystemVersion
    }

    public enum SavesBySystemVersion: Equatable {
        case disabled
        case major
        case majorMinor
        case complete

        func systemVersionDirectory(for version: OperatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersion) -> String
        {
            switch self {
            case .disabled: return "All"
            case .major: return String(version.majorVersion)
            case .majorMinor: return String(version.majorVersion) + "." + String(version.minorVersion)
            case .complete: return String(version.majorVersion) + "." + String(version.minorVersion) + "." + String(version.patchVersion)
            }
        }
    }
}
