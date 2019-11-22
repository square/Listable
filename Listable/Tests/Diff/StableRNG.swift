//
//  StableRNG.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/25/19.
//

import Foundation


struct StableRNG : RandomNumberGenerator
{
    private static let numbers : [UInt64] = {
        let main = Bundle(for: ArrayDiffTests.self)
        let bundle = Bundle(url: main.url(forResource: "ListableTestsResources", withExtension: "bundle")!)!
        
        let url = bundle.url(forResource: "random_numbers", withExtension: "json")!
                
        let decoder = JSONDecoder()
        
        return try! decoder.decode(Array<UInt64>.self, from: Data(contentsOf: url))
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
