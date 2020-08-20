//
//  ContentFilters.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/21/20.
//

import Foundation


/// A filter enum which allows you to query the types of content contained in a `Content` or `Section` object.
public enum ContentFilters : Hashable, CaseIterable {
    
    /// If there is any content in the list at all, including headers and footers.
    public static var anyContent : Set<Self> {
        Set(self.allCases)
    }
    
    /// Check if the content in the list is section-driven content, with the
    /// check ignoring any list-level fields.
    public static var sectionsOnly : Set<Self> {
        [
            .sectionHeaders,
            .sectionFooters,
            .items
        ]
    }
    
    /// If the list has a list-level header.
    case listHeader
    /// If the list has a list-level footer.
    case listFooter
    /// If the list has an overscroll footer.
    case overscrollFooter
    
    /// If the sections in the list contain any items.
    case items
    /// If any section in the list has a header.
    case sectionHeaders
    /// If any section in the list has a footer.
    case sectionFooters
}
