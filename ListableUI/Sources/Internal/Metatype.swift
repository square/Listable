//
//  Metatype.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 4/5/25.
//

import Foundation


/// A wrapper to make metatypes easier to work with, providing `Equatable`, `Hashable`, and `CustomStringConvertible`.
///
/// This is copied from Blueprint:
/// https://github.com/square/Blueprint/blob/main/BlueprintUI/Sources/Internal/Metatype.swift
///
struct Metatype: Hashable, CustomStringConvertible {
    
    var type: Any.Type

    init(_ type: Any.Type) {
        self.type = type
    }

    var description: String {
        "\(type)"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(type))
    }

    static func == (lhs: Metatype, rhs: Metatype) -> Bool {
        lhs.type == rhs.type
    }
}
