//
//  TableViewDemosDictionaryViewController.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/25/19.
//

import UIKit
import ListableCore
import Listable
import BlueprintLists
import BlueprintUI
import BlueprintUICommonControls


final public class TableViewDemosDictionaryViewController : UIViewController
{
    override public func loadView()
    {
        self.title = "Dictionary"
        
        let listView = ListView()
        
        listView.set(source: Source(dictionary: EnglishDictionary.dictionary), initial: Source.State(filter: ""))
        
        self.view = listView
    }
    
    final class Source : ListViewSource
    {
        let dictionary : EnglishDictionary
        //let searchRow : UIViewRowElement<SearchBar>
        
        init(dictionary : EnglishDictionary)
        {
            self.dictionary = dictionary
            
            //self.searchRow = UIViewRowElement(view: SearchBar())
        }
        
        struct State : Equatable
        {
            var filter : String = ""
            
            func include(_ word : String) -> Bool
            {
                return self.filter.isEmpty || word.contains(self.filter.lowercased())
            }
        }

        func content(with state: SourceState<State>, table: inout ContentBuilder)
        {
            if #available(iOS 10.0, *) {
                table.refreshControl = RefreshControl() { finished in
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                        finished()
                    }
                }
            }
            
//            table += Section(identifier: "Search") { rows in
//                self.searchRow.view.onStateChanged = { filter in
//                    state.value.filter = filter
//                }
//
//                rows += self.searchRow
//            }
            
            var hasContent = false
            
            table += self.dictionary.wordsByLetter.map { letter in
                
                return Section(identifier: letter.letter) { rows in
                    rows += letter.words.compactMap { word in
                        if state.value.include(word.word) {
                            hasContent = true
                            return Item(WordRow(title: word.word, detail: word.description))
                        } else {
                            return nil
                        }
                    }
                }
            }
            
            table.removeEmpty()
            
            if hasContent == false {
                table += Section(identifier: "emptty") { rows in
                    rows += Item(
                        WordRow(
                            title: "No Results For '\(state.value.filter)'",
                            detail: "Please enter a different search."
                        )
                    )
                }
            }
        }
    }
}

struct SearchRowAppearance : ItemElementAppearance
{
    // MARK: ItemElementAppearance
    
    typealias ContentView = SearchBar
    typealias BackgroundView = UIView
    typealias SelectedBackgroundView = UIView
    
    static func createReusableItemView() -> View
    {
        return ItemElementView(content: SearchBar(), background: UIView(), selectedBackground: UIView())
    }
    
    func update(view: View, with position: ItemPosition) {}
    
    func apply(to view: View, with state: ItemState, previous: SearchRowAppearance?) {}
}

struct SearchRow : ItemElement, Equatable
{
    var string : String
    
    // MARK: ItemElement
    
    typealias Appearance = SearchRowAppearance
    
    var identifier: Identifier<SearchRow> {
        return .init("search")
    }
    
    func apply(to view: Appearance.View, with state: ItemState, reason: ApplyReason)
    {
        view.content.text = self.string
    }
}


struct WordRow : BlueprintItemElement, Equatable
{
    var title : String
    var detail : String
    
    // MARK: BlueprintItemElement
    
    func element(with state: ItemState) -> Element {
        return Column { column in
            column.add(child: Label(text: self.title))
            column.add(child: Label(text: self.detail))
        }
    }
    
    var identifier: Identifier<WordRow> {
        return .init(self.title)
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
