//
//  Array.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 10/27/19.
//

import Foundation

extension Array {
    func forEachWithIndex(_ block: (Int, Bool, Element) -> Void) {
        let count = count
        var index = 0

        while index < count {
            let element = self[index]
            block(index, index == (count - 1), element)
            index += 1
        }
    }

    func mapWithIndex<Mapped>(_ block: (Int, Bool, Element) -> Mapped) -> [Mapped] {
        var mapped = [Mapped]()
        mapped.reserveCapacity(self.count)

        let count = count
        var index = 0

        while index < count {
            let element = self[index]
            mapped.append(block(index, index == (count - 1), element))
            index += 1
        }

        return mapped
    }

    func compactMapWithIndex<Mapped>(_ block: (Int, Bool, Element) -> Mapped?) -> [Mapped] {
        var mapped = [Mapped]()
        mapped.reserveCapacity(self.count)

        let count = count
        var index = 0

        while index < count {
            let element = self[index]

            if let value = block(index, index == (count - 1), element) {
                mapped.append(value)
            }

            index += 1
        }

        return mapped
    }

    /// Pops all of the items passing the given `predicate` from the beginning of the array.
    /// If there are no passing elements at the beginning, or the array is empty, an empty array is returned.
    mutating func popPassing(_ predicate: (Element) -> Bool) -> [Element] {
        for index in indices {
            if predicate(self[index]) == false {
                let popped = self[0 ..< index]
                removeSubrange(0 ..< index)

                return Array(popped)
            }
        }

        let all = self
        removeAll()

        return all
    }
}
