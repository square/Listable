//
//  CoordinatorViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 5/19/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import BlueprintLists
import BlueprintUICommonControls


final class CoordinatorViewController : UIViewController
{
    let listView = ListView()
    
    override func loadView() {
        self.view = self.listView
        
        self.listView.setContent { list in
            
            list += Section(identifier: "section") { section in
                section += CoordinatedElement()
                section += CoordinatedElement()
                section += CoordinatedElement()
            }
        }
    }
}


fileprivate struct CoordinatedElement : BlueprintItemElement, Equatable
{
    var string : String = ""
    
    var identifier: Identifier<CoordinatedElement> {
        return .init("")
    }
    
    func element(with info: ApplyItemElementInfo) -> Element {
        return Label(text: self.string)
    }
    
    func makeCoordinator(actions: CoordinatorActions, info: CoordinatorInfo) -> Coordinator
    {
        Coordinator(actions: actions, info: info)
    }
    
    final class Coordinator : ItemElementCoordinator
    {
        typealias ItemElementType = CoordinatedElement
        
        let actions: CoordinatorActions
        let info: CoordinatorInfo
        
        var view : View? {
            didSet {
                
            }
        }
        
        init(actions: CoordinatorActions, info: CoordinatorInfo)
        {
            self.actions = actions
            self.info = info
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                self.actions.update {
                    $0.element.string += " \($0.element.string.count)"
                }
            }
        }
    }
}
