//
//  Deprecations.swift
//  Listable
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
    
    @available(*, deprecated, renamed: "setProperties(with:)")
    func setContent(_ builder : ListProperties.Build) {
        self.setProperties(with: builder)
    }
}

//
// MARK: Deprecated May 29, 2020
//

@available(*, deprecated, renamed: "ItemContent")
public typealias ItemElement = ItemContent

@available(*, deprecated, renamed: "ApplyItemContentInfo")
public typealias ApplyItemElementInfo = ApplyItemContentInfo

@available(*, deprecated, renamed: "ItemContentViews")
public typealias ItemElementViews = ItemContentViews

@available(*, deprecated, renamed: "ItemContentSwipeActionsView")
public typealias ItemElementSwipeActionsView = ItemContentSwipeActionsView

public extension Item {
    @available(*, deprecated, renamed: "content")
    var element : Content {
        self.content
    }
}

@available(*, deprecated, renamed: "HeaderFooterContent")
public typealias HeaderFooterElement = HeaderFooterContent

public extension HeaderFooter {
    @available(*, deprecated, renamed: "content")
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
