//
//  ListStateObserver.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 7/9/20.
//

import Foundation


/// Allows reading state and events based on state changes within the list view.
/// For example, you can determine when a user scrolls, when the content of a list
/// changes, etc.
///
/// This is useful if you want to log these events to a logging or debugging system,
/// or potentially perform actions on the list based on some change.
///
/// Every callback has its own data type, filled with information relevant to that callback.
/// Every callback also contains a `ListActions` to perform actions back on the list.
///
/// You can register for each callback type multiple times – eg to split apart different pieces of
/// functionality. Eg, two calls to `onDidScroll` registers two callbacks.
///
/// ### Example
/// ```
/// ListStateObserver { observer in
///     observer.onDidScroll { info in
///         // Called whenever the list is scrolled.
///     }
///
///     observer.onContentChanged { info in
///         // Called when items are inserted or removed.
///     }
/// }
/// ```
///
/// ### Note
/// The duration of performing all callbacks is logged to `os_signpost`. If you find that
/// your application is running slowly, and you have registered `ListStateObserver` callbacks,
/// use Instruments.app to see what callback is slow.
///
public struct ListStateObserver {
    
    /// Creates and optionally allows you to configure an observer.
    public init(_ configure : (inout ListStateObserver) -> () = { _ in })
    {
        configure(&self)
    }
    
    //
    // MARK: Responding To Scrolling
    //
    
    public typealias OnDidScroll = (DidScroll) -> ()

    /// Registers a callback which will be called when the list view is scrolled, or is
    /// scrolled to top.
    ///
    /// ### Important Note!
    /// This callback is called very frequently when the user is scrolling the list (eg, every frame!).
    /// As such, make sure any work you do in the callback is efficient.
    public mutating func onDidScroll( _ callback : @escaping OnDidScroll)
    {
        self.onDidScroll.append(callback)
    }
    
    private(set) var onDidScroll : [OnDidScroll] = []
    
    //
    // MARK: Responding To Content Updates
    //
    
    public typealias OnContentUpdated = (ContentUpdated) -> ()
    
    /// Registers a callback which will be called when the list view's content is updated
    /// due to a call to `setContent`.
    ///
    /// ### Note
    /// This method is called even if there were no actual changes made during the `setContent`
    /// call. To see if there were changes, check the `hadChanges` property on `ContentUpdated`.
    public mutating func onContentUpdated( _ callback : @escaping OnContentUpdated)
    {
        self.onContentUpdated.append(callback)
    }
    
    private(set) var onContentUpdated : [OnContentUpdated] = []
    
    //
    // MARK: Responding To Visibility Changes
    //
    
    public typealias OnVisibilityChanged = (VisibilityChanged) -> ()
    
    /// Registers a callback which will be called when the list view's content is changed – eg through
    /// inserted, removed, updated, moved items or sections.
    public mutating func onVisibilityChanged( _ callback : @escaping OnVisibilityChanged)
    {
        self.onVisibilityChanged.append(callback)
    }
    
    private(set) var onVisibilityChanged : [OnVisibilityChanged] = []
    
    //
    // MARK: Responding To Frame Changes
    //
    
    public typealias OnFrameChanged = (FrameChanged) -> ()
    
    /// Registers a callback which will be called when the list view's frame is changed.
    public mutating func onFrameChanged(_ callback : @escaping OnFrameChanged)
    {
        self.onFrameChanged.append(callback)
    }
    
    private(set) var onFrameChanged : [OnFrameChanged] = []
    
    //
    // MARK: Responding To Selection Changes
    //
    
    public typealias OnSelectionChanged = (SelectionChanged) -> ()
    
    /// Registers a callback which will be called when the list view's selected items are changed by the user.
    public mutating func onSelectionChanged(_ callback : @escaping OnSelectionChanged)
    {
        self.onSelectionChanged.append(callback)
    }
    
    private(set) var onSelectionChanged : [OnSelectionChanged] = []
    
    //
    // MARK: Responding To Reordered Items
    //
    
    public typealias OnItemReordered = (ItemReordered) -> ()
    
    /// Registers a callback which will be called when an item in the list view is reordered by the customer.
    /// May be called multiple times in a row for reorder events which contain multiple items.
    public mutating func onItemReordered(_ callback : @escaping OnItemReordered)
    {
        self.onItemReordered.append(callback)
    }
    
    private(set) var onItemReordered : [OnItemReordered] = []
    
    //
    // MARK: Internal Methods
    //
    
    static func perform<CallbackInfo>(
        _ callbacks : Array<(CallbackInfo) -> ()>,
        _ loggingName : StaticString,
        with listView : ListView, makeInfo : (ListActions) -> (CallbackInfo)
    ){
        guard callbacks.isEmpty == false else {
            return
        }
        
        let actions = ListActions()
        actions.listView = listView
        
        let callbackInfo = makeInfo(actions)
        
        SignpostLogger.log(log: .stateObserver, name: loggingName, for: listView) {
            callbacks.forEach {
                $0(callbackInfo)
            }
        }
        
        actions.listView = nil
    }
}


extension ListStateObserver
{
    /// Parameters available for ``OnDidScroll`` callbacks.
    public struct DidScroll {
        public let actions : ListActions
        public let positionInfo : ListScrollPositionInfo
    }
    
    
    /// Parameters available for ``OnContentUpdated`` callbacks.
    public struct ContentUpdated {
        
        // If there were any changes included in this content update.
        public let hadChanges : Bool
        
        /// The insertions and removals in this change, if any.
        public let insertionsAndRemovals : InsertionsAndRemovals
        
        /// A set of methods you can use to perform actions on the list, eg scrolling to a given row.
        public let actions : ListActions
        
        /// The current scroll position of the list.
        public let positionInfo : ListScrollPositionInfo
        
        /// The insertions and removals, for both sections and items, applied to a list
        /// as the result of an update.
        ///
        /// Note that if developers do not provide unique IDs across sections,
        /// IDs will overlap for items across sections. Because `ChangedIDs`
        /// contains a `Set`, two sections inserting (or removing) an item with an equal ID
        /// will only be included in `ChangedIDs.inserted/removed` set once.
        public struct InsertionsAndRemovals {

            /// The inserted and removed sections.
            public var sections : ChangedIDs
            
            /// The inserted and removed items.
            public var items : ChangedIDs
            
            init(diff : SectionedDiff<Section, AnyIdentifier, AnyItem, AnyIdentifier>) {
                
                self.sections = ChangedIDs(
                    inserted: Set(diff.changes.added.map{ $0.identifier }),
                    removed: Set(diff.changes.removed.map{ $0.identifier })
                )
                
                self.items = ChangedIDs(
                    inserted: diff.changes.addedItemIdentifiers,
                    removed: diff.changes.removedItemIdentifiers
                )
            }
            
            /// The changed IDs.
            public struct ChangedIDs {
                
                /// The inserted IDs.
                public var inserted : Set<AnyIdentifier>
                
                /// The removed IDs.
                public var removed : Set<AnyIdentifier>
            }
        }
    }
    
    
    /// Parameters available for ``OnVisibilityChanged`` callbacks.
    public struct VisibilityChanged {
        
        /// A set of methods you can use to perform actions on the list, eg scrolling to a given row.
        public let actions : ListActions
        
        /// The current scroll position of the list.
        public let positionInfo : ListScrollPositionInfo
        
        /// The items which were scrolled into view or otherwise became visible.
        public let displayed : [AnyItem]
        
        /// The items which were scrolled out of view or otherwise were removed from view.
        public let endedDisplay : [AnyItem]
    }
    
    
    /// Parameters available for ``OnFrameChanged`` callbacks.
    public struct FrameChanged {
        
        /// A set of methods you can use to perform actions on the list, eg scrolling to a given row.
        public let actions : ListActions
        
        /// The current scroll position of the list.
        public let positionInfo : ListScrollPositionInfo

        /// The old frame within the bounds of the list.
        public let old : CGRect
        
        /// The new frame within the bounds of the list.
        public let new : CGRect
    }
    
    
    /// Parameters available for ``OnSelectionChanged`` callbacks.
    public struct SelectionChanged {
        
        /// A set of methods you can use to perform actions on the list, eg scrolling to a given row.
        public let actions : ListActions
        
        /// The current scroll position of the list.
        public let positionInfo : ListScrollPositionInfo

        /// The previously selected items' identifiers.
        public let old : Set<AnyIdentifier>
        
        /// The newly selected items' identifiers.
        public let new : Set<AnyIdentifier>
    }
    
    
    /// Parameters available for ``OnItemReordered`` callbacks.
    public struct ItemReordered {
        
        /// A set of methods you can use to perform actions on the list, eg scrolling to a given row.
        public let actions : ListActions
        
        /// The current scroll position of the list.
        public let positionInfo : ListScrollPositionInfo
        
        /// The item which was reordered by the customer.
        public let item : AnyItem
        
        /// The new state of all sections in the list.
        public let sections : [Section]
        
        /// The detailed information about the reorder event. 
        public let result : ItemReordering.Result
    }
}
