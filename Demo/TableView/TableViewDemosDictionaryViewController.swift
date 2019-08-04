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
    let presenter = TableView.Presenter(
        initial: ContentSource.State(),
        contentSource: ContentSource(dictionary: EnglishDictionary.dictionary),
        tableView: TableView(frame: .zero)
    )
    
    override public func loadView()
    {
        self.title = "Dictionary"
        
        self.view = self.presenter.tableView
    }
    
    final class ContentSource : TableViewContentSource
    {
        var dictionary : EnglishDictionary
        
        var searchRow : UIViewRowElement<SearchBar>
        
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
                return self.filter.count == 0 || word.contains(self.filter.lowercased())
            }
        }

        func tableViewContent(with state: TableView.State<State>, table: inout TableView.ContentBuilder)
        {
            table += TableView.Section(identifier: "Search") { rows in
                self.searchRow.view.onStateChanged = { filter in
                    state.update { state in
                        state.filter = filter
                    }
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
