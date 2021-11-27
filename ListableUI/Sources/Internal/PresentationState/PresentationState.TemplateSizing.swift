//
//  PresentationState.TemplateSizing.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/26/21.
//

import Foundation


extension PresentationState {
    
    final class TemplateSizing {
        
        private var items : [Key : WeakItemState] = [:]
        private var headerFooters : [Key : WeakHeaderFooterState] = [:]
        
        func size(for item : AnyItem)
    }
}


extension PresentationState.TemplateSizing {
    
    struct Key : Hashable {
        let sizing : Sizing.Template
        let typeIdentifier : ObjectIdentifier
    }
    
    fileprivate struct WeakItemState {
        weak private(set) var item : AnyPresentationItemState?
    }
    
    fileprivate struct WeakHeaderFooterState {
        weak private(set) var item : AnyPresentationHeaderFooterState?
    }
}
