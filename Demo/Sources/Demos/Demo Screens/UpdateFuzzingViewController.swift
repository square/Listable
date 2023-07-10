//
//  UpdateFuzzingViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 10/17/22.
//  Copyright © 2022 Kyle Van Essen. All rights reserved.
//

import UIKit
import ListableUI
import BlueprintUILists
import BlueprintUI
import BlueprintUICommonControls
import EnglishDictionary


final class UpdateFuzzingViewController : ListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(startFuzzing)),
            UIBarButtonItem(title: "Stop", style: .plain, target: self, action: #selector(stopFuzzing)),
        ]
    }
    
    private lazy var dictionary = EnglishDictionary.dictionary
    
    var isFilterOn : Bool = false
    
    override func configure(list: inout ListProperties) {
        
        list.layout = .table {
            
            $0.bounds = .init(
                padding: UIEdgeInsets(top: 0.0, left: 20.0, bottom: 20.0, right: 20.0),
                width: .atMost(600.0)
            )
            
            $0.layout.set {
                $0.sectionHeaderBottomSpacing = 10.0
                $0.itemSpacing = 7.0
                $0.interSectionSpacingWithNoFooter = 10.0
            }
        }
        
        list += self.dictionary.wordsByLetter.skipHalfMap(skip: isFilterOn) { letter in
            Section(letter.letter) {
                letter.words.skipHalfMap(skip: isFilterOn) { word in
                    Item(
                        WordRow(title: word.word, detail: word.description),
                        sizing: .thatFits(.init(.atMost(250.0)))
                    )
                }
            } header: {
                SectionHeader(title: letter.letter)
            }
        }
    }
    
    private var timer : Timer? = nil
    
    @objc private func stopFuzzing() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func startFuzzing() {
        guard timer == nil else { return }
        
        timer = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.isFilterOn.toggle()
            
            print("Reloading content...")
            
            self.reload(animated: true)
        }
        
        RunLoop.current.add(timer!, forMode: .tracking)
    }
}


fileprivate extension Array {
    
    func skipHalfMap<Mapped>(skip : Bool, using block : (Element) -> Mapped) -> [Mapped] {
        
        indexedCompactMap { index, element in
            if index % 2 == 0 && skip {
                return nil
            } else {
                return block(element)
            }
        }
        
    }
    
    func indexedCompactMap<Mapped>(_ map: (Int, Element) -> Mapped?) -> [Mapped] {

        var mapped = [Mapped]()

        for index in indices {
            if let value = map(index, self[index]) {
                mapped.append(value)
            }
        }

        return mapped
    }
}


fileprivate struct SectionHeader : BlueprintHeaderFooterContent, Equatable
{
    var title : String
    
    // MARK: BlueprintItemElement
    
    var elementRepresentation: Element {
        return Box(
            backgroundColor: UIColor(white: 0.85, alpha: 1.0),
            cornerStyle: .rounded(radius: 10.0),
            wrapping: Inset(
                top: 10.0,
                bottom: 10.0,
                left: 20.0,
                right: 20.0,
                wrapping: Label(text: self.title) {
                    $0.font = .systemFont(ofSize: 32.0, weight: .bold)
            })
        )
    }
    
    var identifier: String {
        self.title
    }
}

fileprivate struct WordRow : BlueprintItemContent, Equatable
{
    var title : String
    var detail : String
    
    // MARK: BlueprintItemElement
    
    func element(with info: ApplyItemContentInfo) -> Element
    {
        return Box(
            backgroundColor: .init(white: 0.96, alpha: 1.0),
            cornerStyle: .rounded(radius: 10.0),
            wrapping: Inset(top: 10.0, bottom: 10.0, left: 20.0, right: 20.0, wrapping: Column { column in
                column.add(child: Label(text: self.title) {
                    $0.font = .systemFont(ofSize: 18.0, weight: .semibold)
                })
                
                column.add(child: Spacer(size: .init(width: 0.0, height: 10.0)))
                
                column.add(child: Label(text: self.detail) {
                    $0.font = .italicSystemFont(ofSize: 14.0)
                    $0.color = .darkGray
                })
            })
        )
    }
    
    var identifierValue: String {
        self.title
    }
}
