//
//  Deprecations.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/29/20.
//

import Foundation

///
/// This file contains deprecations which have occurred in Listable, for which there are reasonable
/// forward-moving defaults (eg, renames), to ease transitions for consumers when they update their library version.
///
/// To add new deprecations and changes:
/// ------------------------------------
/// 1) Add a new `MARK: Deprecated <Date>` section for the deprecations you are adding.
///
/// 2) Add deprecation annotations like so:
///    ```
///    @available(*, deprecated, renamed: "ItemContent")
///    public typealias ItemElement = ItemContent
///    ```
///
///    Or, when deprecating properties, add a passthrough like so:
///    ```
///    public extension Item {
///       @available(*, deprecated, renamed: "content")
///       var element : Content {
///          self.content
///       }
///    }
///    ```
///
/// 3) After 1-2 months has passed, mark the previously `deprecated` items as `unavailable`:
///    ```
///    @available(*, unavailable, renamed: "ItemContent")
///    ```
///
/// 4) After another 1-2 months have passed, feel free to remove the `MARK: Deprecated` section you added.
///

//
// MARK: Deprecated Jul 15, 2020
//

public extension ListView {
    
    @available(*, unavailable, renamed: "configure(with:)")
    func setContent(_ builder : ListProperties.Build) {
        fatalError()
    }
    
    @available(*, unavailable, renamed: "configure(with:)")
    func setProperties(with builder : ListProperties.Build) {
        fatalError()
    }
    
    @available(*, unavailable, renamed: "configure(with:)")
    func setProperties(with properties : ListProperties) {
        fatalError()
    }
}

//
// MARK: Deprecated Jul 1, 2020
//

public extension Section {

    @available(*, unavailable, renamed: "Section.init(_:build:)")
    init<Identifier:Hashable>(
        identifier : Identifier,
        build : Build = { _ in }
    ) {
        fatalError()
    }
}


//
// MARK: Deprecated May 29, 2020
//

@available(*, unavailable, renamed: "ItemContent")
public typealias ItemElement = ItemContent

@available(*, unavailable, renamed: "ApplyItemContentInfo")
public typealias ApplyItemElementInfo = ApplyItemContentInfo

@available(*, unavailable, renamed: "ItemContentViews")
public typealias ItemElementViews = ItemContentViews

@available(*, unavailable, renamed: "ItemContentSwipeActionsView")
public typealias ItemElementSwipeActionsView = ItemContentSwipeActionsView

public extension Item {
    @available(*, unavailable, renamed: "content")
    var element : Content {
        self.content
    }
}

@available(*, unavailable, renamed: "HeaderFooterContent")
public typealias HeaderFooterElement = HeaderFooterContent

public extension HeaderFooter {
    @available(*, unavailable, renamed: "content")
    var element : Content {
        self.content
    }
}

public extension Content {
    @available(*, unavailable, message: "'Content.selectionMode' has moved to 'Behavior.selectionMode'.")
    var selectionMode : Behavior.SelectionMode {
        fatalError()
    }
}
