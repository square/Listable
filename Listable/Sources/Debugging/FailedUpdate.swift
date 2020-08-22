//
//  FailedUpdate.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/21/20.
//

import Foundation


struct FailedUpdate : Codable {
    
    var old : [Section]
    var new : [Section]
    
    var diff : SectionedDiffInfo
    
    init(diff : SectionedDiff<Section, AnyIdentifier, AnyItem, AnyIdentifier>) {
        fatalError()
    }
    
    //
    // MARK: Codable
    //
    
    init(from decoder: Decoder) throws {
        fatalError()
    }
    
    func encode(to encoder: Encoder) throws {
        
    }
}

extension FailedUpdate {
    
    struct SectionedDiffInfo {
        
    }
    
    struct ArrayDiffInfo {
        
    }
    
    struct SectionInfo {
        var identifier : AnyIdentifier
    }
    
    struct HeaderFooterInfo {
        var reflectedValue : String
    }
    
    struct ItemContentInfo {
        var reflectedValue : String
        var identifier : AnyIdentifier
    }
}

extension FailedUpdate {
    
    struct HeaderFooterContent : Listable.HeaderFooterContent, Equatable {
                
        var reflectedValue : String
        
        typealias ContentView = UILabel
        
        static func createReusableContentView(frame: CGRect) -> UILabel {
            UILabel(frame: frame)
        }
        
        func apply(to views: HeaderFooterContentViews<FailedUpdate.HeaderFooterContent>, reason: ApplyReason) {
            views.content.text = self.reflectedValue
        }
    }

    struct ItemContent : Listable.ItemContent, Equatable {
        
        var reflectedValue : String
        var originalIdentifier : AnyIdentifier
        
        typealias ContentView = UILabel
        
        var identifier : Identifier<Self> {
            .init(originalIdentifier)
        }
        
        static func createReusableContentView(frame: CGRect) -> UILabel {
            UILabel(frame: frame)
        }
        
        func apply(to views: ItemContentViews<FailedUpdate.ItemContent>, for reason: ApplyReason, with info: ApplyItemContentInfo) {
            views.content.text = self.reflectedValue
        }
    }
}
