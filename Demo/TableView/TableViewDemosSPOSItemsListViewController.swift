//
//  TableViewDemosSPOSItemsListViewController.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/25/19.
//

import UIKit

import Listable

import BlueprintUI
import BlueprintUICommonControls


final class TableViewDemosSPOSItemsListViewController : UIViewController
{
    let presenter = TableView.Presenter(initial: ContentSource.State(), contentSource: ContentSource(), tableView: TableView())
    
    override func loadView()
    {
        self.title = "Items"
        
        self.view = self.presenter.tableView
    }
    
    class ContentSource : TableViewContentSource
    {
        let searchRow = UIViewRowElement(view: SearchBar())
        
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
            
            table += TableView.Section(identifier: "actions") { rows in
                rows += Product(
                    tile: Tile(
                        abbreviation: .init(color: .darkGray, text: "$"),
                        image: nil
                    ),
                    title: "Custom Amount",
                    detail: "",
                    catalogID: UUID()
                )
                
                rows += Product(
                    tile: Tile(
                        abbreviation: .init(color: .darkGray, text: "Rw"),
                        image: nil
                    ),
                    title: "Redeem Rewards",
                    detail: "",
                    catalogID: UUID()
                )
                
                rows += Product(
                    tile: Tile(
                        abbreviation: .init(color: .darkGray, text: "Gc"),
                        image: nil
                    ),
                    title: "Gift Cards",
                    detail: "",
                    catalogID: UUID()
                )
            }
            
            let letters = EnglishDictionary.dictionary.wordsByLetter
            
            letters.forEach { letter in
                table += TableView.Section(header: letter.letter.capitalized) { rows in
                    
                    letter.words[0...50].forEach { word in
                        
                        if state.value.include(word.word) {
                            rows += Product(
                                tile: Tile(
                                    abbreviation: .init(color: randomColor(), text: String(word.word.prefix(2))),
                                    image: nil
                                ),
                                title: word.word,
                                detail: "\(Int.random(in: 2...10)) Prices",
                                catalogID: UUID()
                            )
                        }
                    }
                }
            }
            
            table.removeEmpty()
        }
    }
}

func randomColor() -> UIColor
{
    return UIColor(
        red:CGFloat.random(in: 0...1.0),
        green: CGFloat.random(in: 0...1.0),
        blue: CGFloat.random(in: 0...1.0),
        alpha: 1
    )
}

struct Product : TableViewRowViewElement, ProxyElement, Equatable
{
    var tile : Tile
    
    var title : String
    var detail : String
    
    var catalogID : UUID
    
    // MARK: TableViewRowViewElement
    
    var identifier: Identifier<Product> {
        return .init(catalogID)
    }
    
    typealias View = ElementView<Product>
    
    static func createReusableView() -> View
    {
        return ElementView(frame: .zero)
    }
    
    func applyTo(view : View, reason : ApplyReason)
    {
        view.element = self
    }
    
    // MARK: ProxyElement
    
    var elementRepresentation: Element {
        return Row() { stack in
            stack += (.zeroPriority, self.tile)
            
            let titleLabel = Inset(
                wrapping: Label(text: self.title) {
                    $0.font = Font.heading2.font
                    $0.color = .darkGray
                },
                left: 20.0
            )
            
            stack += (.zeroPriority, titleLabel)
            
            stack += Box()
            
            let detailLabel = Inset(
                wrapping: Label(text: self.detail) {
                    $0.font = Font.body.font
                    $0.color = .lightGray
                },
                right: 20.0
            )
            
            stack += (.zeroPriority, detailLabel)
            }.scaleContentToFit()
    }
}


struct Tile : ProxyElement, Equatable
{
    var abbreviation : Abbreviation
    var image : Image?
    
    struct Abbreviation : Equatable
    {
        var color : UIColor
        var text : String
    }
    
    struct Image : Equatable
    {
        var image : UIImage
    }
    
    // MARK: ProxyElement
    
    var elementRepresentation: Element {
        
        let box : Box
        
        if self.image != nil {
            // TODO
            box = Box(backgroundColor: UIColor.darkGray, cornerStyle: .square)
        } else {
            let label = Label(text: self.abbreviation.text) {
                $0.alignment = .center
                $0.color = .white
                $0.font = Font.heading.font
            }
            
            box = Box(backgroundColor: self.abbreviation.color, cornerStyle: .square, wrapping: label)
        }
        
        return Square(in: .vertical, box: box)
    }
}

struct Suggested : Equatable
{
    var tile : Tile
    
    var title : String
    var subtitle : String
    
    var amount : String
    
    var suggestedID : UUID
}

struct QuickAmount : Equatable
{
    var tile : Tile
    
    var title : String
    
    var amount : String
    
    var quickAmountID : UUID
}
