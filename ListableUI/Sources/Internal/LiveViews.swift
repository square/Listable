//
//  LiveViews.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 12/29/21.
//

import Foundation


final class LiveCells {
    
    func add(_ view : AnyItemCell) {
        self.views.append(.init(value: view))
        
        self.views = self.views.filter { $0.value != nil }
    }
    
    func forEach(_ block : (AnyItemCell) -> ()) {
        self.views.forEach {
            if let view = $0.value {
                block(view)
            }
        }
    }
    
    private(set) var views : [Box] = []
    
    struct Box {
        weak var value : AnyItemCell?
    }
}


final class LiveSupplementaryViews {
    
    func add(_ view : SupplementaryContainerView) {
        self.views.append(.init(value: view))
        
        self.views = self.views.filter { $0.value != nil }
    }
    
    func perform(_ block : (SupplementaryContainerView) -> ()) {
        self.views.forEach {
            if let view = $0.value {
                block(view)
            }
        }
    }
    
    private(set) var views : [Box] = []
    
    struct Box {
        weak var value : SupplementaryContainerView?
    }
}

