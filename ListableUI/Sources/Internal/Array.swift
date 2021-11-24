//
//  Array.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 10/27/19.
//

import Foundation


extension Array
{
    func forEachWithIndex(_ block : (Int, Bool, Element) -> ())
    {
        let count = self.count
        var index : Int = 0
        
        while index < count {
            let element = self[index]
            block(index, index == (count - 1), element)
            index += 1
        }
    }
    
    func mapWithIndex<Mapped>(_ block : (Int, Bool, Element) -> Mapped) -> [Mapped]
    {
        var mapped = [Mapped]()
        mapped.reserveCapacity(self.count)
        
        let count = self.count
        var index : Int = 0
        
        while index < count {
            let element = self[index]
            mapped.append(block(index, index == (count - 1), element))
            index += 1
        }
        
        return mapped
    }
    
    func compactMapWithIndex<Mapped>(_ block : (Int, Bool, Element) -> Mapped?) -> [Mapped]
    {
        var mapped = [Mapped]()
        mapped.reserveCapacity(self.count)
        
        let count = self.count
        var index : Int = 0
        
        while index < count {
            let element = self[index]
            
            if let value = block(index, index == (count - 1), element) {
                mapped.append(value)
            }
            
            index += 1
        }
        
        return mapped
    }
    
    mutating func popFirst() -> Element? {
        if self.isEmpty { return nil }
        
        return self.removeFirst()
    }
    
    mutating func mutateEach(_ edit : (inout Element) -> ()) {
        self = self.map { original in
            var copy = original
            edit(&copy)
            return copy
        }
    }
}

