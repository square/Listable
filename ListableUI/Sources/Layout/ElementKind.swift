//
//  ElementKind.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 7/24/25.
//

import Foundation


enum ElementKind : Equatable, Hashable, Codable {
    
    private static let prefix = "Listable"
    
    case supplementary(SupplementaryKind)
    case decoration(DecorationKind)
    
    init?(_ string: String) throws {
        
        guard let next = string.stripPrefix(Self.prefix) else {
            return nil
        }
        
        self = try JSONDecoder()
            .decode(
                Self.self,
                from: next.data(using: .utf8)!
            )
    }
    
    static let encoder : JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()
    
    var stringValue: String {
        Self.prefix + String(
            data: try! Self.encoder.encode(self),
            encoding: .utf8
        )!
    }
}

fileprivate extension String {
    
    func stripPrefix(_ prefix: String) -> String? {
        
        guard count > prefix.count else {
            return nil
        }
        
        guard hasPrefix(prefix) else {
            return nil
        }
        
        return String(self.suffix(count - prefix.count))
    }
}
