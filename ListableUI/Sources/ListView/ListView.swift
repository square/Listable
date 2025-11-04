//
//  ListView.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/16/19.
//

import UIKit


public final class ListView : UIView
{
    //
    // MARK: Initialization
    //
    
    public init(frame: CGRect = .zero, appearance : Appearance = Appearance())
    {
        // Create all default values.

        self.animation = .default
        
        self.appearance = appearance
        
        self.behavior = Behavior()
        self.autoScrollAction = .none
        self.onKeyboardFrameWillChange = nil
        self.scrollIndicatorInsets = .zero
        
        self.storage = Storage()
        
        self.environment = .empty
        
        self.sourcePresenter = SourcePresenter(initial: StaticSource.State(), source: StaticSource())
        
        self.dataSource = DataSource()
        self.delegate = Delegate()
        
        let initialLayout = CollectionViewLayout(
            delegate: self.delegate,
            layoutDescription: .table(),
            appearance: self.appearance,
            behavior: self.behavior
        )

        self.collectionView = CollectionView(
            frame: CGRect(origin: .zero, size: frame.size),
            collectionViewLayout: initialLayout
        )
        
        self.layoutManager = LayoutManager(
            layout: initialLayout,
            collectionView: self.collectionView
        )
        
        self.liveCells = LiveCells()
                
        self.visibleContent = VisibleContent()

        self.keyboardObserver = KeyboardObserver.shared
        KeyboardObserver.logKeyboardSetupWarningIfNeeded()
        
        self.stateObserver = ListStateObserver()
        
        self.collectionView.isPrefetchingEnabled = false
        
        self.collectionView.delegate = self.delegate
        self.collectionView.dataSource = self.dataSource
        
        self.closeActiveSwipesGesture = TouchDownGestureRecognizer()

        self.updateQueue = ListChangesQueue()
        
        // Super init.
        
        super.init(frame: frame)
        
        // Associate ourselves with our child objects.

        self.dataSource.view = self
        self.dataSource.presentationState = self.storage.presentationState
        self.dataSource.storage = self.storage
        self.dataSource.liveCells = self.liveCells
        
        self.delegate.view = self
        self.delegate.presentationState = self.storage.presentationState
        self.delegate.layoutManager = self.layoutManager
        
        self.keyboardObserver.add(delegate: self)
        
        self.closeActiveSwipesGesture.addTarget(self, action: #selector(closeActiveSwipeGestureIfNeeded))
        self.addGestureRecognizer(closeActiveSwipesGesture)

        self.closeActiveSwipesGesture.shouldRecognize = { [weak self] touch in
            self?.shouldRecognizeCloseSwipeTouch(touch) ?? false
        }
        
        self.updateQueue.listHasUncommittedReorderUpdates = { [weak collectionView] in
            collectionView?.hasUncommittedUpdates ?? false
        }
        
        // Register supplementary views.
        
        SupplementaryKind.allCases.forEach {
            SupplementaryContainerView.register(in: self.collectionView, for: $0.rawValue)
        }
        
        // Size and update views.
        
        self.collectionView.frame = self.bounds
        self.addSubview(self.collectionView)
        
        self.applyAppearance()
        self.applyBehavior()
        self.updateScrollViewInsets()
        
        /// We track first responder status in supplementary views
        /// to fix a view recycling issue.
        ///
        /// See the comment in `collectionView(_:viewForSupplementaryElementOfKind:at:)
        /// within `ListView.DataSource.swift` for more.
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidBeginEditingNotification(_:)),
            name: UITextField.textDidBeginEditingNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidEndEditingNotification(_:)),
            name: UITextField.textDidEndEditingNotification,
            object: nil
        )
    }
    
    deinit
    {        
        self.keyboardObserver.remove(delegate: self)
        
        /**
         Even though these are zeroing weak references in UIKIt as of iOS 9.0,
         
         We still want to nil these out, because _our_ `delegate` and `dataSource`
         objects have unowned references back to us (`ListView`). We do not want
         any `delegate` or `dataSource` callbacks to trigger referencing
         that unowned reference (eg, in `scrollViewDidScroll:`).
         */

        self.collectionView.delegate = nil
        self.collectionView.dataSource = nil
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { listableInternalFatal() }
    
    //
    // MARK: Internal Properties
    //
    
    let storage : Storage
    let collectionView : CollectionView
    let delegate : Delegate
    let layoutManager : LayoutManager
    let liveCells : LiveCells
    
    var collectionViewLayout : CollectionViewLayout {
        self.layoutManager.collectionViewLayout
    }
    
    var performsContentCallbacks : Bool = true {
        didSet {
            self.storage.presentationState.performsContentCallbacks = self.performsContentCallbacks
        }
    }
    
    private(set) var visibleContent : VisibleContent
    
    //
    // MARK: Private Properties
    //
            
    private var sourcePresenter : AnySourcePresenter

    private var autoScrollAction : AutoScrollAction
    
    private let dataSource : DataSource
    
    private let keyboardObserver : KeyboardObserver

    private var lastKeyboardFrame : KeyboardFrame? = nil
    
    //
    // MARK: Debugging
    //
    
    public var debuggingIdentifier : String? = nil
    
    //
    // MARK: Appearance
    //
    
    public var animation : ListAnimation
    
    public var appearance : Appearance {
        didSet {
            guard oldValue != self.appearance else {
                return
            }
            
            self.applyAppearance()
        }
    }
    
    private func applyAppearance()
    {
        // Appearance
        
        self.collectionViewLayout.appearance = self.appearance
        self.backgroundColor = self.appearance.backgroundColor
        
        // Scroll View
        
        self.updateCollectionViewWithCurrentLayoutProperties()
    }
    
    //
    // MARK: Layout
    //
        
    public var scrollPositionInfo : ListScrollPositionInfo {
        let visibleItems = Set(self.visibleContent.items.map { item in
            let itemFrame = self.collectionViewLayout.frameForItem(at: item.indexPath)
            let visibleFrame = self.collectionView.visibleContentFrame
            return ListScrollPositionInfo.VisibleItem(
                identifier: item.item.anyModel.anyIdentifier,
                percentageVisible: itemFrame.percentageVisible(inside: visibleFrame)
            )
        })
        
        return ListScrollPositionInfo(
            scrollView: self.collectionView,
            visibleItems: visibleItems,
            isFirstItemVisible: self.content.firstItem.map { firstItem in
                visibleItems.contains(where: { $0.identifier == firstItem.anyIdentifier })
            } ?? false,
            isLastItemVisible: self.content.lastItem.map { lastItem in
                visibleItems.contains(where: { $0.identifier == lastItem.anyIdentifier })
            } ?? false
        )
    }
    
    public var layout : LayoutDescription {
        get { self.collectionViewLayout.layoutDescription }
        set { self.set(layout: newValue, animated: false) }
    }

    public func set(layout new : LayoutDescription, animated : Bool = false, completion : @escaping () -> () = {})
    {
        let needsInsetUpdate = layout.needsCollectionViewInsetUpdate(for: new)
        
        self.layoutManager.set(layout: new, animated: animated, completion: completion)
        
        if needsInsetUpdate {
            self.updateScrollViewInsets()
        }
    }
    
    public var contentSize : CGSize {
        return self.collectionViewLayout.layout.content.contentSize
    }
    
    //
    // MARK: Behavior
    //
    
    public var behavior : Behavior {
        didSet {
            guard oldValue != self.behavior else {
                return
            }
            
            self.applyBehavior()
        }
    }
    
    private func applyBehavior()
    {
        self.collectionViewLayout.behavior = self.behavior
        
        self.collectionView.verticalLayoutGravity = self.behavior.verticalLayoutGravity
        self.collectionView.layoutDirection = self.collectionViewLayout.layout.direction
        
        self.collectionView.keyboardDismissMode = self.behavior.keyboardDismissMode
        
        self.collectionView.canCancelContentTouches = self.behavior.canCancelContentTouches
        self.collectionView.delaysContentTouches = self.behavior.delaysContentTouches

        let newDecelerationRate = UICollectionView.DecelerationRate(behaviorValue: self.behavior.decelerationRate)
        if newDecelerationRate != self.collectionView.decelerationRate {
            self.collectionView.decelerationRate = newDecelerationRate
        }

        // Apply focus behavior
        switch self.behavior.focus {
        case .none:
            self.collectionView.allowsFocus = false
            self.collectionView.selectionFollowsFocus = false
        case .allowsFocus:
            self.collectionView.allowsFocus = true
            self.collectionView.selectionFollowsFocus = false
        case .selectionFollowsFocus:
            self.collectionView.allowsFocus = true
            self.collectionView.selectionFollowsFocus = true
        }

        self.updateCollectionViewWithCurrentLayoutProperties()
        self.updateCollectionViewSelectionMode()
        
        self.updateScrollViewInsets()
    }
    
    private func updateCollectionViewWithCurrentLayoutProperties()
    {
        self.collectionViewLayout.layout.scrollViewProperties.apply(
            to: self.collectionView,
            behavior: self.behavior,
            direction: self.collectionViewLayout.layout.direction,
            showsScrollIndicators: self.appearance.showsScrollIndicators
        )
    }
    
    private func updateCollectionViewSelectionMode()
    {
        let view = self.collectionView
        
        switch self.behavior.selectionMode {
        case .none:
            view.allowsSelection = false
            view.allowsMultipleSelection = false
            
        case .single:
            view.allowsSelection = true
            view.allowsMultipleSelection = false
            
        case .multiple:
            view.allowsSelection = true
            view.allowsMultipleSelection = true
        }
    }
    
    //
    // MARK: Scroll Insets
    //

    /// Returns true when the content size is large enough that scrolling is possible
    public var isContentScrollable: Bool {
        collectionView.isContentScrollable
    }


    public var scrollIndicatorInsets : UIEdgeInsets {
        didSet {
            guard oldValue != self.scrollIndicatorInsets else {
                return
            }
            
            self.updateScrollViewInsets()
        }
    }
        
    /// Callback for when the keyboard changes
    public typealias KeyboardFrameWillChangeCallback = (
        KeyboardCurrentFrameProvider,
        (animationDuration: Double, animationCurve: UIView.AnimationCurve)
    ) -> Void

    /// Called whenever a keyboard change is detected
    public var onKeyboardFrameWillChange: KeyboardFrameWillChangeCallback?

    public struct ScrollViewInsets {
        /// Insets for the content view
        public let content: UIEdgeInsets

        /// Insets for the horizontal scroll bar
        public let horizontalScroll: UIEdgeInsets

        /// Insets for the vertical scroll bar
        public let verticalScroll: UIEdgeInsets
        
        /// All values are optional, and default to `.zero`
        /// - Parameters:
        ///   - content: Insets for the content view
        ///   - horizontalScroll: Insets for the horizontal scroll bar
        ///   - verticalScroll: Insets for the vertical scroll bar
        public init(
            content: UIEdgeInsets = .zero,
            horizontalScroll: UIEdgeInsets = .zero,
            verticalScroll: UIEdgeInsets = .zero
        ) {
            self.content = content
            self.horizontalScroll = horizontalScroll
            self.verticalScroll = verticalScroll
        }
    }

    /// This callback determines the scroll view's insets only when
    /// `behavior.keyboardAdjustmentMode` is `.custom`
    public var customScrollViewInsets: () -> ScrollViewInsets = { .init() }

    /// Call this to trigger an insets update.
    /// When the `keyboardAdjustmentMode` is `.custom`, you should set
    /// a `customScrollViewInsets` callback and then call this method
    /// whenever insets require an update.
    public func updateScrollViewInsets()
    {
        let insets: ScrollViewInsets
        if case .custom = self.behavior.keyboardAdjustmentMode {
            insets = self.customScrollViewInsets()
        } else {
            insets = self.calculateScrollViewInsets(
                with: self.keyboardObserver.currentFrame(in: self)
            )
        }

        if self.collectionView.contentInset != insets.content {
            self.collectionView.contentInset = insets.content
        }
        
        if self.collectionView.horizontalScrollIndicatorInsets != insets.horizontalScroll {
            self.collectionView.horizontalScrollIndicatorInsets = insets.horizontalScroll
        }

        if self.collectionView.verticalScrollIndicatorInsets != insets.verticalScroll {
            self.collectionView.verticalScrollIndicatorInsets = insets.verticalScroll
        }
    }

    func calculateScrollViewInsets(with keyboardFrame : KeyboardFrame?) -> ScrollViewInsets    {
        let keyboardBottomInset : CGFloat = {
            
            guard let keyboardFrame = keyboardFrame else {
                return 0.0
            }
            
            guard layout.wantsKeyboardInsetAdjustment else {
                return 0.0
            }
            
            switch self.behavior.keyboardAdjustmentMode {
            case .none:
                return 0.0
                
            case .adjustsWhenVisible:
                switch keyboardFrame {
                case .nonOverlapping:
                    return 0.0
                    
                case .overlapping(let frame):
                    return (self.bounds.size.height - frame.origin.y) - self.safeAreaInsets.bottom
                }

            case .custom:
                fatalError("Shouldn't call calculateScrollViewInsets for custom case")
            }
        }()

        let scrollInsets = modified(self.scrollIndicatorInsets) {
            $0.bottom = max($0.bottom, keyboardBottomInset)
        }
        
        let contentInsets = modified(self.collectionView.contentInset) {
            $0.bottom = keyboardBottomInset
        }
        
        return .init(
            content: contentInsets,
            horizontalScroll: UIEdgeInsets(
                top: 0,
                left: scrollInsets.left,
                bottom: 0,
                right: scrollInsets.right
            ),
            verticalScroll: UIEdgeInsets(
                top: scrollInsets.top,
                left: 0,
                bottom: scrollInsets.bottom,
                right: 0
            )
        )
    }

    
    //
    // MARK: List State Observation
    //
    
    /// A state observer allows you to receive callbacks when varying types
    /// of changes occur within the list's state, such as scroll events,
    /// content change events, frame change events, or item visibility changes.
    ///
    /// See the `ListStateObserver` for more info.
    public var stateObserver : ListStateObserver
    
    /// Allows registering a `ListActions` object associated
    /// with the list view that allows you to perform actions such as scrolling to
    /// items, or controlling view appearance transitions.
    private var actions : ListActions? {
        didSet {
            oldValue?.listView = nil
            
            self.actions?.listView = self
        }
    }
    
    //
    // MARK: Public - Scrolling To Sections & Items
    //
    
    /// TODO: The below functions do not yet work for horizontal lists.
    /// A pass needs to be done to change math and offsets based on the `LayoutDirection`
    /// of the current layout.
    
    public typealias ScrollCompletion = ListStateObserver.OnDidEndScrollingAnimation
    
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
        self.scrollTo(
            item: item.anyIdentifier,
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
        // Make sure the item identifier is valid.

        guard let toIndexPath = self.storage.allContent.firstIndexPathForItem(with: item) else {
            handleScrollCompletion(reason: .cannotScroll, completion: completion)
            return false
        }

        // If user is performing this in a `UIView.performWithoutAnimation` block, respect that and don't animate, regardless of what the animated parameter is.
        let shouldAnimate = animated && UIView.areAnimationsEnabled

        return preparePresentationStateForScroll(to: toIndexPath, handlerWhenFailed: completion) {
            
            /// `preparePresentationStateForScroll(to:)` is asynchronous in some
            /// cases, we need to re-query our section index in case it changed or is no longer valid.
            
            guard let toIndexPath = self.storage.allContent.firstIndexPathForItem(with: item) else {
                self.handleScrollCompletion(reason: .cannotScroll, completion: completion)
                return
            }
            
            let itemFrame = self.collectionViewLayout.frameForItem(at: toIndexPath)
            let viewport = self.collectionView.visibleContentFrame
            let isAlreadyVisible = viewport.contains(itemFrame)

            // If the item is already visible and that's good enough, return.

            if isAlreadyVisible && position.ifAlreadyVisible == .doNothing {
                self.handleScrollCompletion(reason: .cannotScroll, completion: completion)
                return
            }

            let sectionHeader = self.collectionViewLayout.layout.content.sections[toIndexPath.section].header

            // Prevent the item from appearing underneath a sticky section header.

            if sectionHeader.isPopulated,
               self.collectionViewLayout.layout.stickySectionHeaders,
               position.position == .top {

                let itemFrameAdjustedForStickyHeaders = CGRect(
                    x: itemFrame.minX,
                    y: itemFrame.minY - sectionHeader.size.height,
                    width: itemFrame.width,
                    height: itemFrame.height
                )
                self.performScroll(
                    to: itemFrameAdjustedForStickyHeaders,
                    scrollPosition: position,
                    animated: shouldAnimate,
                    completion: completion
                )
            } else {
                let scrollPosition = position.position.toUICollectionViewScrollPosition(
                    for: self.collectionViewLayout.layout.direction
                )
                self.collectionView.scrollToItem(
                    at: toIndexPath,
                    at: scrollPosition,
                    animated: shouldAnimate
                )
                if let completion {
                    let willScroll = self.willScroll(
                        for: scrollPosition,
                        itemFrame: itemFrame,
                        viewport: viewport.inset(by: self.collectionView.adjustedContentInset),
                        contentSize: self.contentSize
                    )
                    if willScroll {
                        self.handleScrollCompletion(reason: .scrolled(animated: animated), completion: completion)
                    } else {
                        self.handleScrollCompletion(reason: .cannotScroll, completion: completion)
                    }
                }
            }
        }
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

        let storageContent = storage.allContent

        // Make sure the section identifier is valid.

        guard let sectionIndex = storageContent.firstIndexForSection(with: identifier) else {
            self.handleScrollCompletion(reason: .cannotScroll, completion: completion)
            return false
        }

        return preparePresentationStateForScrollToSection(index: sectionIndex, handlerWhenFailed: completion) {
            
            /// `preparePresentationStateForScrollToSection` is asynchronous in some
            /// cases, we need to re-query our section index in case it changed or is no longer valid.
            
            guard let sectionIndex = storageContent.firstIndexForSection(with: identifier) else {
                self.handleScrollCompletion(reason: .cannotScroll, completion: completion)
                return
            }
            
            let layoutContent = self.collectionViewLayout.layout.content

            // Make sure the section has content.

            guard layoutContent.sections[sectionIndex].all.isEmpty == false else {
                self.handleScrollCompletion(reason: .cannotScroll, completion: completion)
                return
            }
            
            let header = layoutContent.sections[sectionIndex].header
            let footer = layoutContent.sections[sectionIndex].footer
            let items = storageContent.sections[sectionIndex].items

            let targetSupplementaryView = (sectionPosition == .top) ? header : footer
            let fallbackSupplementaryView = (sectionPosition == .top) ? footer : header
            let adjacentItem = (sectionPosition == .top) ? items.first : items.last

            // Prevent the footer from appearing underneath a sticky section header.

            let footerFrameAdjustedForStickyHeaders: CGRect? = {
                guard sectionPosition == .bottom,
                      self.collectionViewLayout.layout.stickySectionHeaders,
                      scrollPosition.position == .top
                else {
                    return nil
                }
                return CGRect(
                    x: footer.x,
                    y: footer.y - header.size.height,
                    width: footer.size.width,
                    height: footer.size.height
                )
            }()

            if targetSupplementaryView.isPopulated {
                self.performScroll(
                    to: footerFrameAdjustedForStickyHeaders ?? targetSupplementaryView.defaultFrame,
                    scrollPosition: scrollPosition,
                    animated: animated,
                    completion: completion
                )
            } else if let adjacentItem = adjacentItem {
                self.scrollTo(
                    item: adjacentItem,
                    position: scrollPosition,
                    animated: animated,
                    completion: completion
                )
            } else {
                self.performScroll(
                    to: fallbackSupplementaryView.defaultFrame,
                    scrollPosition: scrollPosition,
                    animated: animated,
                    completion: completion
                )
            }
        }
    }
    
    /// Scrolls to the very top of the list, which includes displaying the list header.
    @discardableResult
    public func scrollToTop(
        animated: Bool = false
    ) -> Bool {
        
        // The rect we scroll to must have an area – an empty rect will result in no scrolling.
        let rect = CGRect(origin: .zero, size: CGSize(width: 1.0, height: 1.0))

        // If user is performing this in a `UIView.performWithoutAnimation` block, respect that and don't animate, regardless of what the animated parameter is.
        let shouldAnimate = animated && UIView.areAnimationsEnabled

        return self.preparePresentationStateForScroll(to: IndexPath(item: 0, section: 0), handlerWhenFailed: nil)  {
            self.collectionView.scrollRectToVisible(rect, animated: shouldAnimate)
        }
    }

    /// Scrolls to the last item in the list. If the list contains no items, no action is performed.
    @discardableResult
    public func scrollToLastItem(
        animated: Bool = false
    ) -> Bool {

        // Make sure we have a valid last index path.

        guard let toIndexPath = self.storage.allContent.lastIndexPath() else {
            return false
        }

        // If user is performing this in a `UIView.performWithoutAnimation` block, respect that and don't animate, regardless of what the animated parameter is.
        let shouldAnimate = animated && UIView.areAnimationsEnabled

        // Perform scrolling.

        return self.preparePresentationStateForScroll(to: toIndexPath, handlerWhenFailed: nil)  {
            let contentHeight = self.collectionViewLayout.collectionViewContentSize.height
            let contentFrameHeight = self.collectionView.visibleContentFrame.height

            guard contentHeight > contentFrameHeight else {
                return
            }

            let contentOffsetY = contentHeight - contentFrameHeight - self.collectionView.adjustedContentInset.top
            let contentOffset = CGPoint(x: self.collectionView.contentOffset.x, y: contentOffsetY)
            
            self.collectionView.setContentOffset(contentOffset, animated: shouldAnimate)
        }
    }
    
    //
    // MARK: Private - Scrolling
    //
    
    private enum ScrollCompletionReason {
        case cannotScroll
        case scrolled(animated: Bool)
    }
    
    /// This function is used by programmatic scrolling APIs that provide a scroll
    /// completion handler. This will execute the `completion` handler after scrolling
    /// is finished, or it will execute immediately if scrolling is not possible or if
    /// animations are disabled.
    private func handleScrollCompletion(reason: ScrollCompletionReason, completion: ScrollCompletion?) {
        guard let completion else { return }
        switch reason {
        case .cannotScroll:
            // Dispatch so that the completion handler executes on the next runloop
            // execution.
            DispatchQueue.main.async {
                completion(ListStateObserver.DidEndScrollingAnimation(positionInfo: self.scrollPositionInfo))
            }
        case .scrolled(let animated):
            if animated {
                scrollCompletionHandlers.append(completion)
            } else {
                // Dispatch so that scrolling without an animation executes the closure
                // on the next runloop execution, similar to scrolling with an animation.
                DispatchQueue.main.async {
                    // Sync the `scrollPositionInfo` before executing the handler.
                    self.performEmptyBatchUpdates()
                    completion(ListStateObserver.DidEndScrollingAnimation(positionInfo: self.scrollPositionInfo))
                }
            }
        }
    }
    
    /// This is used to house the completion handlers of scrolling APIs. This is kept
    /// internal and separate from `ListStateObserver` and its handlers.
    internal var scrollCompletionHandlers: [ScrollCompletion] = []
    
    /// This is called by the `ListView.Delegate` and is used to notify the
    /// `scrollCompletionHandler` that scrolling finished. This does nothing if there is
    /// no handler set.
    internal func didEndScrolling() {
        
        guard scrollCompletionHandlers.isEmpty == false else { return }
        let handlers = scrollCompletionHandlers
        
        // Proactively remove these handlers before executing them. This avoids a
        // potential edge case where clients have synchronous code in a handler that
        // makes another call to `scrollTo(...)` with a completion handler.
        scrollCompletionHandlers.removeAll()
        
        // Sync the `scrollPositionInfo` before executing the handlers.
        //
        // Calling `performEmptyBatchUpdates()` will synchronously call the
        // `CollectionViewLayout`'s `prepare()` function. That will update the
        // list's `visibleContent`, which `scrollPositionInfo` uses to accurately
        // find the visible items.
        //
        // ListViewTests has unit tests to assert that the handler's items are correct.
        performEmptyBatchUpdates()
        let positionInfo = scrollPositionInfo
        handlers.forEach { handler in
            handler(ListStateObserver.DidEndScrollingAnimation(positionInfo: positionInfo))
        }
    }
    
    /// This function will determine if a call to `collectionView.scrollToItem(...)`
    /// will result in an adjusted content offset. This is necessary because when the
    /// item is already at the expected position, `UICollectionView` will not scroll
    /// and will not execute its `scrollViewDidEndScrollingAnimation(_:)` delegate.
    func willScroll(
        for scrollPosition: UICollectionView.ScrollPosition,
        itemFrame: CGRect,
        viewport: CGRect,
        contentSize: CGSize
    ) -> Bool {
        let distanceToScroll: CGFloat
        switch scrollPosition {
        case .top:
            distanceToScroll = abs(itemFrame.minY - viewport.minY)
        case .bottom:
            distanceToScroll = abs(itemFrame.maxY - viewport.maxY)
        case .centeredVertically:
            distanceToScroll = abs(itemFrame.midY - viewport.midY)
        case .left:
            distanceToScroll = abs(itemFrame.minX - viewport.minX)
        case .right:
            distanceToScroll = abs(itemFrame.maxX - viewport.maxX)
        case .centeredHorizontally:
            distanceToScroll = abs(itemFrame.midX - viewport.midX)
        default:
            return false
        }
        
        // UICollectionView will not scroll when the distance is under 0.5. Because
        // of this, we floor/ceil the distance calculations to eagerly return false
        // for floats under 1.0.
        guard floor(distanceToScroll) > 0 else { return false }
        let canScrollUp = floor(viewport.minY) > 0
        let canScrollLeft = floor(viewport.minX) > 0
        let canScrollDown = ceil(viewport.maxY - contentSize.height) < 0
        let canScrollRight = ceil(viewport.maxX - contentSize.width) < 0
        
        switch scrollPosition {
        case .top:
            return itemFrame.minY > viewport.minY ? canScrollDown : canScrollUp
        case .bottom:
            return itemFrame.maxY > viewport.maxY ? canScrollDown : canScrollUp
        case .centeredVertically:
            return itemFrame.midY > viewport.midY ? canScrollDown : canScrollUp
        case .left:
            return itemFrame.minX > viewport.minX ? canScrollRight : canScrollLeft
        case .right:
            return itemFrame.maxX > viewport.maxX ? canScrollRight : canScrollLeft
        case .centeredHorizontally:
            return itemFrame.midX > viewport.midX ? canScrollRight : canScrollLeft
        default:
            return false
        }
    }
    
    //
    // MARK: Setting & Getting Content
    //
    
    /// The environment associated with the list, which is used to pass data through to
    /// the list's layout, or through to items, headers/footers, etc.
    ///
    /// If you have used SwiftUI's environment, Listable's environment is similar.
    ///
    /// ### Note
    /// Setting the environment, or a property on the environment, does **not** force a re-layout
    /// of the list view. The newly provided environment values will be used during the next update.
    public var environment : ListEnvironment
    
    public var content : Content {
        get { return self.storage.allContent }
        set { self.setContent(animated: false, newValue) }
    }
    
    public func setContent(animated : Bool = false, _ content : Content)
    {
        self.set(
            source: StaticSource(with: content),
            initial: StaticSource.State(),
            animated: animated
        )
    }
    
    private var sourceChangedTimer : ReloadTimer? = nil
    
    @discardableResult
    public func set<Source:ListViewSource>(source : Source, initial : Source.State, animated : Bool = false) -> StateAccessor<Source.State>
    {
        self.sourcePresenter.discard()
        
        let sourcePresenter = SourcePresenter(initial: initial, source: source, didChange: { [weak self] in
            guard let self = self else { return }
            guard self.sourceChangedTimer == nil else { return }
            
            self.sourceChangedTimer = ReloadTimer {
                self.sourceChangedTimer = nil
                self.setContentFromSource(animated: true)
            }
        })
        
        self.sourcePresenter = sourcePresenter
        
        self.setContentFromSource(animated: animated)
        
        return StateAccessor(get: {
            sourcePresenter.state
        }, set: {
            sourcePresenter.state = $0
        })
    }
    
    public func configure(with configure : ListProperties.Configure)
    {
        let description = ListProperties(
            animatesChanges: true,
            animation: self.animation,
            layout: self.layout,
            appearance: self.appearance,
            scrollIndicatorInsets: self.scrollIndicatorInsets,
            behavior: self.behavior,
            autoScrollAction: self.autoScrollAction,
            onKeyboardFrameWillChange: self.onKeyboardFrameWillChange,
            accessibilityIdentifier: self.collectionView.accessibilityIdentifier,
            debuggingIdentifier: self.debuggingIdentifier,
            configure: configure
        )
        
        self.configure(with: description)
    }
    
    let updateQueue : ListChangesQueue
    
    public func configure(with properties : ListProperties)
    {
        /// We enqueue these changes into the update queue to ensure they are not applied
        /// before it is safe to do so. Currently, "safe" means "during the application of a reorder".
        ///
        /// See `CollectionViewLayout.sendEndQueuingEditsAfterDelay()` for more.
        
        self.updateQueue.add { [weak self] in
            guard let self = self else { return }
            
            let animated = properties.animatesChanges
            
            self.animation = properties.animation
            self.appearance = properties.appearance
            self.behavior = properties.behavior
            self.autoScrollAction = properties.autoScrollAction
            self.onKeyboardFrameWillChange = properties.onKeyboardFrameWillChange
            self.scrollIndicatorInsets = properties.scrollIndicatorInsets
            self.collectionView.accessibilityIdentifier = properties.accessibilityIdentifier
            self.debuggingIdentifier = properties.debuggingIdentifier
            self.actions = properties.actions

            self.stateObserver = properties.stateObserver
            
            self.environment = properties.environment
            
            self.set(layout: properties.layout, animated: animated)
            
            self.setContent(animated: animated, properties.content)
        }
    }
    
    private func setContentFromSource(animated : Bool = false)
    {
        let oldIdentifier = self.storage.allContent.identifier
        
        self.storage.allContent = self.sourcePresenter.reloadContent()
        
        let newIdentifier = self.storage.allContent.identifier
        let identifierChanged = oldIdentifier != newIdentifier
        
        self.storage.presentationState.context = self.storage.allContent.context
        
        self.updatePresentationState(for: .contentChanged(animated: animated, identifierChanged: identifierChanged))
    }
    
    //
    // MARK: UIView
    //
    
    @available(*, unavailable, message: "sizeThatFits does not re-measure the size of the list. Use ListView.contentSize(in:for:) instead.")
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
    }
    
    @available(*, unavailable, message: "intrinsicContentSize does not re-measure the size of the list. Use ListView.contentSize(in:for:) instead.")
    public override var intrinsicContentSize: CGSize {
        super.intrinsicContentSize
    }
    
    public override var frame: CGRect {
        didSet {
            self.frameDidChange(from: oldValue, to: self.frame)
        }
    }
    
    public override var bounds: CGRect {
        get { super.bounds }
        
        set {
            let oldValue = self.frame
            
            super.bounds = newValue
            
            self.frameDidChange(from: oldValue, to: self.frame)
        }
    }
    
    private func frameDidChange(from old : CGRect, to new : CGRect) {
        
        /// Set the frame explicitly, so that the layout can occur
        /// within performBatchUpdates. Waiting for layoutSubviews() is too late.
        self.collectionView.frame = self.bounds
        
        /// If nothing has changed, there's no work here – return early.
        guard old != new else {
            return
        }
        
        /// Once the view actually has a size, we can provide content.
        ///
        /// There's no value in having content with no view size, as we cannot size cells otherwise.
        let fromEmpty = old.size.isEmpty && new.size.isEmpty == false
        let toEmpty = old.size.isEmpty == false && new.size.isEmpty
        
        if fromEmpty {
            self.updatePresentationState(for: .transitionedToBounds(isEmpty: false))
        } else if toEmpty {
            self.updatePresentationState(for: .transitionedToBounds(isEmpty: true))
        }
        
        /// Our frame changed, update the keyboard inset in case the inset should now be different.
        self.updateScrollViewInsets()
        
        ListStateObserver.perform(self.stateObserver.onFrameChanged, "Frame Changed", with: self) { actions in
            ListStateObserver.FrameChanged(
                actions: actions,
                positionInfo: self.scrollPositionInfo,
                old: old,
                new: new
            )
        }
    }
    
    public override var backgroundColor: UIColor? {
        didSet {
            self.collectionView.backgroundColor = self.backgroundColor
        }
    }
    
    public override func didMoveToWindow()
    {
        super.didMoveToWindow()
        
        if self.window != nil {
            self.updateScrollViewInsets()
        }
    }
    
    public override func didMoveToSuperview()
    {
        super.didMoveToSuperview()
        
        if self.superview != nil {
            self.updateScrollViewInsets()
        }
    }
    
    override public func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.collectionView.frame = self.bounds
        
        /// Our layout changed, update the keyboard inset in case the inset should now be different.
        self.updateScrollViewInsets()
    }
    
    //
    // MARK: Internal – First Responder Tracking
    //
    
    @objc private func textDidBeginEditingNotification(_ notification : Notification) {
        
        guard let field = notification.object as? UIView else {
            return
        }
        
        if let containingSupplementaryView = field.firstSuperview(ofType: SupplementaryContainerView.self) {
            containingSupplementaryView.headerFooter?.containsFirstResponder = true
        }
    }
    
    @objc private func textDidEndEditingNotification(_ notification : Notification) {
                
        guard let field = notification.object as? UIView else {
            return
        }
        
        if let containingSupplementaryView = field.firstSuperview(ofType: SupplementaryContainerView.self) {
            containingSupplementaryView.headerFooter?.containsFirstResponder = false
        }
    }
    
    //
    // MARK: Internal – Swipe To Delete
    //
    
    private let closeActiveSwipesGesture : TouchDownGestureRecognizer
    
    @objc private func shouldRecognizeCloseSwipeTouch(_ touch : UITouch) -> Bool {
        
        guard let cell = self.liveCells.activeSwipeCell else { return false }
        
        // If the user is touching down anywhere in the `activeSwipeCell` the `activeSwipeCell` will handle it.
        return cell.contains(touch: touch) == false
    }
    
    @objc private func closeActiveSwipeGestureIfNeeded(with recognizer : UIGestureRecognizer) {
        
        guard let cell = self.liveCells.activeSwipeCell else { return }
        
        cell.closeSwipeActions()
    }
    
    //
    // MARK: Internal - Updating Content
    //
    
    internal func setPresentationStateItemPositions()
    {        
        self.storage.presentationState.forEachItem { indexPath, item in
            item.itemPosition = self.collectionViewLayout.positionForItem(at: indexPath)
        }
    }
    
    private func updateCollectionViewSelections(animated : Bool)
    {
        let oldSelected : Set<IndexPath> = Set(self.collectionView.indexPathsForSelectedItems ?? [])
        let newSelected : Set<IndexPath> = Set(self.storage.presentationState.selectedIndexPaths)
        
        let removed = oldSelected.subtracting(newSelected)
        let added = newSelected.subtracting(oldSelected)
        
        let view = self.collectionView
        let state = self.storage.presentationState
        
        removed.forEach {
            let item = state.item(at: $0)
            view.deselectItem(at: $0, animated: animated)
            item.applyToVisibleCell(with: self.environment)
        }
        
        added.forEach {
            let item = state.item(at: $0)
            view.selectItem(at: $0, animated: animated, scrollPosition: [])
            item.applyToVisibleCell(with: self.environment)
        }
    }
    
    //
    // MARK: Internal - Updating Presentation State
    //
    
    /// An index path we store in order to ensure if multiple updates are processed in quick succession, we do not
    /// end up overriding a previous attempt to programmatically trigger a scroll event.
    ///
    /// https://github.com/square/Listable/pull/557
    ///
    private var updateOverrideIndexPath : IndexPath? = nil
    
    private var firstVisibleIndexPath : IndexPath? {

        /// 1) Get the first visible index path.

        let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems.sorted(by: <)

        /// 2) Pick the largest index path of two to return.

        return [
            updateOverrideIndexPath,
            visibleIndexPaths.first
        ]
            .compactMap { $0 }
            .sorted(by: >)
            .first
    }

    internal func updatePresentationState(
        for reason : PresentationState.UpdateReason,
        completion callerCompletion : @escaping (Bool) -> () = { _ in }
    ) {
        SignpostLogger.log(.begin, log: .updateContent, name: "List Update", for: self)
        
        let completion = { (completed : Bool) in
            callerCompletion(completed)
            SignpostLogger.log(.end, log: .updateContent, name: "List Update", for: self)
        }
                
        let indexPath = firstVisibleIndexPath
        
        let presentationStateTruncated = self.storage.presentationState.containsAllItems == false
        
        switch reason {
        case .scrolledDown:
            let needsUpdate = self.collectionView.isScrolledNearBottom() && presentationStateTruncated
            
            if needsUpdate {
                self.updatePresentationStateWith(firstVisibleIndexPath: indexPath, for: reason, completion: completion)
            } else {
                completion(true)
            }
            
        case .contentChanged:
            self.updatePresentationStateWith(firstVisibleIndexPath: indexPath, for: reason, completion: completion)

        case .didEndDecelerating:
            if presentationStateTruncated {
                self.updatePresentationStateWith(firstVisibleIndexPath: indexPath, for: reason, completion: completion)
            } else {
                completion(true)
            }
            
        case .scrolledToTop:
            if presentationStateTruncated {
                self.updatePresentationStateWith(firstVisibleIndexPath: IndexPath(item: 0, section: 0), for: reason, completion: completion)
            } else {
                completion(true)
            }
            
        case .transitionedToBounds(_):
            self.updatePresentationStateWith(firstVisibleIndexPath: indexPath, for: reason, completion: completion)
            
        case .programaticScrollDownTo(let scrollToIndexPath):
            
            updateOverrideIndexPath = scrollToIndexPath
            
            self.updatePresentationStateWith(firstVisibleIndexPath: scrollToIndexPath, for: reason, completion: {
                
                /// Verify this is the same as inputted index path – if it's not, that means
                /// _another_ `programaticScrollDownTo` has occurred and thus has
                /// overridden this value, so we shouldn't clear it out.
                if self.updateOverrideIndexPath == scrollToIndexPath {
                    self.updateOverrideIndexPath = nil
                }

                completion($0)
            })
        }
    }
        
    private func updatePresentationStateWith(
        firstVisibleIndexPath indexPath: IndexPath?,
        for reason : PresentationState.UpdateReason,
        completion callerCompletion : @escaping (Bool) -> ()
    ) {
        /// We must put the updates to the collection view and our presentation state into the update queue,
        /// to ensure that the calls to `presentationState.update` is done serially. It seems like some times,
        /// in particular under high load, the call to `UICollectionView.performBatchUpdates` will not
        /// call the update block synchronously, meaning if many updates are queued and submitted at once,
        /// things can get out of sync, and we end up applying an incorrect diff to the presentation state.
        ///
        /// By placing the update within our serial update queue, and only marking the event as done in
        /// `collectionViewUpdateCompletion`, we can guarantee that out of order updates do not occur.
        
        self.updateQueue.add { [weak self] completion in
            
            guard let self = self else {
                completion.finish()
                return
            }
            
            // Figure out visible content.
            
            let presentationState = self.storage.presentationState
            
            let indexPath = indexPath ?? IndexPath(item: 0, section: 0)

            let visibleSlice = self.newVisibleSlice(to: indexPath)

            let diff = SignpostLogger.log(log: .updateContent, name: "Diff Content", for: self) {
                ListView.diffWith(old: presentationState.sectionModels, new: visibleSlice.content.sections)
            }

            let updateCallbacks = UpdateCallbacks(.queue, wantsAnimations: reason.animated)
            
            let updateBackingData = {
                let dependencies = ItemStateDependencies(
                    reorderingDelegate: self,
                    coordinatorDelegate: self,
                    environmentProvider: { [weak self] in self?.environment ?? .empty }
                )
                
                presentationState.update(
                    with: diff,
                    slice: visibleSlice,
                    reason: .wasUpdated,
                    animated: reason.animated,
                    dependencies: dependencies,
                    updateCallbacks: updateCallbacks,
                    loggable: self
                )
            }
                    
            // Update Refresh Control
            
            /**
             Update Refresh Control
             
             Note: Must be called *OUTSIDE* of CollectionView's `performBatchUpdates:`, otherwise
             we trigger a bug where updated indexes are calculated incorrectly.
             */
            presentationState.updateRefreshControl(
                with: visibleSlice.content.refreshControl,
                in: self.collectionView,
                color: self.appearance.refreshControlColor
            )
            
            // Update Collection View
            
            self.performBatchUpdates(
                with: diff,
                animated: reason.animated,
                updateBackingData: updateBackingData,
                collectionViewUpdateCompletion: completion.finish,
                animationCompletion: callerCompletion
            )

            // Update the offset of the scroll view to show the refresh control if needed
            presentationState.adjustContentOffsetForRefreshControl(in: self.collectionView)

            // Perform any needed offset adjustments due to the reason
            self.updateContentOffset(for: reason)

            // Perform any needed auto scroll actions.
            self.performAutoScrollAction(with: diff.changes.addedItemIdentifiers, animated: reason.animated)

            // Update info for new contents.
            
            self.updateCollectionViewSelections(animated: reason.animated)
            
            // Notify updates.
            
            updateCallbacks.perform()
            
            // Notify state reader the content updated.
            
            if case .contentChanged(_, _) = reason {
                ListStateObserver.perform(self.stateObserver.onContentUpdated, "Content Updated", with: self) { actions in
                    ListStateObserver.ContentUpdated(
                        hadChanges: diff.changes.isEmpty == false,
                        insertionsAndRemovals: .init(diff: diff),
                        actions: actions,
                        positionInfo: self.scrollPositionInfo
                    )
                }
            }
        }
    }
    
    private func newVisibleSlice(to indexPath : IndexPath) -> Content.Slice
    {
        if self.bounds.isEmpty {
            return Content.Slice()
        } else {
            switch self.autoScrollAction {
            case .scrollToItem(let insertInfo):
                let itemPath = self.storage.allContent.firstIndexPathForItem(with: insertInfo.insertedIdentifier)
                
                guard let autoScrollIndexPath = itemPath else {
                    fallthrough
                }

                let greaterIndexPath = max(autoScrollIndexPath, indexPath)
                return self.storage.allContent.sliceTo(indexPath: greaterIndexPath)

            case .none, .pin:

                return self.storage.allContent.sliceTo(indexPath: indexPath)
            }
        }
    }

    private func updateContentOffset(for reason: PresentationState.UpdateReason) {
        switch reason {
        case .contentChanged(_, let identifierChanged):
            if identifierChanged {
                let contentOffset = CGPoint(x: 0, y: -collectionView.adjustedContentInset.top)
                collectionView.setContentOffset(contentOffset, animated: false)
            }
        default:
            break
        }
    }

    private func performAutoScrollAction(with addedItems : Set<AnyIdentifier>, animated : Bool)
    {
        switch self.autoScrollAction {
        case .none:
            return
            
        case .scrollToItem(let info):
            let wasInserted = addedItems.contains(info.insertedIdentifier)
            if wasInserted {
                autoScroll(with: info)
            }
        case .pin(let pin):
            autoScroll(with: pin)
        }
        
        func autoScroll(with info: AutoScrollAction.Configuration) {
            if info.shouldPerform(self.scrollPositionInfo) {
                
                /// Only animate the scroll if both the update **and** the scroll action are animated.
                let animated = info.animated && animated
                
                if let destination = info.destination.destination(with: self.content) {
                    
                    if behavior.verticalLayoutGravity == .bottom {
                        /// Temporarily ignore the bottom gravity offest overrides before scrolling. This
                        /// avoids an issue where:
                        ///   - the list has `VerticalLayoutGravity.bottom` and `AutoScrollAction` behaviors
                        ///   - the list has offscreen items that haven't been sized
                        ///   - the `AutoScrollAction` has been triggered
                        ///   - the resulting scroll position will adjust the collection view's `contentSize`
                        ///     as items are dequeued and sized
                        ///
                        /// Without ignoring the custom `VerticalLayoutGravity.bottom` offset behavior, the
                        /// above scenario will force the scroll offset to the bottom, discarding this scroll
                        /// update.
                        collectionView.ignoreBottomGravityOffsetOverride = true
                    }
                    
                    guard self.scrollTo(item: destination, position: info.position, animated: animated) else {
                        collectionView.ignoreBottomGravityOffsetOverride = false
                        return
                    }
                    if animated {
                        stateObserver.onDidEndScrollingAnimation { [weak self] state in
                            self?.collectionView.ignoreBottomGravityOffsetOverride = false
                            info.didPerform(state.positionInfo)
                        }
                    } else {
                        /// Perform an update after an animationless scroll so that `CollectionViewLayout`'s
                        /// `prepare()` function will synchronously execute before calling `didPerform`. Otherwise,
                        /// the list's `visibleContent` and the resulting `scrollPositionInfo.visibleItems` will
                        /// be stale.
                        performEmptyBatchUpdates()
                        collectionView.ignoreBottomGravityOffsetOverride = false
                        info.didPerform(scrollPositionInfo)
                    }
                }
            }
        }
    }

    private func performScroll(
        to targetFrame : CGRect,
        scrollPosition : ScrollPosition,
        animated: Bool = false,
        completion: ScrollCompletion? = nil
    ) {
        // If the item is already visible and that's good enough, return.

        let isAlreadyVisible = collectionView.visibleContentFrame.contains(targetFrame)
        if isAlreadyVisible && scrollPosition.ifAlreadyVisible == .doNothing {
            handleScrollCompletion(reason: .cannotScroll, completion: completion)
            return
        }

        // If user is performing this in a `UIView.performWithoutAnimation` block, respect that and don't animate, regardless of what the animated parameter is.
        let shouldAnimate = animated && UIView.areAnimationsEnabled

        let topInset = collectionView.adjustedContentInset.top
        let contentFrameHeight = collectionView.visibleContentFrame.height
        let adjustedOriginY = targetFrame.origin.y - topInset

        var resultOffset = collectionView.contentOffset

        switch scrollPosition.position {
        case .top:
            resultOffset.y = adjustedOriginY
        case .centered:
            resultOffset.y = adjustedOriginY - (contentFrameHeight / 2 - targetFrame.size.height / 2)
        case .bottom:
            resultOffset.y = adjustedOriginY - (contentFrameHeight - targetFrame.size.height)
        }

        // Don't scroll past the bottom of the list.

        let maxOffsetHeight = collectionViewLayout.collectionViewContentSize.height - contentFrameHeight - topInset
        resultOffset.y = min(resultOffset.y, maxOffsetHeight)

        // Don't scroll beyond the top of the list.

        resultOffset.y = max(resultOffset.y, -topInset)
        
        let roundedResultOffset = CGPoint(
            x: round(resultOffset.x),
            y: round(resultOffset.y)
        )
        let roundedCurrentOffset = CGPoint(
            x: round(collectionView.contentOffset.x),
            y: round(collectionView.contentOffset.y)
        )
        if roundedCurrentOffset != roundedResultOffset {
            collectionView.setContentOffset(resultOffset, animated: shouldAnimate)
            handleScrollCompletion(reason: .scrolled(animated: shouldAnimate), completion: completion)
        } else {
            handleScrollCompletion(reason: .cannotScroll, completion: completion)
        }
    }

    private func preparePresentationStateForScroll(to toIndexPath: IndexPath, handlerWhenFailed: ScrollCompletion?, scroll: @escaping () -> Void) -> Bool {

        // Make sure we have a last loaded index path.

        guard let lastLoadedIndexPath = self.storage.presentationState.lastIndexPath else {
            handleScrollCompletion(reason: .cannotScroll, completion: handlerWhenFailed)
            return false
        }

        // Update presentation state if needed, then scroll.

        if lastLoadedIndexPath < toIndexPath {
            self.updatePresentationState(for: .programaticScrollDownTo(toIndexPath)) { _ in
                scroll()
            }
        } else {
            scroll()
        }

        return true
    }

    private func preparePresentationStateForScrollToSection(index: Int, handlerWhenFailed: ScrollCompletion?, scroll: @escaping () -> Void) -> Bool {

        // Make sure section is contained within all content.

        guard index < storage.allContent.sections.count else {
            handleScrollCompletion(reason: .cannotScroll, completion: handlerWhenFailed)
            return false
        }

        // Update presentation state if needed, then scroll.

        if index >= storage.presentationState.sections.count {
            let toIndexPath = IndexPath(item: 0, section: index)
            self.updatePresentationState(for: .programaticScrollDownTo(toIndexPath)) { _ in
                scroll()
            }
        } else {
            scroll()
        }

        return true
    }
    
    /// This is similar to calling `collectionView.performBatchUpdates(nil)`, but
    /// it also includes workarounds for first responder bugs on iOS 16.4 and 17.0.
    private func performEmptyBatchUpdates() {
        collectionView.performBatchUpdates(
            {},
            changes: CollectionViewChanges.empty,
            completion: { _ in }
        )
    }
    
    private func performBatchUpdates(
        with diff : SectionedDiff<Section, AnyIdentifier, AnyItem, AnyIdentifier>,
        animated: Bool,
        updateBackingData : @escaping () -> (),
        collectionViewUpdateCompletion callerCollectionViewUpdateCompletion : @escaping () -> (),
        animationCompletion callerAnimationCompletion : @escaping (Bool) -> ()
    )
    {
        SignpostLogger.log(.begin, log: .updateContent, name: "Update UICollectionView", for: self)
        
        let animationCompletion = { (completed : Bool) in
            callerAnimationCompletion(completed)
            SignpostLogger.log(.end, log: .updateContent, name: "Update UICollectionView", for: self)
        }
        
        let view = self.collectionView
        
        let changes = CollectionViewChanges(sectionChanges: diff.changes)
            
        let batchUpdates = {
            updateBackingData()
            
            // Sections

            view.deleteSections(IndexSet(changes.deletedSections.map { $0.oldIndex }))
            view.insertSections(IndexSet(changes.insertedSections.map { $0.newIndex }))
            
            changes.movedSections.forEach {
                view.moveSection($0.oldIndex, toSection: $0.newIndex)
            }

            // Items
            
            view.deleteItems(at: changes.deletedItems.map { $0.oldIndex })
            view.insertItems(at: changes.insertedItems.map { $0.newIndex })
            
            changes.movedItems.forEach {
                view.moveItem(at: $0.oldIndex, to: $0.newIndex)
            }
            
            callerCollectionViewUpdateCompletion()
        }
        
        if changes.hasIndexAffectingChanges {
            
            if self.hasInProgressReorders {
                print(
                    """
                    LISTABLE WARNING: Reordering while applying an update diff that has changes which affect index \
                    path stability is currently experimental, and will likely crash. A fix is planned, but this \
                    warning is here so you know what to expect.
                    """
                )
            }
            
            self.cancelAllInProgressReorders()
        }
        
        self.collectionViewLayout.setShouldAskForItemSizesDuringLayoutInvalidation()
        
        let performUpdates = {
            view.performBatchUpdates(
                batchUpdates,
                changes: changes,
                completion: animationCompletion
            )
        }
        
        if animated {
            self.animation.perform(performUpdates)
        } else {
            UIView.performWithoutAnimation(performUpdates)
        }
    }
    
    private static func diffWith(old : [Section], new : [Section]) -> SectionedDiff<Section, AnyIdentifier, AnyItem, AnyIdentifier>
    {
        return SectionedDiff(
            old: old,
            new: new,
            configuration: SectionedDiff.Configuration(
                section: .init(
                    identifier: { $0.identifier },
                    items: { $0.items },
                    movedHint: { $0.identifier != $1.identifier }
                ),
                item: .init(
                    identifier: { $0.anyIdentifier },
                    updated: { $0.anyIsEquivalent(to: $1) == false },
                    movedHint: { $0.anyWasMoved(comparedTo: $1) }
                )
            )
        )
    }
}


public extension ListView
{
    ///
    /// Call this method to force an immediate, synchronous re-render of the list
    /// and its content when writing unit or snapshot tests. This avoids needing to
    /// spin the runloop or needing to use test expectations to wait for content
    /// to be rendered asynchronously.
    ///
    /// **WARNING**: You must **not** call this method outside of tests. Doing so will cause a fatal error.
    ///
    func testing_forceLayoutUpdateNow()
    {
        guard NSClassFromString("XCTestCase") != nil else {
            fatalError("You must not call testing_forceLayoutUpdateNow outside of an XCTest environment.")
        }
        
        self.collectionView.reloadData()
    }
}


@_spi(ListableKeyboard)
extension ListView : KeyboardObserverDelegate
{
    public func keyboardFrameWillChange(for observer: KeyboardObserver, animationDuration: Double, animationCurve: UIView.AnimationCurve) {

        guard let frame = self.keyboardObserver.currentFrame(in: self) else {
            return
        }

        guard self.lastKeyboardFrame != frame else {
            return
        }

        self.lastKeyboardFrame = frame

        if .custom != behavior.keyboardAdjustmentMode {
            UIViewPropertyAnimator(duration: animationDuration, curve: animationCurve) {
                self.updateScrollViewInsets()
            }
            .startAnimation()
        }
        
        self.onKeyboardFrameWillChange?(
            self.keyboardObserver,
            (animationDuration: animationDuration, animationCurve: animationCurve)
        )
    }
}


extension ListView : ItemContentCoordinatorDelegate
{
    func coordinatorUpdated(for : AnyItem)
    {
        self.collectionViewLayout.setNeedsRelayout()
        self.collectionView.layoutIfNeeded()
    }
}


extension ListView : ReorderingActionsDelegate
{
    //
    // MARK: Internal - Moving Items
    //
    
    func beginReorder(for item : AnyPresentationItemState) -> Bool
    {
        guard let indexPath = self.storage.presentationState.indexPath(for: item) else {
            return false
        }
        
        if self.collectionView.beginInteractiveMovementForItem(at: indexPath) {
            item.beginReorder(from: indexPath, with: self.environment)
            
            return true
        } else {
            return false
        }
    }
    
    func updateReorderTargetPosition(
        with recognizer : ItemReordering.GestureRecognizer,
        for item : AnyPresentationItemState
    )
    {
        guard let position = recognizer.reorderPosition(in: self.collectionView) else {
            return
        }
        
        self.collectionView.updateInteractiveMovementTargetPosition(position)
    }
    
    func endReorder(for item : AnyPresentationItemState, with result : ReorderingActions.Result)
    {
        item.endReorder(with: self.environment, result: result)
        
        switch result {
        case .finished:
            self.collectionView.endInteractiveMovement()
        case .cancelled:
            self.collectionView.cancelInteractiveMovement()
        }
    }
    
    func accessibilityMove(item: AnyPresentationItemState, direction: ReorderingActions.AccessibilityMoveDirection) -> Bool {
        guard let indexPath = self.storage.presentationState.indexPath(for: item),
        self.dataSource.collectionView(self.collectionView, canMoveItemAt: indexPath) else {
            return false
        }

        let destinationPath : IndexPath
        switch direction {
        case .up:
            // Moving an item up means decrementing the index.
            if indexPath.row == 0 {
                // First item in section, we should go to the previous section
                if indexPath.section > 0 {
                    let newSection = indexPath.section - 1
                    let rowInNewSection = self.storage.allContent.sections[indexPath.section - 1].count
                    destinationPath = IndexPath(row: rowInNewSection, section:newSection )
                }
                else {
                    // Unable to move up, we are item 0,0.
                    return false
                }
            } else {
                destinationPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            }

        case .down:
            // Moving an item down means incrementing the index.
            if indexPath.row == storage.allContent.sections[indexPath.section].count - 1 {
                // we are the last item our section, lets see if there's another section we can move down to
                if storage.allContent.sections.count - 1 > indexPath.section {
                    destinationPath = IndexPath(row: 0, section: indexPath.section + 1)
                } else {
                    // Unable to move down, we are the last item in the last section.
                    return false
                }
            } else {
                destinationPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            }
        }
        
        let targetPath = self.delegate.collectionView(self.collectionView, targetIndexPathForMoveFromItemAt: indexPath, toProposedIndexPath: destinationPath)
        
        /*  We are responding to a user event, but won't be using the `InteractiveMovement` API the collection view provides as we are being called from an accessibility action rather than a gesture regognizer. This means we'll have to call out to the dataSource directly.
        
            NOTE: It's Important that we call `dataSource.collectionView(_ :, moveItemAt:, to:)` to perform the move in the data source before calling `collectionView.moveItem(at:, to:)` to update the collection view itself.
        */
        
        item.beginReorder(from: indexPath, with: self.environment)
        self.dataSource.collectionView(self.collectionView, moveItemAt: indexPath, to: targetPath)
        self.collectionView.moveItem(at: indexPath, to: targetPath)
        item.endReorder(with: environment, result: .finished)
        
        return true
    }
    
    func cancelAllInProgressReorders() {
        
        self.storage.presentationState.forEachItem { _, item in
            item.endReorder(with: self.environment, result: .cancelled)
        }
        
        self.collectionView.cancelInteractiveMovement()
    }
    
    private var hasInProgressReorders : Bool {
        
        for section in self.storage.presentationState.sections {
            for item in section.items {
                if item.isReordering {
                    return true
                }
            }
        }
        
        return false
    }
}


extension ListView : SignpostLoggable
{
    var signpostInfo : SignpostLoggingInfo {
        SignpostLoggingInfo(
            identifier: self.debuggingIdentifier,
            instanceIdentifier: String(format: "%p", unsafeBitCast(self, to: Int.self))
        )
    }
}


fileprivate extension UIScrollView
{

    func isScrolledNearBottom() -> Bool
    {
        let viewHeight = self.bounds.size.height
        
        // We are within one half view height from the bottom of the content.
        return self.contentOffset.y + (viewHeight * 1.5) > self.contentSize.height
    }
}


final class CollectionView : ListView.IOS16_4_First_Responder_Bug_CollectionView {
    
    var verticalLayoutGravity : Behavior.VerticalLayoutGravity = .top
    var layoutDirection: LayoutDirection = .vertical
    
    /// Normally, using `VerticalLayoutGravity.bottom` will keep the viewport anchored at the bottom.
    /// This happens in overrides of `contentSize`, `contentInset`, and `frame`. When this variable is
    /// `true`, the logic in those overrides is ignored. This can be used to ensure `AutoScrollAction`
    /// has a chance to scroll to the desired item when mixing it with `VerticalLayoutGravity.bottom`.
    var ignoreBottomGravityOffsetOverride: Bool = false

    override var contentSize: CGSize {

        didSet {
            // Normally when the `contentSize` height increases the distance required to
            // scroll to the bottom increases by the height delta. But with bottom gravity enabled
            // we need to keep the scroll distance to the bottom unchanged, which we do by
            // adjusting the `contentOffset`.
            if verticalLayoutGravity == .bottom && !ignoreBottomGravityOffsetOverride {
                guard layoutDirection == .vertical else {
                    assertionFailure("bottom gravity is only supported for vertical layouts")
                    return
                }
                guard oldValue != contentSize else { return }
                guard isContentScrollable else { return }
                
                let heightDelta = contentSize.height - oldValue.height
                guard heightDelta > 0 else { return }
                
                let maxContentOffsetY = contentSize.height - bounds.height + adjustedContentInset.bottom
                let targetY = self.contentOffset.y + heightDelta

                self.contentOffset.y = min(targetY, maxContentOffsetY)
            }
        }
    }
 
    override var contentInset: UIEdgeInsets {
        didSet {
            // When bottom gravity is enabled, we may need to adjust the `contentOffset`
            // when the `contentInset` changes in order to keep the scroll distance to
            // the bottom unchanged.
            if layoutDirection == .vertical && verticalLayoutGravity == .bottom && !ignoreBottomGravityOffsetOverride {
                guard oldValue != contentInset else { return }
                guard isContentScrollable else { return }

                let delta = contentInset.bottom - oldValue.bottom
                if delta < 0 {
                    // we have to reference the previous `contentOffset` value because
                    // UIKit has already changed it.
                    self.contentOffset.y = previousContentOffset.y + delta
                } else {
                    self.contentOffset.y += delta
                }
            }
        }
    }

    private var previousContentOffset: CGPoint = .zero
    override var contentOffset: CGPoint {
        didSet {
            previousContentOffset = oldValue
        }
    }

    /// Returns true when the content size is large enough that scrolling is possible
    /// without bouncing back to it's original position.
    var isContentScrollable: Bool {
        switch layoutDirection {
        case .vertical:
            return contentSize.height > visibleContentFrame.height
        case .horizontal:
            return contentSize.width > visibleContentFrame.width

        }
    }

    override var frame: CGRect {
        get {
            super.frame
        }
        set {
            // With bottom gravity enabled keep the scroll distance to the bottom unchanged
            if layoutDirection == .vertical && verticalLayoutGravity == .bottom && !ignoreBottomGravityOffsetOverride {
                guard newValue != super.frame else {
                    return
                }
                let oldValue = super.frame
                let offsetY = contentOffset.y
                super.frame = newValue
                contentOffset.y = offsetY - (newValue.height - oldValue.height)
            } else {
                super.frame = newValue
            }
        }
    }
}
