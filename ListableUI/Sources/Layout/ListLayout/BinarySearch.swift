//
//  BinarySearch.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 3/2/21.
//

import Foundation


enum BinarySearch {
    
    enum Comparison : Equatable {
        
        case less
        case equal
        case greater
        
        static func compare(
            frame : CGRect,
            in parent : CGRect,
            direction : LayoutDirection
        ) -> Self
        {
            switch direction {
            case .vertical:
                if frame.maxY < parent.origin.y {
                    return .less
                } else if frame.minY > parent.maxY {
                    return .greater
                } else {
                    return .equal
                }
                
            case .horizontal:
                fatalError("TODO")
            }
        }
    }
}


extension Array {
    
    /// Implements a binary search to find the first object in an array
    /// that passes the given test, and then enumerates forwards until
    /// the `forEach` closure returns false.
    func forEachAfter(
        first isFirst : (Element) -> BinarySearch.Comparison,
        forEach : (Int, Element) -> Bool
    ) {
        guard let start = self.firstIndexPassing(isFirst) else {
            return
        }
        
        for (index, item) in self[start..<self.endIndex].enumerated() {
            if forEach(index + start, item) == false { // TODO: I think the index here is wrong? Did the fix fix it?
                break
            }
        }
    }
    
    func firstIndexPassing(
        _ isFirst : (Element) -> BinarySearch.Comparison
    ) -> Int?
    {
        guard let startGuess = self.binarySearch(for: isFirst, in: 0..<self.count) else {
            return nil
        }
        
        let slice = self[0...startGuess]
        
        for (index, element) in slice.reversed().enumerated() {
            let comparison = isFirst(element)
            
            if comparison == .less {
                return startGuess - index + 1
            }
        }
        
        return 0
    }
    
    func binarySearch(
        for find : (Element) -> BinarySearch.Comparison,
        in range : Range<Int>
    ) -> Int?
    {
        guard self.isEmpty == false else {
            return nil
        }
        
        var lower = 0
        var upper = self.count
        
        while lower < upper {
            let index = lower + (upper - lower) / 2
            
            let result = find(self[index])
            
            switch result {
            case .less:
                lower = index + 1
            case .equal:
                return index
            case .greater:
                upper = index
            }
        }
        
        return nil
    }
}
