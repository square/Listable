//
//  CollectionViewDictionaryDemoViewController.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/25/19.
//

import UIKit
import Listable
import BlueprintLists
import BlueprintUI
import BlueprintUICommonControls


final public class CollectionViewDictionaryDemoViewController : UIViewController
{
    let listView = ListView()
    
    override public func loadView()
    {
        self.title = "Dictionary"
        
        self.listView.appearance.contentLayout.set {
            $0.width = .atMost(600.0)
            $0.sectionHeaderBottomSpacing = 10.0
            $0.rowSpacing = 7.0
            $0.interSectionSpacingWithNoFooter = 10.0
        }
        
        listView.set(source: Source(dictionary: EnglishDictionary.dictionary), initial: Source.State(filter: ""))
        
        self.view = self.listView
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Scroll Down", style: .plain, target: self, action: #selector(tappedScrollDown)),
            UIBarButtonItem(title: "Scroll Up", style: .plain, target: self, action: #selector(tappedScrollUp)),
        ]
    }
    
    @objc func tappedScrollDown()
    {
        self.listView.scrollTo(
            item: Identifier<WordRow>("clam"),
            position: .init(position: .centered, ifAlreadyVisible: .doNothing),
            animated: true
        )
    }
    
    @objc func tappedScrollUp()
    {
        self.listView.scrollTo(
            item: Identifier<WordRow>("aard-vark"),
            position: .init(position: .centered, ifAlreadyVisible: .doNothing),
            animated: true
        )
    }
    
    final class Source : ListViewSource
    {
        let dictionary : EnglishDictionary
        
        init(dictionary : EnglishDictionary)
        {
            self.dictionary = dictionary
        }
        
        struct State : Equatable
        {
            var filter : String = ""
            
            func include(_ word : String) -> Bool
            {
                return self.filter.isEmpty || word.contains(self.filter.lowercased())
            }
        }

        func content(with state: SourceState<State>, content: inout Content)
        {
            if #available(iOS 10.0, *) {
                content.refreshControl = RefreshControl() { finished in
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                        finished()
                    }
                }
            }
            
            content += Section(identifier: "search") { rows in
                rows += Item(
                    SearchRow(
                        string: state.value.filter,
                        onChange: { string in
                            state.value.filter = string
                    }
                ), appearance: SearchRowAppearance()
                )
            }
            
            var hasContent = false
            
            content += self.dictionary.wordsByLetter.map { letter in
                
                return Section(identifier: letter.letter) { section in
                    
                    section.header = HeaderFooter(
                        SectionHeader(title: letter.letter),
                        height: .thatFits(.noConstraint)
                    )
                    
                    section += letter.words.compactMap { word in
                        if state.value.include(word.word) {
                            hasContent = true
                            return Item(
                                WordRow(title: word.word, detail: word.description),
                                height: .thatFits(.atMost(250.0))
                            )
                        } else {
                            return nil
                        }
                    }
                }
            }
            
            content.removeEmpty()
            
            if hasContent == false {
                content += Section(identifier: "empty") { section in
                    section += Item(
                        WordRow(
                            title: "No Results For '\(state.value.filter)'",
                            detail: "Please enter a different search."
                        ),
                        height: .thatFits(.atMost(250.0))
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

struct SearchRow : ItemElement
{
    var string : String
    
    var onChange : (String) -> ()
    
    // MARK: ItemElement
    
    typealias Appearance = SearchRowAppearance
    
    var identifier: Identifier<SearchRow> {
        return .init("search")
    }
    
    func apply(to view: Appearance.View, with state: ItemState, reason: ApplyReason)
    {
        view.content.onStateChanged = self.onChange
        view.content.text = self.string
    }
    
    func wasUpdated(comparedTo other: SearchRow) -> Bool {
        return self.string != other.string
    }
}

struct SectionHeader : BlueprintHeaderFooterElement, Equatable
{
    var title : String
    
    // MARK: BlueprintItemElement
    
    var element: Element {
        return Box(
            backgroundColor: UIColor(white: 0.85, alpha: 1.0),
            cornerStyle: .rounded(radius: 10.0),
            wrapping: Inset(
                wrapping: Label(text: self.title) {
                    $0.font = .systemFont(ofSize: 32.0, weight: .bold)
                },
                top: 10.0, bottom: 10.0, left: 20.0, right: 20.0
            )
        )
    }
    
    var identifier: Identifier<SectionHeader> {
        return .init(self.title)
    }
}


struct WordRow : BlueprintItemElement, Equatable
{
    var title : String
    var detail : String
    
    // MARK: BlueprintItemElement
    
    func element(with state: ItemState) -> Element {
        return Box(
            backgroundColor: .init(white: 0.96, alpha: 1.0),
            cornerStyle: .rounded(radius: 10.0),
            wrapping: Inset(wrapping: Column { column in
                column.add(child: Label(text: self.title) {
                    $0.font = .systemFont(ofSize: 18.0, weight: .semibold)
                })
                
                column.add(child: Spacer(size: .init(width: 0.0, height: 10.0)))
                
                column.add(child: Label(text: self.detail) {
                    $0.font = .italicSystemFont(ofSize: 14.0)
                    $0.color = .darkGray
                })
            }, top: 10.0, bottom: 10.0, left: 20.0, right: 20.0)
        )
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
