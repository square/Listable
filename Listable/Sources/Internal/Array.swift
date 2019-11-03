//
//  Array.swift
//  Listable
//
//  Created by Kyle Van Essen on 10/27/19.
//

import Foundation


extension Array
{
    func mapWithIndex<Mapped>(_ block : (Int, Element) -> Mapped) -> [Mapped]
    {
        var mapped = [Mapped]()
        mapped.reserveCapacity(self.count)
        
        for (index, element) in self.enumerated() {
            mapped.append(block(index, element))
        }
        
        return mapped
    }
    
    func flatMapWithIndex<Mapped>(_ block : (Int, Element) -> Mapped?) -> [Mapped]
    {
        var mapped = [Mapped]()
        mapped.reserveCapacity(self.count)
        
        for (index, element) in self.enumerated() {
            if let value = block(index, element) {
                mapped.append(value)
            }
        }
        
        return mapped
    }
}
