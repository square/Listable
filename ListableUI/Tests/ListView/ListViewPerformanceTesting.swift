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
    
    func test_contentSize() {
        
        let properties = ListProperties.default {
            $0.content = Content(
                identifier: nil,
                refreshControl: nil,
                header: HeaderFooter(TestHeaderFooterContent(title: "header")),
                footer:  HeaderFooter(TestHeaderFooterContent(title: "footer")),
                overscrollFooter: nil,
                sections: (1...5).map { sectionIndex in
                    
                    Section(sectionIndex) { section in
                        
                        section += (1...50).map { itemIndex in
                            TestContent(title: "")
                        }
                    }
                }
            )
        }
        
        let fittingSize = CGSize(width: 400, height: 700)
        
        self.determineAverage(for: 5.0) {
            _ = ListView.contentSize(in: fittingSize, for: properties)
        }
    }
}


fileprivate struct TestContent : ItemContent, Equatable
{
    var title : String
    
    var identifierValue: String {
        self.title
    }
    
    func apply(to views: ItemContentViews<Self>, for reason: ApplyReason, with info: ApplyItemContentInfo) {}
        
    static func createReusableContentView(frame: CGRect) -> UIView
    {
        return UIView(frame: frame)
    }
}

fileprivate struct TestHeaderFooterContent : HeaderFooterContent, Equatable
{
    var title : String
    
    func apply(
        to views: HeaderFooterContentViews<TestHeaderFooterContent>,
        for reason: ApplyReason,
        with info: ApplyHeaderFooterContentInfo
    ) {
        // Nothing for now
    }
    
    static func createReusableContentView(frame : CGRect) -> UIView
    {
        UIView(frame: frame)
    }
}
