//
//  LayoutAttributesSnapshot.swift
//  Listable
//
//  Created by Kyle Van Essen on 6/11/20.
//

import Foundation
import Snapshot
@testable import Listable


struct LayoutAttributesSnapshot : SnapshotOutputFormat
{
    typealias RenderingFormat = ListView
    
    static func snapshotData(with renderingFormat: ListView) throws -> Data {
        renderingFormat.layout.layout.content.layoutAttributes.stringRepresentation.data(using: .utf8)!
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
