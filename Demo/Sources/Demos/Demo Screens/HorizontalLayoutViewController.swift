//
//  HorizontalLayoutViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 11/10/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import UIKit
import ListableUI
import BlueprintUI
import BlueprintUICommonControls
import BlueprintUILists


final class HorizontalLayoutViewController : UIViewController
{
    let listView = ListView()
    
    override func loadView()
    {
        self.view = self.listView
        
        self.listView.configure { list in
            
            list.layout = .table {
                $0.layout.itemSpacing = 20.0
                
                $0.bounds = .init(
                    padding: UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0),
                    width: .atMost(600)
                )
            }
            
            list.content.overscrollFooter = HeaderFooter(
                HorizontalHeader(title: "Thanks for using Listable!!", color: .white(0.65)),
                sizing: .fixed(height: 100.0)
            )
            
            list += Section("Cards") {
                Item(
                    CardElement(title: "This is the first card", detail: "Isn't it neat?", color: .white(0.95)),
                    sizing: .fixed(height: 200)
                )
                
                Item.list("carousel-paged", sizing: .fixed(height: 200.0)) { horizontal in
                    
                    horizontal.layout = .paged {
                        $0.direction = .horizontal
                        $0.itemInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
                    }

                    horizontal += Section("cards") {

                        for index in 1...20 {
                            Item(
                                CardElement(
                                    title: "This card #\(index)",
                                    detail: "",
                                    color: index % 2 == 0 ? .white(0.90) : .white(0.80)
                                ),
                                sizing: .fixed(width: 200)
                            )
                        }
                    }
                }
                
                Item.list("carousel-table", sizing: .fixed(height: 200.0)) { horizontal in
                    
                    horizontal.layout = .table {
                        $0.direction = .horizontal
                        
                        $0.pagingBehavior = .firstVisibleItemEdge
                        
                        $0.layout.itemSpacing = 20.0
                        
                        $0.bounds = .init(
                            padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                        )
                    }

                    horizontal += Section("cards") {
                        for index in 1...20 {
                            Item(
                                CardElement(
                                    title: "This card #\(index)",
                                    detail: "",
                                    color: index % 2 == 0 ? .white(0.90) : .white(0.80)
                                ),
                                sizing: .fixed(width: 200)
                            )
                        }
                    }
                }
                
                Item(
                    CardElement(title: "This is the fourth card", detail: "Isn't it neat?", color: .white(0.95)),
                    sizing: .fixed(height: 200)
                )
                
                Item(
                    CardElement(title: "This is the fifth card", detail: "Isn't it neat?", color: .white(0.95)),
                    sizing: .fixed(height: 200)
                )
            }
        }
    }
}


fileprivate struct HorizontalHeader : BlueprintHeaderFooterContent, Equatable
{
    var title : String
    var color : UIColor
    
    var elementRepresentation: Element {
        return Box(
            backgroundColor: self.color,
            cornerStyle: .rounded(radius: 15.0),
            wrapping: Inset(uniformInset: 10.0,  wrapping: Label(text: self.title) {
                $0.font = .systemFont(ofSize: 18.0, weight: .bold)
            })
        )
    }
}

fileprivate struct CardElement : BlueprintItemContent, Equatable
{
    var title : String
    var detail : String
    var color : UIColor
    
    func element(with info : ApplyItemContentInfo) -> Element
    {
        Column { column in
            
            column.verticalUnderflow = .growProportionally
            column.horizontalAlignment = .fill
            
            column.add(growPriority: 0.0, child: Label(text: self.title) {
                $0.font = .systemFont(ofSize: 24.0, weight: .bold)
            })
            
            column.add(growPriority: 0.0, child: Spacer(size: .init(width: 20.0, height: 20.0)))
            
            column.add(growPriority: 0.0, child: Label(text: self.detail) {
                $0.font = .systemFont(ofSize: 18.0, weight: .semibold)
            })
        }
        .inset(uniform: 30.0)
        .box(background: self.color, corners: .rounded(radius: 15.0))
    }
    
    var identifierValue: String {
        self.title
    }
    
}
