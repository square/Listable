//
//  LocalizedItemCollator.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 12/7/20.
//

import UIKit


///
/// If you would like to make your `ItemContent` work with the `LocalizedItemCollator`,
/// you should make it conform to this protocol, and then return a `collationString` that
/// represents the primary content of your `ItemContent`; usually a name or title.
///
/// Upon collation, the `ItemContent` will then be grouped into sections according to its
/// first "character" in a localized manner.
/// ```
/// struct MyContent : ItemContent, LocalizedCollatableItemContent {
///
///     var title : String
///
///     var collationString : String {
///         self.title
///     }
/// }
/// ```
public protocol LocalizedCollatableItemContent : ItemContent {
    
    /// A string that represents the primary content of your `ItemContent`; usually a name or title.
    var collationString : String { get }
}


///
/// Represents an `AnyItem` which can be collated, via its vended `collationString`.
///
/// `Item` (and by extension `AnyItem`) is conditionally conformed to this protocol
/// when its `Content` conforms to `LocalizedCollatableItemContent`,
/// to allow vending homogenous lists of content to be collated.
///
public protocol AnyLocalizedCollatableItem : AnyItem {
    var collationString : String { get }
}


///
/// If you're looking for the equivalent of `UILocalizedIndexedCollation` for lists,
/// you have come to the right place.
///
/// `LocalizedItemCollator` takes in a list of unsorted content, and sorts and then
/// partitions the content into sections, returning you a list of collated sections for display.
///
/// Just like `UILocalizedIndexedCollation`, `LocalizedItemCollator` takes
/// into account the localization settings of the device, using different collation for the various
/// supported iOS languages.
///
/// Example
/// -------
/// ```
/// List { list in
///     list += LocalizedItemCollator.sections(with: items) { collated, section in
///
///         /// You are passed a pre-populated section on which you may
///         /// customize the header and footer, or mutate the content.
///
///         section.header = HeaderFooter(DemoHeader(title: collated.title))
///         section.footer = HeaderFooter(DemoFooter(title: collated.title))
///     }
/// }
///
/// ```
/// Warning
/// -------
/// Sorting and partitioning thousands and thousands of `Items` each
/// time a list updates can be expensive, especially on slower devices.
///
/// If you have a list that you wish to collate that may contain thousands of items,
/// it is recommended that you store the list pre-collated outside of Listable,
/// so each recreation of the list's view model does not re-partake in an expensive sort operation.
/// Instead only re-collate when the underlying list receives an update (from Core Data, an API callback, etc).
///
public struct LocalizedItemCollator {
    
    //
    // MARK: Public
    //
    
    /// Collates and returns the set of items into list `Sections`,
    /// allowing you to customize each `Section` via the provided `modify`
    /// closure.
    ///
    /// ```
    /// List { list in
    ///     list += LocalizedItemCollator.sections(with: items) { collated, section in
    ///         section.header = HeaderFooter(DemoHeader(title: collated.title))
    ///         section.footer = HeaderFooter(DemoFooter(title: collated.title))
    ///     }
    /// }
    ///
    /// ```
    public static func sections(
        collation : UILocalizedIndexedCollation = .current(),
        with items : [AnyLocalizedCollatableItem],
        _ modify : (CollatedSection, inout Section) -> () = { _, _ in }
    ) -> [Section]
    {
        let collated = Self.collate(collation: collation, items: items)
        
        return collated.map { collated in
            var section = Section(collated.title, items: collated.items)
            
            modify(collated, &section)
            
            return section
        }
    }
    
    /// Collates and returns the set of items into `CollatedSection`s.
    /// You may then convert these into list `Section`s, or for another use.
    public static func collate(
        collation : UILocalizedIndexedCollation = .current(),
        items : [AnyLocalizedCollatableItem]
    ) -> [CollatedSection]
    {
        Self.init(
            collation: collation,
            items: items
        ).collated
    }
    
    //
    // MARK: Internal
    //
    
    let collated : [CollatedSection]
    
    init(
        collation : UILocalizedIndexedCollation = .current(),
        items : [AnyLocalizedCollatableItem]
    ) {
        /// 1) Convert to providers so we can leverage `collationStringSelector`, which is Objective-C only.
        
        let providers = items.map {
            Provider(item: $0)
        }
        
        /// 2) Convert the titles from the collation into sections.
        
        var collated = collation.sectionTitles.map { title in
            CollatedSection(title: title)
        }
        
        /// 3) Sort all of the provided content based on the `collationString`.
        
        let sorted = collation.sortedArray(from: providers, collationStringSelector: #selector(getter: Provider.collationString))
        
        /// 4) Insert the sorted content into the correct section's items.
        
        for provider in sorted {
            let provider = provider as! Provider
            
            let sectionIndex = collation.section(for: provider, collationStringSelector: #selector(getter: Provider.collationString))
            
            collated[sectionIndex].items.append(provider.item)
        }
        
        /// 5) Only provide collated items that have content.
        
        self.collated = collated.filter { $0.items.isEmpty == false }
    }
    
    /// A private wrapper that is used to ensure we have an Objective-C selector to vend to `collationStringSelector`.
    private final class Provider {
        
        /// The item backing the provider, to vend the `collationString`.
        let item : AnyLocalizedCollatableItem
        
        /// The string used to collate all items.
        @objc let collationString : String
        
        init(item: AnyLocalizedCollatableItem) {
            self.item = item
            self.collationString = self.item.collationString
        }
    }
}


extension LocalizedItemCollator {
    
    /// The output of the collator, with the collated title and items
    /// that should be added to a given section.
    public struct CollatedSection {
        
        /// The title of section – a single letter like A, B, C, D, E, etc.
        /// Localized depending on locale.
        /// See https://nshipster.com/uilocalizedindexedcollation/ for more examples.
        public var title : String
        
        /// The sorted items in the collated sections.
        public var items : [AnyItem] = []
    }
}


/// Ensures that `Item` (and by extension, `AnyItem`) will conform to `LocalizedCollatableItem`
/// when its `content` conforms to `LocalizedCollatableItemContent`.
extension Item : AnyLocalizedCollatableItem where Content : LocalizedCollatableItemContent {
    
    public var collationString: String {
        self.content.collationString
    }
}
