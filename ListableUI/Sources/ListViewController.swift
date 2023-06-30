//
//  ListViewController.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/21/20.
//

import Foundation
import UIKit


///
/// A class which provides an easy way to set up and display a `ListView`,
/// The `ListViewController` itself manages setup and presentation of the `ListView`.
///
/// As a consumer of the API, all you need to do is override one method:
/// ```
/// func configure(list : inout ListProperties) {
///     ...
/// }
/// ```
/// In which you set up and configure the list as needed.
///
/// In order to reload the list when content changes or other display changes are required, call
/// ```
/// func reload(animated : Bool = false)
/// ```
/// Which will update the list with the new contents returned from your `configure` method.
/// If the `ListViewController`'s view is not loaded, this method has no effect.
///
open class ListViewController : UIViewController
{
    //
    // MARK: Configuration
    //
    
    /// The default value for `clearsSelectionOnViewWillAppear` is true.
    /// This parameter allows mirroring the `clearsSelectionOnViewWillAppear`
    /// as available from `UITableViewController` or `UICollectionViewController`.
    public var clearsSelectionOnViewWillAppear : Bool = true
    
    //
    // MARK: Methods To Override
    //
    
    /// Override this method to configure your list how you'd like to.
    /// The properties on `ListProperties` closely mirror those on `ListView`
    /// itself, allowing you to fully configure and work with a list without needing to maintain
    /// and manage the view instance yourself.
    ///
    /// Example
    /// -------
    /// ```
    /// override func configure(list : inout ListProperties)
    /// {
    ///     list.appearance = .myAppearance
    ///
    ///     list.layout = .table { appearance in
    ///         // Configure the appearance.
    ///     }
    ///
    ///     list.stateObserver.onContentChanged { info in
    ///         MyLogger.log(...)
    ///     }
    ///
    ///     list("first-section") { section in
    ///         section += self.myPodcasts.map { podcast in
    ///             PodcastItem(podcast)
    ///         }
    ///     }
    /// }
    /// ```
    /// You should not call super in your overridden implementation.
    ///
    open func configure(list : inout ListProperties)
    {
        fatalError("Subclasses of `ListViewController` must override `configure(list:)` to customize the content of their list view.")
    }
    
    //
    // MARK: Updating Content
    //
    
    public func reload(animated : Bool = false)
    {
        guard let listView = self.listView else {
            return
        }

        listView.configure { list in
            list.animatesChanges = animated
            self.configure(list: &list)
        }
    }

    
    //
    // MARK: - Internal & Private Methods -
    //
    
    
    // MARK: Initialization
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable) required public init?(coder: NSCoder) { fatalError() }
    
    // MARK: UIViewController
    
    private var listView : ListView?
    
//    public override func loadView() {
//        let listView = ListView()
//
//        self.listView = listView
////        self.view = listView
//        self.view.addSubview(listView)
//    }
    open override func viewDidLoad() {
        let listView = ListView()
        view.clipsToBounds = false
        listView.clipsToBounds = false
        self.view.addSubview(listView)
        self.listView = listView
    }

    open override func viewDidLayoutSubviews() {
        self.listView?.frame = CGRectInset(self.view.frame, 200, 300)
    }
    
    private var hasViewAppeared : Bool = false
    
    open override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if self.hasViewAppeared == false {
            self.hasViewAppeared = true
            self.reload(animated: false)
        } else {
            if self.clearsSelectionOnViewWillAppear {
                self.listView?.clearSelectionDuringViewWillAppear(alongside: self.transitionCoordinator, animated: animated)
            }
        }
    }
}


public extension ListView {
    
    /// A method which provides `Behavior.SelectionMode.single`'s `clearsSelectionOnViewWillAppear` behaviour.
    /// By default, this method is called by `ListViewController`. However if you are not using `ListViewController` you
    /// will need to call this method yourself one of two ways:
    ///
    /// 1) If subclassing `UIViewController`: within your view controller's `viewWillAppear` method.
    ///
    /// 2) By invoking this same method on your `ListActions` that you have wired up to your list view. Use this
    /// in the case that you do not have access to your list view at all, such as when using `BlueprintUILists`.
    ///
    /// // Behaviour from UIKit Eng: https://twitter.com/smileyborg/status/1279473615553982464
    ///
    func clearSelectionDuringViewWillAppear(alongside coordinator: UIViewControllerTransitionCoordinator?, animated : Bool) {
        
        guard case Behavior.SelectionMode.single = behavior.selectionMode else {
            return
        }

        guard let indexPath = storage.presentationState.selectedIndexPaths.first else {
            return
        }
        
        let item = storage.presentationState.item(at: indexPath)
        
        guard let coordinator = coordinator else {
            // No transition coordinator is available – we should just deselect return in this case.
            item.set(isSelected: false, performCallbacks: true)
            collectionView.deselectItem(at: indexPath, animated: animated)
            item.applyToVisibleCell(with: self.environment)

            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            item.set(isSelected: false, performCallbacks: true)
            self.collectionView.deselectItem(at: indexPath, animated: true)
            item.applyToVisibleCell(with: self.environment)
        }, completion: { context in
            if context.isCancelled {
                item.set(isSelected: true, performCallbacks: false)
                self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                item.applyToVisibleCell(with: self.environment)
            }
        })
    }
}
