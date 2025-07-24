//
//  StableRNG.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/25/19.
//

import Foundation

internal extension Bundle {
    static let resources = Bundle.module
}

struct StableRNG : RandomNumberGenerator
{
    private static let numbers : [UInt64] = {
        let bundle = Bundle.resources
        
        let url = bundle.url(forResource: "random_numbers", withExtension: "json")!
                
        let decoder = JSONDecoder()
        
        let strings = try! decoder.decode(Array<String>.self, from: Data(contentsOf: url))
        
        return strings.map {
            UInt64($0)!
        }
    }()
    
    var index : Int = 0
    
    // MARK: RandomNumberGenerator
    
    mutating func next() -> UInt64
    {
        let result = StableRNG.numbers[self.index]
        let lastIndex = StableRNG.numbers.count - 1
                     
        if self.index >= lastIndex {
            self.index = 0
        } else {
            self.index += 1
        }
        
        return result
    }
}
