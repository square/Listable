//
//  DiffPerformanceTesting.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 6/30/20.
//

import EnglishDictionary
@testable import ListableUI
import XCTest

class DiffPerformanceTesting: XCTestCase {
    override func invokeTest() {
        // Uncomment to be able to run perf testing.
        // super.invokeTest()
    }

    func test_no_diff_array() {
        let dictionary = EnglishDictionary.dictionary

        Thread.sleep(forTimeInterval: 0.5)

        determineAverage(for: 10.0) {
            _ = ArrayDiff(
                old: dictionary.allWords,
                new: dictionary.allWords,
                identifierProvider: { word in word.word },
                movedHint: { lhs, rhs in lhs != rhs },
                updated: { lhs, rhs in lhs != rhs }
            )
        }
    }

    func test_no_diff_sectioned() {
        let dictionary = EnglishDictionary.dictionary

        Thread.sleep(forTimeInterval: 0.5)

        determineAverage(for: 10.0) {
            _ = SectionedDiff(
                old: dictionary.wordsByLetter,
                new: dictionary.wordsByLetter,
                configuration: .init(
                    section: .init(
                        identifier: { $0.letter },
                        items: { $0.words },
                        movedHint: { $0.letter != $1.letter }
                    ),
                    item: .init(
                        identifier: { $0.word },
                        updated: { $0.word != $1.word },
                        movedHint: { $0.word != $1.word }
                    )
                )
            )
        }
    }

    static let numbers: [String] = (1 ... 1000).map {
        String($0)
    }

    func test_shuffling() {
        var rng = StableRNG()

        determineAverage(for: 10.0) {
            let old = Self.numbers
            var new = Self.numbers

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

            let diff = ArrayDiff(old: old, new: new, identifierProvider: { $0 }, movedHint: { _, _ in false }, updated: { _, _ in false })

            XCTAssertEqual(new, self.transformed(with: old, diff: diff))
        }
    }

    func transformed<Element, Identifier: Hashable>(with old: [Element], diff: ArrayDiff<Element, Identifier>) -> [Element]
    {
        diff.transform(
            old: old,
            removed: { _, _ in },
            added: { $0 },
            moved: { _, new, value in value = new },
            updated: { _, new, value in value = new },
            noChange: { _, new, value in value = new }
        )
    }
}
