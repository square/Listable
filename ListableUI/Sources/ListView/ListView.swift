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
            item.item.anyModel.anyIdentifier
        })
        
        return ListScrollPositionInfo(
            scrollView: self.collectionView,
            visibleItems: visibleItems,
            isFirstItemVisible: self.content.firstItem.map { visibleItems.contains($0.anyIdentifier) } ?? false,
            isLastItemVisible: self.content.lastItem.map { visibleItems.contains($0.anyIdentifier) } ?? false
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
    
    public typealias ScrollCompletion = (Bool) -> ()
    
    ///
    /// Scrolls to the provided item, with the provided positioning.
    /// If the item is contained in the list, true is returned. If it is not, false is returned.
    ///
    @discardableResult
    public func scrollTo(
        item : AnyItem,
        position : ScrollPosition,
        animation: ViewAnimation = .none,
        completion : @escaping ScrollCompletion = { _ in }
    ) -> Bool
    {
        self.scrollTo(
            item: item.anyIdentifier,
            position: position,
            animation: animation,
            completion: completion
        )
    }
    
    private var hasLoggedHorizontalScrollToWarning : Bool = false
    
    private func logHorizontalScrollToWarning() {
        
        guard self.collectionViewLayout.layout.direction == .horizontal else { return }
        
        if self.hasLoggedHorizontalScrollToWarning { return }
        
        self.hasLoggedHorizontalScrollToWarning = true
        
        print(
        """
        Hello! It looks like you are using one of the `scrollTo...` family of APIs.
        
        These have not yet been updated to support `.horizontal` layouts, and thus, will
        likely not work as expected.
        
        Please let us know you're looking for this feature in #listable on Slack.
        """
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
        animation: ViewAnimation = .none,
        completion : @escaping ScrollCompletion = { _ in }
    ) -> Bool
    {
        self.logHorizontalScrollToWarning()
        
        // Make sure the item identifier is valid.

        guard let toIndexPath = self.storage.allContent.firstIndexPathForItem(with: item) else {
            completion(false)
            return false
        }
        
        return self.preparePresentationStateForScroll(to: toIndexPath) {
            
            /// `preparePresentationStateForScroll(to:)` is asynchronous in some
            /// cases, we need to re-query our section index in case it changed or is no longer valid.
            
            guard let toIndexPath = self.storage.allContent.firstIndexPathForItem(with: item) else {
                completion(false)
                return
            }
            
            let itemFrame = self.collectionViewLayout.frameForItem(at: toIndexPath)

            let isAlreadyVisible = self.collectionView.visibleContentFrame.contains(itemFrame)

            // If the item is already visible and that's good enough, return.

            if isAlreadyVisible && position.ifAlreadyVisible == .doNothing {
                return
            }

            let scroll: () -> Void = {
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
                    self.performScroll(to: itemFrameAdjustedForStickyHeaders, scrollPosition: position)

                } else {
                    self.collectionView.scrollToItem(
                        at: toIndexPath,
                        at: position.position.toUICollectionViewScrollPosition(for: self.collectionViewLayout.layout.direction),
                        animated: false
                    )
                }
            }
            
            animation.perform(
                animations: scroll,
                completion: completion
            )
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
        animation: ViewAnimation = .none,
        completion : @escaping ScrollCompletion = { _ in }
    ) -> Bool
    {
        self.logHorizontalScrollToWarning()
        
        let storageContent = storage.allContent

        // Make sure the section identifier is valid.

        guard let sectionIndex = storageContent.firstIndexForSection(with: identifier) else {
            completion(false)
            return false
        }

        return preparePresentationStateForScrollToSection(index: sectionIndex) {
            
            /// `preparePresentationStateForScrollToSection` is asynchronous in some
            /// cases, we need to re-query our section index in case it changed or is no longer valid.
            
            guard let sectionIndex = storageContent.firstIndexForSection(with: identifier) else {
                completion(false)
                return
            }
            
            let layoutContent = self.collectionViewLayout.layout.content

            // Make sure the section has content.

            guard layoutContent.sections[sectionIndex].all.isEmpty == false else {
                completion(false)
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
                    animation: animation,
                    completion: completion
                )
            } else if let adjacentItem = adjacentItem {
                self.scrollTo(
                    item: adjacentItem,
                    position: scrollPosition,
                    animation: animation,
                    completion: completion
                )
            } else {
                self.performScroll(
                    to: fallbackSupplementaryView.defaultFrame,
                    scrollPosition: scrollPosition,
                    animation: animation,
                    completion: completion
                )
            }
        }
    }
    
    /// Scrolls to the very top of the list, which includes displaying the list header.
    @discardableResult
    public func scrollToTop(
        animation: ViewAnimation = .none,
        completion : @escaping ScrollCompletion = { _ in }
    ) -> Bool {
        
        self.logHorizontalScrollToWarning()
        
        // The rect we scroll to must have an area – an empty rect will result in no scrolling.
        let rect = CGRect(origin: .zero, size: CGSize(width: 1.0, height: 1.0))
        
        return self.preparePresentationStateForScroll(to: IndexPath(item: 0, section: 0))  {
            animation.perform(
                animations: {
                    self.collectionView.scrollRectToVisible(rect, animated: false)
                },
                completion: completion
            )
        }
    }

    /// Scrolls to the last item in the list. If the list contains no items, no action is performed.
    @discardableResult
    public func scrollToLastItem(
        animation: ViewAnimation = .none,
        completion : @escaping ScrollCompletion = { _ in }
    ) -> Bool {
        
        self.logHorizontalScrollToWarning()

        // Make sure we have a valid last index path.

        guard let toIndexPath = self.storage.allContent.lastIndexPath() else {
            return false
        }

        // Perform scrolling.

        return self.preparePresentationStateForScroll(to: toIndexPath)  {
            let contentHeight = self.collectionViewLayout.collectionViewContentSize.height
            let contentFrameHeight = self.collectionView.visibleContentFrame.height

            guard contentHeight > contentFrameHeight else {
                return
            }

            let contentOffsetY = contentHeight - contentFrameHeight - self.collectionView.adjustedContentInset.top
            let contentOffset = CGPoint(x: self.collectionView.contentOffset.x, y: contentOffsetY)
            
            animation.perform(
                animations: {
                    self.collectionView.setContentOffset(contentOffset, animated: false)
                },
                completion: completion
            )
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
    
    internal func updatePresentationState(
        for reason : PresentationState.UpdateReason,
        completion callerCompletion : @escaping (Bool) -> () = { _ in }
    ) {
        SignpostLogger.log(.begin, log: .updateContent, name: "List Update", for: self)
        
        let completion = { (completed : Bool) in
            callerCompletion(completed)
            SignpostLogger.log(.end, log: .updateContent, name: "List Update", for: self)
        }
        
        let indexPaths = self.collectionView.indexPathsForVisibleItems
        
        let indexPath = indexPaths.first
        
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
            self.updatePresentationStateWith(firstVisibleIndexPath: scrollToIndexPath, for: reason, completion: completion)
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
    
    private func performAutoScrollAction(with addedItems : Set<AnyIdentifier>, animated : Bool)
    {
        switch self.autoScrollAction {
        case .none:
            return
            
        case .scrollToItem(let info):
            let wasInserted = addedItems.contains(info.insertedIdentifier)
            
            if wasInserted && info.shouldPerform(self.scrollPositionInfo) {
                
                /// Only animate the scroll if both the update **and** the scroll action are animated.
                let animation = info.animation.and(with: animated)
                
                if let destination = info.destination.destination(with: self.content) {
                    self.scrollTo(item: destination, position: info.position, animation: animation) { scrolled in
                        guard scrolled else { return }
                        info.didPerform(self.scrollPositionInfo)
                    }
                }
            }
            
        case .pin(let pin):
            if pin.shouldPerform(self.scrollPositionInfo) {
                /// Only animate the scroll if both the update **and** the scroll action are animated.
                let animation = pin.animation.and(with: animated)
                
                if let destination = pin.destination.destination(with: self.content) {
                    self.scrollTo(item: destination, position: pin.position, animation: animation) { scrolled in
                        guard scrolled else { return }
                        pin.didPerform(self.scrollPositionInfo)
                    }
                }
            }
        }
    }

    private func performScroll(
        to targetFrame : CGRect,
        scrollPosition : ScrollPosition,
        animation: ViewAnimation = .none,
        completion : @escaping ScrollCompletion = { _ in }
    )
    {
        // If the item is already visible and that's good enough, return.

        let isAlreadyVisible = collectionView.visibleContentFrame.contains(targetFrame)
        if isAlreadyVisible && scrollPosition.ifAlreadyVisible == .doNothing {
            return
        }

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

        animation.perform(
            animations: {
                self.collectionView.setContentOffset(resultOffset, animated: false)
            },
            completion: completion
        )
    }

    private func preparePresentationStateForScroll(to toIndexPath: IndexPath, scroll: @escaping () -> Void) -> Bool {

        // Make sure we have a last loaded index path.

        guard let lastLoadedIndexPath = self.storage.presentationState.lastIndexPath else {
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

    private func preparePresentationStateForScrollToSection(index: Int, scroll: @escaping () -> Void) -> Bool {

        // Make sure section is contained within all content.

        guard index < storage.allContent.sections.count else {
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

    override var contentSize: CGSize {

        didSet {
            // Normally when the `contentSize` height increases the distance required to
            // scroll to the bottom increases by the height delta. But with bottom gravity enabled
            // we need to keep the scroll distance to the bottom unchanged, which we do by
            // adjusting the `contentOffset`.
            if verticalLayoutGravity == .bottom {
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
            if layoutDirection == .vertical && verticalLayoutGravity == .bottom {
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
            if layoutDirection == .vertical && verticalLayoutGravity == .bottom {
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
