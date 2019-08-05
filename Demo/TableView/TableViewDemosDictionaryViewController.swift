//
//  TableViewDemosDictionaryViewController.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/25/19.
//

import UIKit

import Listable

final public class TableViewDemosDictionaryViewController : UIViewController
{
    override public func loadView()
    {
        self.title = "Dictionary"
        
        self.view = TableView(state: Source.State(), source: Source(dictionary: EnglishDictionary.dictionary))
    }
    
    final class Source : TableViewSource
    {
        let dictionary : EnglishDictionary
        let searchRow : UIViewRowElement<SearchBar>
        
        init(dictionary : EnglishDictionary)
        {
            self.dictionary = dictionary
            
            self.searchRow = UIViewRowElement(view: SearchBar())
        }
        
        struct State : Equatable
        {
            var filter : String = ""
            
            func include(_ word : String) -> Bool
            {
                return self.filter.isEmpty || word.contains(self.filter.lowercased())
            }
        }

        func content(with state: SourceState<State>, table: inout TableView.ContentBuilder)
        {
            if #available(iOS 10.0, *) {
                table.refreshControl = RefreshControl() { finished in
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                        finished()
                    }
                }
            }
            
            table += TableView.Section(identifier: "Search") { rows in
                self.searchRow.view.onStateChanged = { filter in
                    state.value.filter = filter
                }
                
                rows += self.searchRow
            }
            
            var hasContent = false
            
            table += self.dictionary.wordsByLetter.map { letter in
                
                return TableView.Section(header: letter.letter) { rows in
                    
                    rows += letter.words.compactMap { word in
                        if state.value.include(word.word) {
                            hasContent = true
                            return TableView.Row(SubtitleRow(text: word.word, detail: word.description))
                        } else {
                            return nil
                        }
                    }
                }
            }
            
            table.removeEmpty()
            
            if hasContent == false {
                table += TableView.Section(identifier: "emptty") { rows in
                    rows += TableView.Row(
                        SubtitleRow(
                            text: "No Results For '\(state.value.filter)'",
                            detail: "Please enter a different search."
                        )
                    )
                }
            }
        }
    }
}


final class SearchBar : UISearchBar, UISearchBarDelegate
{
    init()
    {
        super.init(frame: .zero)
        
        self.delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    typealias StateChanged = (String) -> ()
    var onStateChanged : StateChanged?
    
    var searchTimer : Timer?
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if #available(iOS 10.0, *) {
            self.searchTimer?.invalidate()
            
            self.searchTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { _ in
                self.onStateChanged?(searchText)
            }
        }
    }
}
