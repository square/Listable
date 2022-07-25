//
//  EnglishDictionary.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/25/19.
//

import UIKit

internal extension Bundle {
    static var resources: Bundle {
        #if SWIFT_PACKAGE
            return .module
        #else
            let main = Bundle(for: EnglishDictionary.self)
            return Bundle(url: main.url(forResource: "EnglishDictionaryResources", withExtension: "bundle")!)!
        #endif
    }
}

public class EnglishDictionary {
    public static let dictionary: EnglishDictionary = .init()

    public let wordsByLetter: [Letter]
    public let allWords: [Word]

    public init() {
        let bundle = Bundle.resources

        let stream = InputStream(url: bundle.url(forResource: "dictionary", withExtension: "json")!)!
        defer { stream.close() }
        stream.open()

        let json = try! JSONSerialization.jsonObject(with: stream, options: []) as! [String: String]

        var letters = [String: Letter]()
        var words = [Word]()

        for (word, description) in json {
            let firstCharacter = String(word.first!)
            let word = Word(word: word, description: description)

            let letter = letters[firstCharacter, default: Letter(letter: firstCharacter)]

            letter.words.append(word)
            words.append(word)

            letters[firstCharacter] = letter
        }

        wordsByLetter = letters.values.sorted { $0.letter < $1.letter }
        wordsByLetter.forEach { $0.sort() }

        allWords = words.sorted { $0.word < $1.word }
    }

    public class Letter {
        public let letter: String
        public var words: [Word] = []

        init(letter: String) {
            self.letter = letter
        }

        fileprivate func sort() {
            words.sort {
                $0.word < $1.word
            }
        }
    }

    public struct Word: Equatable {
        public let word: String
        public let description: String
    }
}
