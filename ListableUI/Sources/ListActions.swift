//
//  ListActions.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 7/12/20.
//

import Foundation
import UIKit


///
/// `ListActions` is an type that you can use to gain access to actions to perform on a `List`
/// (for example, scrolling to a given item in the list) when used when you otherwise do
/// not have a reference to the underlying list view (for example, when using `ListViewController` or `BlueprintUILists`).
///
/// You also gain access to a `ListActions` instance when using `ListStateObserver`, in each registered callback.
///
/// You usually use `ListActions` by keeping an instance on your view controller,
/// and then assign it when providing list content. Once the list is updated with the content,
/// the `ListActions` will be registered with the list to perform actions.
///
/// A `ListActions` behaviors are split into internal sub-objects, such as `Scrolling` and `ViewControllerTransitioning`.
/// You can pass these separate objects around if your code invokes actions from several different places.
///
/// Only one `ListActions` can be registered in a list at a time. If you register a new one, it replaces the last one,
/// and any actions performed on the last instance become no-ops.
///
/// Example
/// -------
/// ```
/// final class ListStateViewController : ListViewController
/// {
///     // Owned by the view controller.
///     let actions = ListActions()
///
///     override func configure(list : inout ListProperties)
///     {
///         list.appearance = .myAppearance
///         list.layout = .myLayout
///
///         // Registered with list here.
///         list.actions = self.actions
///
///         list.stateObserver = ListStateObserver { reader in
///             reader.onDidScroll { info in
///                 // Perform an action based on scrolling.
///             }
///         }
///     }
///
///     private func performScrollTo(item : AnyItem)
///     {
///         // Used here to scroll to an item.
///         self.actions.scrolling.scrollTo(item: item, position: .init(position: .top), animated: true)
///     }
/// }
/// ```
public final class ListActions {
        
    /// Actions which allow scrolling to individual items in a list.
    public let scrolling : Scrolling
    
    /// Actions which allow hooking up your list to the view controller transitioning APIs.
    public let viewControllerTransitioning : ViewControllerTransitioning
    
    /// Creates and returns an actions object which can be registered with a list view.
    public init() {
        self.scrolling = Scrolling()
        self.viewControllerTransitioning = ViewControllerTransitioning()
    }
    
    weak var listView : ListView? {
        didSet {
            self.scrolling.listView = self.listView
            self.viewControllerTransitioning.listView = self.listView
        }
    }

    /// Provides access to scrolling actions within a list view.
    public final class Scrolling {
        
        public init() {}
        
        fileprivate weak var listView : ListView?
        
        public typealias ScrollCompletion = ListView.ScrollCompletion
        
        ///
        /// Scrolls to the provided item, with the provided positioning.
        /// If the item is contained in the list, true is returned. If it is not, false is returned.
        ///
        @discardableResult
        public func scrollTo(
            item : AnyItem,
            position : ScrollPosition,
            animated : Bool = false,
            completion: ScrollCompletion? = nil
        ) -> Bool
        {
            guard let listView = self.listView else {
                return false
            }
            
            return listView.scrollTo(
                item: item,
                position: position,
                animated: animated,
                completion: completion
            )
        }
        
        ///
        /// Scrolls to the item with the provided identifier, with the provided positioning.
        /// If there is more than one item with the same identifier, the list scrolls to the first.
        /// If the item is contained in the list, true is returned. If it is not, false is returned.
        ///
        @discardableResult
        public func scrollTo(
            item : AnyIdentifier,
            position : ScrollPosition,
            animated : Bool = false,
            completion: ScrollCompletion? = nil
            ) -> Bool
        {
            guard let listView = self.listView else {
                return false
            }
            
            return listView.scrollTo(
                item: item,
                position: position,
                animated: animated,
                completion: completion
            )
        }

        ///
        /// Scrolls to the section with the given identifier, with the provided scroll and section positioning.
        ///
        /// If there is more than one section with the same identifier, the list scrolls to the first.
        /// If the section has any content and is contained in the list, true is returned. If not, false is returned.
        ///
        /// The list will first attempt to scroll to the section's supplementary view
        /// (header for `SectionPosition.top`, footer for `SectionPosition.bottom`).
        ///
        /// If not found, the list will scroll to the adjacent item instead
        /// (section's first item for `.top`, last item for `.bottom`).
        ///
        /// If none of the above are present, the list will fallback to the remaining supplementary view
        /// (footer for `.top`, header for `.bottom`).
        ///
        @discardableResult
        public func scrollToSection(
            with identifier : AnyIdentifier,
            sectionPosition : SectionPosition = .top,
            scrollPosition : ScrollPosition,
            animated: Bool = false,
            completion: ScrollCompletion? = nil
        ) -> Bool
        {
            guard let listView = self.listView else {
                return false
            }

            return listView.scrollToSection(
                with: identifier,
                sectionPosition: sectionPosition,
                scrollPosition: scrollPosition,
                animated: animated,
                completion: completion
            )
        }
        
        /// Scrolls to the very top of the list, which includes displaying the list header.
        @discardableResult
        public func scrollToTop(
            animated: Bool = false
        ) -> Bool
        {
            guard let listView = self.listView else {
                return false
            }
            
            return listView.scrollToTop(
                animated: animated
            )
        }

        /// Scrolls to the last item in the list. If the list contains no items, no action is performed.
        @discardableResult
        public func scrollToLastItem(
            animated: Bool = false
        ) -> Bool
        {
            guard let listView = self.listView else {
                return false
            }
           
            return listView.scrollToLastItem(
                animated: animated
            )
        }
    }
    
    /// Provides access to view controller transitioning options in a list.
    public final class ViewControllerTransitioning {
        
        public init() {}
        
        fileprivate weak var listView : ListView?
        
        func clearSelectionDuringViewWillAppear(alongside coordinator: UIViewControllerTransitionCoordinator?, animated : Bool)
        {
            guard let listView = self.listView else {
                return
            }
           
            listView.clearSelectionDuringViewWillAppear(alongside: coordinator, animated: animated)
        }
    }
}
