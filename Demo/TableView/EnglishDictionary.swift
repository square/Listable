//
//  EnglishDictionary.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/25/19.
//

import Foundation

import Listable


class BundleFinder : NSObject {}

public class EnglishDictionary
{
    static let dictionary : EnglishDictionary = EnglishDictionary()
    
    let wordsByLetter : [Letter]
    let allWords : [Word]
    
    init()
    {
        let stream = InputStream(url: Bundle.ListableDemoResourcesBundle.url(forResource: "dictionary", withExtension: "json")!)!
        defer { stream.close() }
        stream.open()
        
        let json = try! JSONSerialization.jsonObject(with: stream, options: []) as! [String:String]
        
        var letters = [String:Letter]()
        var words = [Word]()
        
        for (word, description) in json
        {
            let firstCharacter = String(word.first!)
            let word = Word(word: word, description: description)
            
            let letter = letters[firstCharacter, default: Letter(letter: firstCharacter)]
            
            letter.words.append(word)
            words.append(word)
            
            letters[firstCharacter] = letter
        }
        
        self.wordsByLetter = letters.values.sorted { $0.letter < $1.letter }
        self.wordsByLetter.forEach { $0.sort() }
        
        self.allWords = words.sorted { $0.word < $1.word }
    }
    
    class Letter  {
        let letter : String
        var words : [Word] = []
        
        init(letter : String)
        {
            self.letter = letter
        }
        
        fileprivate func sort()
        {
            self.words.sort {
                $0.word < $1.word
            }
        }
    }
    
    struct Word {
        let word : String
        let description : String
    }
    
    public static func runPerformanceTest()
    {
        let dictionary = EnglishDictionary()
        
        for count in 0..<dictionary.wordsByLetter.count {
            
            let includedLetters = Array(dictionary.wordsByLetter[0...count])
            
            let wordCount : Int = includedLetters.reduce(0, { $0 + $1.words.count })
            
            let start = DispatchTime.now()
            
            _ = SectionedDiff(
                old: includedLetters,
                new: includedLetters,
                configuration: SectionedDiff.Configuration(
                    moveDetection: .checkAll,
                    
                    section: .init(
                        identifier: { AnyHashable($0.letter) },
                        rows: { $0.words },
                        updated: { $0.letter != $1.letter },
                        movedHint: { $0.letter != $1.letter }
                    ),
                    
                    row: .init(
                        identifier: { AnyHashable($0.word) },
                        updated: { $0.word != $1.word },
                        movedHint: { $0.word != $1.word }
                    )
                )
            )
            
            let end = DispatchTime.now()
            
            let seconds = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000.0
            
            print("Run Time for \(count) sections (\(wordCount) words): \(seconds).")
        }
    }
    
}
