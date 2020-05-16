//
//  ListPreview.swift
//  Listable
//
//  Created by Kyle Van Essen on 5/15/20.
//

#if DEBUG && canImport(SwiftUI) && !arch(i386) && !arch(arm)

import UIKit
import SwiftUI

///
///
///
///
///
public struct ListPreview : UIViewRepresentable
{
    public var list : ListDescription
    
    public init( _ build : ListDescription.Build)
    {
        self.list = .default(build)
    }
    
    public init<ElementType:ItemElement>(_ provider : () -> ElementType)
    {
        self.init { list in
            list += Section(identifier: "section") { section in
                section += provider()
            }
        }
    }
    
    public init<HeaderFooterType:HeaderFooterElement>(_ provider : () -> HeaderFooterType)
    {
        self.init { list in
            list += Section(identifier: "section") { section in
                section.header = HeaderFooter(provider())
            }
        }
    }
    
    // MARK: UIViewRepresentable
    
    public typealias UIViewType = ListView
    
    public func makeUIView(context: Context) -> ListView {
        ListView()
    }
    
    public func updateUIView(_ listView: ListView, context: Context) {
        listView.setProperties(with: self.list)
    }
}

#endif
