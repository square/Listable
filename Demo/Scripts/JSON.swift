//
//  JSON.swift
//  Scripts
//
//  Created by Kyle Van Essen on 12/28/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import Foundation


protocol FromJSONStringDecodable : Decodable
{
    static func from(json jsonString : String) throws -> Self
}

extension FromJSONStringDecodable
{
    static func from(json jsonString : String) throws -> Self
    {
        return try JSONDecoder().decode(Self.self, from: jsonString.data(using: .utf8)!)
    }
}
