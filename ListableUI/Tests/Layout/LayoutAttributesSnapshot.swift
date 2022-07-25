//
//  LayoutAttributesSnapshot.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/11/20.
//

import Foundation
@testable import ListableUI
import Snapshot

struct LayoutAttributesSnapshot: SnapshotOutputFormat {
    typealias RenderingFormat = ListView

    static func snapshotData(with renderingFormat: ListView) throws -> Data {
        renderingFormat.collectionViewLayout.layout.content.layoutAttributes.stringRepresentation.data(using: .utf8)!
    }

    static var outputInfo: SnapshotOutputInfo {
        SnapshotOutputInfo(
            directoryName: "ListAttributes",
            fileExtension: "txt"
        )
    }

    static func validate(render: ListView, existingData: Data) throws {
        let new = try Self.snapshotData(with: render)

        if new != existingData {
            throw SnapshotValidationError.notMatching
        }
    }
}
