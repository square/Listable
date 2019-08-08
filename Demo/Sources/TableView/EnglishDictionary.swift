//
//  EnglishDictionary.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/25/19.
//

import UIKit
import ListableTableView


class BundleFinder : NSObject {}

public class EnglishDictionary
{
    static let dictionary : EnglishDictionary = EnglishDictionary()
    
    let wordsByLetter : [Letter]
    let allWords : [Word]
    
    init()
    {
        let stream = InputStream(url: Bundle.main.url(forResource: "dictionary", withExtension: "json")!)!
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
}
