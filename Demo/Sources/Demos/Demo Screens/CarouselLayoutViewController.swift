//
//  CarouselLayoutViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 11/27/21.
//  Copyright © 2021 Kyle Van Essen. All rights reserved.
//

import ListableUI

import BlueprintUILists
import BlueprintUICommonControls


final class CarouselLayoutViewController : ListViewController {
    
    override func configure(list: inout ListProperties) {
        
        list.layout = .table {
            $0.layout.itemSpacing = 10
        }
        
        list.add {
            Section(1) {
                
                // Lil colored Squares
                
                Item.list("squares-flow", sizing: .fixed(height: 250)) { list in
                    
                    list.layout = .flow {
                        $0.direction = .horizontal
                        
                        $0.bounds = .init(padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
                        
                        $0.pagingBehavior = .firstVisibleItemEdge
                        
                        $0.spacings.itemSpacing = 10.0
                        $0.spacings.rowSpacing = 10
                    }
                    
                    list.add {
                        Section("colors") {
                            for (color, emoji) in Self.colors {
                                ColorItem(color: color, emoji: emoji)
                                    .with(
                                        sizing: .fixed(width: 75, height: 75),
                                        selectionStyle: .selectable(isSelected: false)
                                    )
                            }
                        }
                    }
                }
                
                Item.list("squares-table", sizing: .fixed(height: 100)) { list in
                    
                    list.layout = .table {
                        $0.direction = .horizontal
                        
                        $0.bounds = .init(padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
                        
                        $0.pagingBehavior = .firstVisibleItemEdge
                        
                        $0.layout.itemSpacing = 10.0
                    }
                                        
                    list.add {
                        Section("colors") {
                            for (color, emoji) in Self.colors {
                                ColorItem(color: color, emoji: emoji)
                                    .with(
                                        sizing: .fixed(width: 150),
                                        selectionStyle: .selectable(isSelected: false)
                                    )
                            }
                        }
                    }
                }
                
                Item.list("tags", sizing: .fixed(height: 500)) { list in
                    
                    list.behavior.selectionMode = .multiple
                    
                    list.layout = .flow {
                        
                        $0.bounds = .init(padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
                        
                        $0.width = .scrolls(width: .atMost(2000))
                        
                        $0.spacings.itemSpacing = 10.0
                        $0.spacings.rowSpacing = 10
                    }
                    
                    list.add {
                        Section("colors") {
                            for tag in Self.tagNames {
                                TagItem(text: tag)
                                    .with(
                                        selectionStyle: .selectable(isSelected: false)
                                    )
                            }
                        }
                    }
                }
            }
        }
    }
    
    private static let colors : [(UIColor, String)] = Array(
        repeating: [
            (.systemRed, "😀"),
            (.systemGreen, "😗"),
            (.systemBlue, "🤓"),
            (.systemOrange, "🥺"),
            (.systemYellow, "🥵"),
            (.systemPink, "😵‍💫"),
            (.systemPurple, "🤠"),
            (.systemTeal, "🥴"),
        ],
        count: 30
    ).flatMap { $0 }
    
    private static let tagNames : [String] =
        """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris molestie, tellus sit amet dignissim bibendum, leo tortor cursus lectus, nec molestie velit eros sed ligula. Vivamus id justo sed velit iaculis pharetra in quis nunc. Vivamus ut dictum dolor. Nam gravida pellentesque massa, in accumsan ex aliquet aliquet. Integer ultrices vulputate nisi, sed mattis lorem condimentum ut. Aliquam fringilla urna eros, vitae luctus nisi tincidunt sit amet. Mauris sagittis varius risus eu efficitur. Mauris sed congue nisi. Integer suscipit ligula eu diam sagittis, vel interdum lorem semper. Cras et turpis libero.
        """
        .components(separatedBy: .whitespacesAndNewlines)
        .filter { $0.count >= 3 }
}


fileprivate struct ColorItem : BlueprintItemContent, Equatable {
    
    var color : UIColor
    var emoji : String
    
    var identifierValue: UIColor {
        color
    }
    
    func element(with info: ApplyItemContentInfo) -> Element {
        Label(text: emoji) {
            $0.font = .systemFont(ofSize: 40.0, weight: .regular)
        }
        .centered()
        .box(
            background: color,
            corners: .rounded(radius: 10),
            shadow: .simple(radius: 3, opacity: 0.15, offset: .init(width: 0, height: 1), color: .black)
        )
    }
}

fileprivate struct TagItem : BlueprintItemContent, Equatable {
    
    var text : String
    
    var identifierValue: String {
        text
    }
    
    func element(with info: ApplyItemContentInfo) -> Element {
        Label(text: text) {
            $0.font = .systemFont(ofSize: 16.0, weight: .semibold)
            $0.color = info.state.isSelected ? .white : .darkGray
        }
        .inset(horizontal: 20, vertical: 10)
        .box(
            background: info.state.isSelected ? .darkGray : .white,
            corners: .capsule,
            borders: .solid(color: info.state.isSelected ? .black : .lightGray, width: 1),
            shadow: .simple(radius: 3, opacity: 0.15, offset: .init(width: 0, height: 1), color: .black)
        )
    }
}
