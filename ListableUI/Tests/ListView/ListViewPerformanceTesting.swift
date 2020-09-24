//
//  ListViewPerformanceTesting.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 6/30/20.
//

import XCTest
import EnglishDictionary
@testable import ListableUI


class ListViewPerformanceTesting : XCTestCase {
    
    override func invokeTest() {
        // Uncomment to be able to run perf testing.
        // super.invokeTest()
    }
    
    func test_no_diff_uncached_items()
    {
        let dictionary = EnglishDictionary.dictionary
        
        Thread.sleep(forTimeInterval: 0.5)
        
        let listView = ListView(frame: CGRect(x: 0.0, y: 0.0, width: 300.0, height: 500.0))
        
        self.determineAverage(for: 10.0) {
            listView.configure { list in
                list.animatesChanges = false
                
                list += dictionary.wordsByLetter.map { letter in
                    Section(letter.letter) { section in
                        section += letter.words.compactMap { word in
                            Item(
                                TestContent(title: word.word),
                                sizing: .fixed(height: 100.0)
                            )
                        }
                    }
                }
            }
        }
    }
    
    func test_no_diff_cached_items()
    {
        let dictionary = EnglishDictionary.dictionary
        
        Thread.sleep(forTimeInterval: 0.5)
        
        let listView = ListView(frame: CGRect(x: 0.0, y: 0.0, width: 300.0, height: 500.0))
        
        let sections = dictionary.wordsByLetter.map { letter in
            Section(letter.letter) { section in
                section += letter.words.compactMap { word in
                    Item(
                        TestContent(title: word.word),
                        sizing: .fixed(height: 100.0)
                    )
                }
            }
        }
        
        self.determineAverage(for: 10.0) {
            listView.configure { list in
                list.animatesChanges = false
                
                list += sections
            }
        }
    }
}


fileprivate struct TestContent : ItemContent, Equatable
{
    var title : String
    
    var identifier: Identifier<TestContent> {
        return .init(self.title)
    }
    
    func apply(to views: ItemContentViews<Self>, for reason: ApplyReason, with info: ApplyItemContentInfo) {}
    
    typealias ContentView = UIView
    
    static func createReusableContentView(frame: CGRect) -> UIView
    {
        return UIView(frame: frame)
    }
}
