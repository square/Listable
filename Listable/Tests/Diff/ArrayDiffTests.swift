//
//  ArrayDiffTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import XCTest
import EnglishDictionary

@testable import Listable


class ArrayDiffTests: XCTestCase
{
    func transformed<Element>(with old : [Element], diff : ArrayDiff<Element>) -> [Element]
    {
        return diff.transform(
            old: old,
            removed: { _, _ in },
            added: { $0 },
            moved: { old, new, value in value = new },
            updated: { old, new, value in value = new },
            noChange: { old, new, value in value = new }
        )
    }
    
    func test_insert_and_remove()
    {
        self.perform("Empty to filled") {
            let old = [String]()
            let new = ["a", "b", "c", "d"]
            
            let diff = ArrayDiff(old: old, new: new, identifierProvider: { AnyHashable($0) }, movedHint: { _, _ in false }, updated: { _, _ in false })
            
            XCTAssertEqual(new, self.transformed(with: old, diff: diff))
            
            XCTAssertEqual(diff.changeCount, 4)
            
            XCTAssertEqual(diff.added, [
                ArrayDiff.Added(newIndex: 0, new: "a"),
                ArrayDiff.Added(newIndex: 1, new: "b"),
                ArrayDiff.Added(newIndex: 2, new: "c"),
                ArrayDiff.Added(newIndex: 3, new: "d"),
            ])
            
            XCTAssertEqual(diff.removed, [])
            XCTAssertEqual(diff.moved, [])
            XCTAssertEqual(diff.updated, [])
            XCTAssertEqual(diff.noChange, [])
        }
        
        self.perform("Filled to to empty") {
            let old = ["a", "b", "c", "d"]
            let new = [String]()
            
            let diff = ArrayDiff(old: old, new: new, identifierProvider: { AnyHashable($0) }, movedHint: { _, _ in false }, updated: { _, _ in false })
            
            XCTAssertEqual(new, self.transformed(with: old, diff: diff))
            
            XCTAssertEqual(diff.changeCount, 4)
            
            XCTAssertEqual(diff.added, [])
            
            XCTAssertEqual(diff.removed, [
                ArrayDiff.Removed(oldIndex: 3, old: "d"),
                ArrayDiff.Removed(oldIndex: 2, old: "c"),
                ArrayDiff.Removed(oldIndex: 1, old: "b"),
                ArrayDiff.Removed(oldIndex: 0, old: "a"),
            ])
            
            XCTAssertEqual(diff.moved, [])
            XCTAssertEqual(diff.updated, [])
            XCTAssertEqual(diff.noChange, [])
        }
        
        self.perform("Add more items") {
            let old = ["a", "b", "c", "d"]
            let new = ["a", "a2", "b", "c", "c2", "d", "d2"]
            
            let diff = ArrayDiff(old: old, new: new, identifierProvider: { AnyHashable($0) }, movedHint: { _, _ in false }, updated: { _, _ in false })
            
            XCTAssertEqual(new, self.transformed(with: old, diff: diff))
            
            XCTAssertEqual(diff.changeCount, 3)
            
            XCTAssertEqual(diff.added, [
                ArrayDiff.Added(newIndex: 1, new: "a2"),
                ArrayDiff.Added(newIndex: 4, new: "c2"),
                ArrayDiff.Added(newIndex: 6, new: "d2"),
            ])
            
            XCTAssertEqual(diff.removed, [])
            XCTAssertEqual(diff.moved, [])
            XCTAssertEqual(diff.updated, [])
            
            XCTAssertEqual(diff.noChange, [
                ArrayDiff.NoChange(oldIndex: 3, newIndex: 5, old: "d", new: "d"),
                ArrayDiff.NoChange(oldIndex: 2, newIndex: 3, old: "c", new: "c"),
                ArrayDiff.NoChange(oldIndex: 1, newIndex: 2, old: "b", new: "b"),
                ArrayDiff.NoChange(oldIndex: 0, newIndex: 0, old: "a", new: "a")
            ])
        }
        
        self.perform("Remove items") {
            let old = ["a", "a2", "b", "c", "c2", "d", "d2"]
            let new = ["a", "b", "c", "d"]
            
            let diff = ArrayDiff(old: old, new: new, identifierProvider: { AnyHashable($0) }, movedHint: { _, _ in false }, updated: { _, _ in false })
            
            XCTAssertEqual(new, self.transformed(with: old, diff: diff))
            
            XCTAssertEqual(diff.changeCount, 3)
            
            XCTAssertEqual(diff.added, [])
            
            XCTAssertEqual(diff.removed, [
                ArrayDiff.Removed(oldIndex: 6, old: "d2"),
                ArrayDiff.Removed(oldIndex: 4, old: "c2"),
                ArrayDiff.Removed(oldIndex: 1, old: "a2"),
            ])
            
            XCTAssertEqual(diff.moved, [])
            XCTAssertEqual(diff.updated, [])
            
            XCTAssertEqual(diff.noChange, [
                ArrayDiff.NoChange(oldIndex: 5, newIndex: 3, old: "d", new: "d"),
                ArrayDiff.NoChange(oldIndex: 3, newIndex: 2, old: "c", new: "c"),
                ArrayDiff.NoChange(oldIndex: 2, newIndex: 1, old: "b", new: "b"),
                ArrayDiff.NoChange(oldIndex: 0, newIndex: 0, old: "a", new: "a")
            ])
        }
        
        self.perform("Add and remove items") {
            let old = ["a", "b", "c", "d"]
            let new = ["a", "a2", "c", "c2", "d2"]
            
            let diff = ArrayDiff(old: old, new: new, identifierProvider: { AnyHashable($0) }, movedHint: { _, _ in false }, updated: { _, _ in false })
            
            XCTAssertEqual(new, self.transformed(with: old, diff: diff))
            
            XCTAssertEqual(diff.changeCount, 5)
            
            XCTAssertEqual(diff.added, [
                ArrayDiff.Added(newIndex: 1, new: "a2"),
                ArrayDiff.Added(newIndex: 3, new: "c2"),
                ArrayDiff.Added(newIndex: 4, new: "d2"),
            ])
            
            XCTAssertEqual(diff.removed, [
                ArrayDiff.Removed(oldIndex: 3, old: "d"),
                ArrayDiff.Removed(oldIndex: 1, old: "b"),
            ])
            
            XCTAssertEqual(diff.moved, [])
            XCTAssertEqual(diff.updated, [])
            
            XCTAssertEqual(diff.noChange, [
                ArrayDiff.NoChange(oldIndex: 2, newIndex: 2, old: "c", new: "c"),
                ArrayDiff.NoChange(oldIndex: 0, newIndex: 0, old: "a", new: "a"),
            ])
        }
    }
    
    func test_move_and_update()
    {
        self.perform("Move items") {
            let old = ["a", "b", "c", "d"]
            let new = ["b", "c", "d", "a"]
            
            let diff = ArrayDiff(old: old, new: new, identifierProvider: { AnyHashable($0) }, movedHint: { _, _ in false }, updated: { _, _ in false })
            
            XCTAssertEqual(new, self.transformed(with: old, diff: diff))
            
            XCTAssertEqual(diff.changeCount, 1)
            
            XCTAssertEqual(diff.added, [])
            XCTAssertEqual(diff.removed, [])
            
            XCTAssertEqual(diff.moved, [
                ArrayDiff.Moved(
                    old: ArrayDiff.Removed(oldIndex: 0, old: "a"),
                    new: ArrayDiff.Added(newIndex: 3, new: "a")
                )
            ])
            
            XCTAssertEqual(diff.updated, [])
            
            XCTAssertEqual(diff.noChange, [
                ArrayDiff.NoChange(oldIndex: 3, newIndex: 2, old: "d", new: "d"),
                ArrayDiff.NoChange(oldIndex: 2, newIndex: 1, old: "c", new: "c"),
                ArrayDiff.NoChange(oldIndex: 1, newIndex: 0, old: "b", new: "b")
            ])
        }
        
        self.perform("Update items") {
            let old = ["a", "b", "c", "d"]
            let new = ["A", "b", "c", "d"]
            
            let diff = ArrayDiff(old: old, new: new, identifierProvider: { AnyHashable($0.lowercased()) }, movedHint: { _, _ in false }, updated: { $0 != $1 })
            
            XCTAssertEqual(new, self.transformed(with: old, diff: diff))
            
            XCTAssertEqual(diff.changeCount, 1)
            
            XCTAssertEqual(diff.added, [])
            XCTAssertEqual(diff.removed, [])
            
            XCTAssertEqual(diff.moved, [])
            
            XCTAssertEqual(diff.updated, [
                ArrayDiff.Updated(oldIndex: 0, newIndex: 0, old: "a", new: "A")
            ])
            
            XCTAssertEqual(diff.noChange, [
                ArrayDiff.NoChange(oldIndex: 3, newIndex: 3, old: "d", new: "d"),
                ArrayDiff.NoChange(oldIndex: 2, newIndex: 2, old: "c", new: "c"),
                ArrayDiff.NoChange(oldIndex: 1, newIndex: 1, old: "b", new: "b")
            ])
        }
        
        self.perform("Update and moved items") {
            let old = ["a", "b", "c", "d"]
            let new = ["A", "c", "d", "B"]
            
            let diff = ArrayDiff(old: old, new: new, identifierProvider: { AnyHashable($0.lowercased()) }, movedHint: { _, _ in false }, updated: { $0 != $1 })
            
            XCTAssertEqual(new, self.transformed(with: old, diff: diff))
            
            XCTAssertEqual(diff.changeCount, 2)
            
            XCTAssertEqual(diff.added, [])
            XCTAssertEqual(diff.removed, [])
            
            XCTAssertEqual(diff.moved, [
                ArrayDiff.Moved(
                    old: ArrayDiff.Removed(oldIndex: 1, old: "b"),
                    new: ArrayDiff.Added(newIndex: 3, new: "B")
                )
            ])
            
            XCTAssertEqual(diff.updated, [
                ArrayDiff.Updated(oldIndex: 0, newIndex: 0, old: "a", new: "A")
            ])
            
            XCTAssertEqual(diff.noChange, [
                ArrayDiff.NoChange(oldIndex: 3, newIndex: 2, old: "d", new: "d"),
                ArrayDiff.NoChange(oldIndex: 2, newIndex: 1, old: "c", new: "c"),
            ])
        }
    }
    
    func test_insert_and_remove_duplicate_items()
    {
        self.perform("Insert duplicate items") {
            let old = ["a", "b", "c", "d"]
            let new = ["a", "a", "b", "b", "c", "c", "d", "d"]
            
            let diff = ArrayDiff(old: old, new: new, identifierProvider: { AnyHashable($0) }, movedHint: { _, _ in false }, updated: { _, _ in false })
            
            XCTAssertEqual(new, self.transformed(with: old, diff: diff))
            
            XCTAssertEqual(diff.changeCount, 4)
            
            XCTAssertEqual(diff.added, [
                ArrayDiff.Added(newIndex: 1, new: "a"),
                ArrayDiff.Added(newIndex: 3, new: "b"),
                ArrayDiff.Added(newIndex: 5, new: "c"),
                ArrayDiff.Added(newIndex: 7, new: "d"),
            ])
            
            XCTAssertEqual(diff.removed, [])
            XCTAssertEqual(diff.moved, [])
            XCTAssertEqual(diff.updated, [])
            
            XCTAssertEqual(diff.noChange, [
                ArrayDiff.NoChange(oldIndex: 3, newIndex: 6, old: "d", new: "d"),
                ArrayDiff.NoChange(oldIndex: 2, newIndex: 4, old: "c", new: "c"),
                ArrayDiff.NoChange(oldIndex: 1, newIndex: 2, old: "b", new: "b"),
                ArrayDiff.NoChange(oldIndex: 0, newIndex: 0, old: "a", new: "a"),
            ])
        }
        
        self.perform("Remove duplicate items") {
            let old = ["a", "a", "b", "b", "c", "c", "d", "d"]
            let new = ["a", "b", "c", "d"]
            
            let diff = ArrayDiff(old: old, new: new, identifierProvider: { AnyHashable($0) }, movedHint: { _, _ in false }, updated: { _, _ in false })
            
            XCTAssertEqual(new, self.transformed(with: old, diff: diff))
            
            XCTAssertEqual(diff.changeCount, 4)
            
            XCTAssertEqual(diff.added, [])
            
            XCTAssertEqual(diff.removed, [
                ArrayDiff.Removed(oldIndex: 7, old: "d"),
                ArrayDiff.Removed(oldIndex: 5, old: "c"),
                ArrayDiff.Removed(oldIndex: 3, old: "b"),
                ArrayDiff.Removed(oldIndex: 1, old: "a"),
            ])
            
            XCTAssertEqual(diff.moved, [])
            XCTAssertEqual(diff.updated, [])
            
            XCTAssertEqual(diff.noChange, [
                ArrayDiff.NoChange(oldIndex: 6, newIndex: 3, old: "d", new: "d"),
                ArrayDiff.NoChange(oldIndex: 4, newIndex: 2, old: "c", new: "c"),
                ArrayDiff.NoChange(oldIndex: 2, newIndex: 1, old: "b", new: "b"),
                ArrayDiff.NoChange(oldIndex: 0, newIndex: 0, old: "a", new: "a"),
            ])
        }
    }
    
    func test_transform_with_random_mutations()
    {
        let iterations : Int = 1000
        
        var rng = StableRNG()
        
        self.perform("Removing elements") {
            
            for _ in 1...iterations {
                let old = numbers
                var new = numbers
                
                new.removeRandom(using: &rng)
                new.removeRandom(using: &rng)
                new.removeRandom(using: &rng)
                new.removeRandom(using: &rng)
                new.removeRandom(using: &rng)
                
                let diff = ArrayDiff(old: old, new: new, identifierProvider: { AnyHashable($0) }, movedHint: { _, _ in false }, updated: { _, _ in false })
                
                XCTAssertEqual(new, self.transformed(with: old, diff: diff))
            }
        }
        
        self.perform("Inserting elements") {

            for _ in 1...iterations {
                let old = numbers
                var new = numbers
                
                new.insert(atRandom: "A", using: &rng)
                new.insert(atRandom: "B", using: &rng)
                new.insert(atRandom: "C", using: &rng)
                new.insert(atRandom: "D", using: &rng)
                new.insert(atRandom: "E", using: &rng)
                
                let diff = ArrayDiff(old: old, new: new, identifierProvider: { AnyHashable($0) }, movedHint: { _, _ in false }, updated: { _, _ in false })
                
                XCTAssertEqual(new, self.transformed(with: old, diff: diff))
            }
        }
        
        self.perform("Shuffling elements") {
            
            for _ in 1...iterations {
                let old = numbers
                let new = numbers.shuffled(using: &rng)
                
                let diff = ArrayDiff(old: old, new: new, identifierProvider: { AnyHashable($0) }, movedHint: { _, _ in false }, updated: { _, _ in false })
                
                XCTAssertEqual(new, self.transformed(with: old, diff: diff))
            }
        }
        
        self.perform("Shuffling, Removing, and Inserting elements") {
            
            for _ in 1...iterations {
                let old = numbers
                var new = numbers
                
                new.removeRandom(using: &rng)
                new.removeRandom(using: &rng)
                new.removeRandom(using: &rng)
                new.removeRandom(using: &rng)
                new.removeRandom(using: &rng)
                
                new.insert(atRandom: "A", using: &rng)
                new.insert(atRandom: "B", using: &rng)
                new.insert(atRandom: "C", using: &rng)
                new.insert(atRandom: "D", using: &rng)
                new.insert(atRandom: "E", using: &rng)
                
                new.shuffle(using: &rng)
                
                let diff = ArrayDiff(old: old, new: new, identifierProvider: { AnyHashable($0) }, movedHint: { _, _ in false }, updated: { _, _ in false })
                
                XCTAssertEqual(new, self.transformed(with: old, diff: diff))
            }
        }
    }
    
    func disabled_test_performance_curves()
    {
        let dictionary = EnglishDictionary.dictionary
        
        let test = PerformanceCurveTest<[EnglishDictionary.Word]>(
            cases: 15.mapEach { index in
                let count = (index + 1 ) * 100
                return .init(count: count, data: Array(dictionary.allWords[0...count]))
            },
            expectedCurve: { Double($0) },
            caseRunCount: 5,
            test: { words in
                var rng = StableRNG()
                
                var new = words
                new.shuffle(using: &rng)
                
                _ = ArrayDiff(old: words, new: new, identifierProvider: { AnyHashable($0.word) }, movedHint: { _, _ in false }, updated: { _, _ in false })
        })
        
        test.run()
    }
}

fileprivate extension Array
{
    @discardableResult
    mutating func removeRandom<RNG:RandomNumberGenerator>(using rng : inout RNG) -> Element
    {
        return self.remove(at: Int.random(in: 0..<self.count, using: &rng))
    }
    
    mutating func insert<RNG:RandomNumberGenerator>(atRandom element: Element, using rng : inout RNG)
    {
        self.insert(element, at: Int.random(in: 0..<self.count, using: &rng))
    }
}


fileprivate extension Int
{
    func mapEach<Mapped>(_ block : (Int) -> Mapped) -> [Mapped]
    {
        var mapped = [Mapped]()
        
        for index in 0..<self {
            mapped.append(block(index))
        }
        
        return mapped
    }
}


private let numbers : [String] = [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",

    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16",
    "17",
    "18",
    "19",

    "20",
    "21",
    "22",
    "23",
    "24",
    "25",
    "26",
    "27",
    "28",
    "29",

    "30",
    "31",
    "32",
    "33",
    "34",
    "35",
    "36",
    "37",
    "38",
    "39",

    "40",
    "41",
    "42",
    "43",
    "44",
    "45",
    "46",
    "47",
    "48",
    "49",
    "50"
]

