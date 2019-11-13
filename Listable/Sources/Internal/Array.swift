//
//  Array.swift
//  Listable
//
//  Created by Kyle Van Essen on 10/27/19.
//

import Foundation


extension Array
{
    func forEachWithIndex(_ block : (Int, Bool, Element) -> ())
    {
        let count = self.count
        
        for (index, element) in self.enumerated() {
            block(index, index == (count - 1), element)
        }
    }
    
    func mapWithIndex<Mapped>(_ block : (Int, Bool, Element) -> Mapped) -> [Mapped]
    {
        var mapped = [Mapped]()
        mapped.reserveCapacity(self.count)
        
        let count = self.count
        
        for (index, element) in self.enumerated() {
            mapped.append(block(index, index == (count - 1), element))
        }
        
        return mapped
    }
    
    func flatMapWithIndex<Mapped>(_ block : (Int, Bool, Element) -> Mapped?) -> [Mapped]
    {
        var mapped = [Mapped]()
        mapped.reserveCapacity(self.count)
        
        let count = self.count
        
        for (index, element) in self.enumerated() {
            if let value = block(index, index == (count - 1), element) {
                mapped.append(value)
            }
        }
        
        return mapped
    }
}
