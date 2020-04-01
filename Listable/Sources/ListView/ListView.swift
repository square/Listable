//
//  ListView.swift
//  Listable
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
        
        self.appearance = appearance
        
        self.behavior = Behavior()
        self.autoScrollAction = .none
        self.scrollInsets = ScrollInsets(top: nil, bottom:  nil)
        
        self.storage = Storage()
        self.sourcePresenter = SourcePresenter(initial: StaticSource.State(), source: StaticSource())
        
        self.dataSource = DataSource()
        self.delegate = Delegate()
        
        self.layout = ListViewLayout(
            delegate: self.delegate,
            appearance: self.appearance
        )
        
        self.collectionView = UICollectionView(frame: CGRect(origin: .zero, size: frame.size), collectionViewLayout: self.layout)
        
        self.keyboardObserver = KeyboardObserver()
        
        self.collectionView.isPrefetchingEnabled = false
                
        self.collectionView.dataSource = self.dataSource
        self.collectionView.delegate = self.delegate
        
        // Super init.
        
        super.init(frame: frame)
        
        // Associate ourselves with our child objects.
        
        self.storage.presentationState.view = self
        
        self.dataSource.presentationState = self.storage.presentationState
        
        self.delegate.view = self
        self.delegate.presentationState = self.storage.presentationState
        
        self.keyboardObserver.delegate = self
        
        // Register supplementary views.
        
        ListViewLayout.SupplementaryKind.allCases.forEach {
            SupplementaryContainerView.register(in: self.collectionView, for: $0.rawValue)
        }
        
        // Size and update views.
        
        self.collectionView.frame = self.bounds
        self.addSubview(self.collectionView)
        
        self.applyAppearance()
        self.applyScrollInsets()
    }
    
    deinit
    {
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
    required init?(coder: NSCoder) { listableFatal() }
    
    //
    // MARK: Internal Properties
    //
    
    internal let storage : Storage
    internal let collectionView : UICollectionView
    internal let layout : ListViewLayout
    
    //
    // MARK: Private Properties
    //
    
    private var sourcePresenter : AnySourcePresenter
    
    private let dataSource : DataSource
    private let delegate : Delegate
    
    private let keyboardObserver : KeyboardObserver
    
    //
    // MARK: Appearance
    //
    
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
        
        self.layout.appearance = self.appearance
        self.backgroundColor = self.appearance.backgroundColor
        
        // Row Sizing
        
        self.storage.presentationState.resetAllCachedHeights()
        
        // Scroll View Config
        
        self.collectionView.setAlwaysBounce(self.appearance.underflow.alwaysBounce, direction: self.appearance.direction)
    }
    
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
        // Nothing right now.
    }

    public var autoScrollAction : AutoScrollAction
    
    public var scrollInsets : ScrollInsets {
        didSet {
            guard oldValue != self.scrollInsets else {
                return
            }
            
            self.applyScrollInsets()
        }
    }
    
    func applyScrollInsets()
    {
        let insets = self.scrollInsets.insets(
            with: self.collectionView.contentInset,
            layoutDirection: self.appearance.direction
        )

        self.collectionView.contentInset = insets
        self.collectionView.scrollIndicatorInsets = insets
    }
    
    //
    // MARK: Scrolling To Sections & Items
    //
    
    @discardableResult
    public func scrollTo(item : AnyItem, position : ItemScrollPosition, animated : Bool = false) -> Bool
    {
        return self.scrollTo(item: item.identifier, position: position, animated: animated)
    }
    
    @discardableResult
    public func scrollTo<Element:ItemElement>(item : Identifier<Element>, position : ItemScrollPosition, animated : Bool = false) -> Bool
    {
        return self.scrollTo(item: AnyIdentifier(item), position: position, animated: animated)
    }
    
    @discardableResult
    public func scrollTo(item : AnyIdentifier, position : ItemScrollPosition, animated : Bool = false) -> Bool
    {
        // Make sure the item identifier is valid.
        
        guard let toIndexPath = self.storage.allContent.indexPath(for: item) else {
            return false
        }

        // Check if the item is visible using its frame, since `visibleIndexPaths` includes items outside of the actual content frame.
        
        let isAlreadyVisible: Bool = {
            guard let frame = self.layout.layoutAttributesForItem(at: toIndexPath)?.frame else {
                return false
            }

            return self.collectionView.contentFrame.contains(frame)
        }()

        // If the item is already visible and that's good enough, return.

        if isAlreadyVisible && position.ifAlreadyVisible == .doNothing {
            return true
        }
        
        // Otherwise, perform scrolling.
        
        return self.updatePresentationStateForScroll(toIndexPath: toIndexPath) {
            self.collectionView.scrollToItem(
                at: toIndexPath,
                at: position.position.UICollectionViewScrollPosition,
                animated: animated
            )
        }
    }

    @discardableResult
    public func scrollToBottom(animated : Bool = false) -> Bool {

        // Make sure we have a valid last index path.

        guard let toIndexPath = self.storage.allContent.lastIndexPath() else {
            return false
        }

        // Perform scrolling.

        return self.updatePresentationStateForScroll(toIndexPath: toIndexPath)  {
            let contentHeight = self.layout.collectionViewContentSize.height
            let contentFrameHeight = self.collectionView.contentFrame.height

            guard contentHeight > contentFrameHeight else {
                return
            }

            let contentOffsetY = contentHeight - contentFrameHeight -
                self.collectionView.lst_adjustedContentInset.top
            let contentOffset = CGPoint(x: self.collectionView.contentOffset.x, y: contentOffsetY)
            self.collectionView.setContentOffset(contentOffset, animated: animated)
        }
    }
    
    //
    // MARK: Setting & Getting Content
    //
    
    public var content : Content {
        get { return self.storage.allContent }
        set { self.setContent(animated: false, newValue) }
    }
    
    public func setContent(with builder : ListDescription.Build)
    {
        let description = ListDescription(
            animatesChanges: true,
            appearance: self.appearance,
            behavior: self.behavior,
            autoScrollAction: self.autoScrollAction,
            scrollInsets: self.scrollInsets,
            build: builder
        )
        
        self.setProperties(with: description)
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
    
    public func setProperties(with description : ListDescription)
    {
        self.appearance = description.appearance
        self.behavior = description.behavior
        self.autoScrollAction = description.autoScrollAction
        self.scrollInsets = description.scrollInsets
        
        self.setContent(animated: description.animatesChanges, description.content)
    }
    
    private func setContentFromSource(animated : Bool = false)
    {
        let oldIdentifier = self.storage.allContent.identifier
        self.storage.allContent = self.sourcePresenter.reloadContent()
        let newIdentifier = self.storage.allContent.identifier
        
        let identifierChanged = oldIdentifier != newIdentifier
        
        self.updatePresentationState(for: .contentChanged(animated: animated, identifierChanged: identifierChanged))
    }
    
    // MARK: UIView
    
    public override var frame: CGRect {
        didSet {
            /**
             Set the frame explicitly, so that the layout can occur
             within performBatchUpdates. Waiting for layoutSubviews() is too late.
             */
            self.collectionView.frame = self.bounds
            
            /**
             Once the view actually has a size, we can provide content.
            
             There's no value in having content with no view size, as we cannot
             size cells otherwise.
             */
            
            let fromEmpty = oldValue.isEmpty && self.bounds.isEmpty == false
            let toEmpty = oldValue.isEmpty == false && self.bounds.isEmpty
            
            if fromEmpty {
                self.updatePresentationState(for: .transitionedToBounds(isEmpty: false))
            } else if toEmpty {
                self.updatePresentationState(for: .transitionedToBounds(isEmpty: true))
            }
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
            self.setContentInsetWithKeyboardFrame()
        }
    }
    
    public override func didMoveToSuperview()
    {
        super.didMoveToSuperview()
        
        if self.superview != nil {
            self.setContentInsetWithKeyboardFrame()
        }
    }
    
    override public func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.collectionView.frame = self.bounds
    }
    
    //
    // MARK: Updating Content
    //
    
    internal func setPresentationStateItemPositions()
    {
        self.storage.presentationState.forEachItem { indexPath, item in
            item.itemPosition = self.layout.positionForItem(at: indexPath)
        }
    }
    
    private func updateCollectionViewConfiguration()
    {
        let view = self.collectionView
        
        switch self.content.selectionMode {
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
            item.applyToVisibleCell()
        }
        
        added.forEach {
            let item = state.item(at: $0)
            view.selectItem(at: $0, animated: animated, scrollPosition: [])
            item.applyToVisibleCell()
        }
    }
    
    //
    // MARK: Updating Displayed Items
    //
    
    private struct VisibleSection : Hashable
    {
        let section : PresentationState.SectionState
        
        func hash(into hasher: inout Hasher)
        {
            hasher.combine(ObjectIdentifier(self.section))
        }
        
        static func == (lhs : VisibleSection, rhs : VisibleSection) -> Bool
        {
            return lhs.section === rhs.section
        }
    }
    
    
    private struct VisibleItem : Hashable
    {
        let item : AnyPresentationItemState
        
        func hash(into hasher: inout Hasher)
        {
            hasher.combine(ObjectIdentifier(self.item))
        }
        
        static func == (lhs : VisibleItem, rhs : VisibleItem) -> Bool
        {
            return lhs.item === rhs.item
        }
    }
    
    private var visibleSections : Set<VisibleSection> = Set()
    private var visibleItems : Set<VisibleItem> = Set()
    
    internal func updateVisibleItemsAndSections()
    {
        // Visible Items & Sections
        
        let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems
        
        let newVisibleItems = Set(visibleIndexPaths.map {
            VisibleItem(item: self.storage.presentationState.item(at: $0))
        })
        
        let visibleSectionIndexes : Set<Int> = visibleIndexPaths.reduce(into: Set(), { $0.insert($1.section) })
        let visibleSections = self.storage.presentationState.sections(at: Array(visibleSectionIndexes))
        
        // Message Changes
        
        let removed = self.visibleItems.subtracting(newVisibleItems)
        let added = newVisibleItems.subtracting(self.visibleItems)
        
        removed.forEach {
            $0.item.setAndPerform(isDisplayed: false)
        }
        
        added.forEach {
            $0.item.setAndPerform(isDisplayed: true)
        }
        
        self.visibleItems = newVisibleItems
        self.visibleSections = Set(visibleSections.map { VisibleSection(section: $0)} )
    }
    
    //
    // MARK: Updating Presentation State
    //
    
    internal func updatePresentationState(for reason : Content.Slice.UpdateReason, completion : @escaping (Bool) -> () = { _ in })
    {
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
            self.updateCollectionViewConfiguration()
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
        for reason : Content.Slice.UpdateReason,
        completion callerCompletion : @escaping (Bool) -> ()
        )
    {
        // Figure out visible content.
        
        let presentationState = self.storage.presentationState
        
        let indexPath = indexPath ?? IndexPath(item: 0, section: 0)

        let visibleSlice: Content.Slice

        if self.bounds.isEmpty {
            visibleSlice = Content.Slice()
        } else {
            switch self.autoScrollAction {
            case .none:
                visibleSlice = self.storage.allContent.sliceTo(indexPath: indexPath, plus: Content.Slice.defaultSize)
            case .scrollToItemOnInsert(let autoScrollItem, _):
                let indexPath = self.storage.allContent.indexPath(for: autoScrollItem.identifier) ?? indexPath
                visibleSlice = self.storage.allContent.sliceTo(indexPath: indexPath, plus: Content.Slice.defaultSize)
            }
        }

        let diff = ListView.diffWith(old: presentationState.sectionModels, new: visibleSlice.content.sections)

        let updateBackingData = {
            presentationState.update(with: diff, slice: visibleSlice)
        }
        
        // Update Refresh Control
        
        /**
         Update Refresh Control
         
         Note: Must be called *OUTSIDE* of CollectionView's `performBatchUpdates:`, otherwise
         we trigger a bug where updated indexes are calculated incorrectly.
         */
        presentationState.updateRefreshControl(with: visibleSlice.content.refreshControl)
        
        // Update Collection View
        
        self.performBatchUpdates(with: diff, animated: reason.animated, updateBackingData: updateBackingData) { finished in
            self.updateVisibleItemsAndSections()
            callerCompletion(finished)
        }

        if case let AutoScrollAction.scrollToItemOnInsert(autoScrollItem, autoScrollPosition) = self.autoScrollAction,
            !diff.old.contains(item: autoScrollItem), diff.new.contains(item: autoScrollItem)
        {
            self.scrollTo(item: autoScrollItem, position: autoScrollPosition, animated: true)
        }

        // Update info for new contents.
        
        self.updateCollectionViewSelections(animated: reason.animated)
    }

    private func updatePresentationStateForScroll(toIndexPath: IndexPath, scroll: @escaping () -> Void) -> Bool {

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

    private func performBatchUpdates(
        with diff : SectionedDiff<Section,AnyItem>,
        animated: Bool,
        updateBackingData : @escaping () -> (),
        completion : @escaping (Bool) -> ()
    )
    {
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
            
            self.applyToVisibleViews()
        }
        
        if changes.hasIndexAffectingChanges {
            self.cancelInteractiveMovement()
        }
        
        self.layout.setShouldAskForItemSizesDuringLayoutInvalidation()
        
        if animated {
            view.performBatchUpdates(batchUpdates, completion: completion)
        } else {
            UIView.performWithoutAnimation {
                view.performBatchUpdates(batchUpdates, completion: completion)
            }
        }
    }
    
    private func applyToVisibleViews()
    {
        let presentationState = self.storage.presentationState
        
        // Perform Updates Of Visible Table Headers & Footers

        presentationState.header.applyToVisibleView()
        presentationState.footer.applyToVisibleView()
        presentationState.overscrollFooter.applyToVisibleView()
        
        // Perform Updates Of Visible Section Headers & Footers
        
        self.visibleSections.forEach {
            $0.section.header.applyToVisibleView()
            $0.section.footer.applyToVisibleView()
        }
        
        // Perform Updates Of Visible Items
        
        self.visibleItems.forEach {
            $0.item.applyToVisibleCell()
        }
    }
    
    private static func diffWith(old : [Section], new : [Section]) -> SectionedDiff<Section, AnyItem>
    {
        return SectionedDiff(
            old: old,
            new: new,
            configuration: SectionedDiff.Configuration(
                section: .init(
                    identifier: { $0.info.anyIdentifier },
                    items: { $0.items },
                    movedHint: { $0.info.anyWasMoved(comparedTo: $1.info) }
                ),
                item: .init(
                    identifier: { $0.identifier },
                    updated: { $0.anyIsEquivalent(to: $1) == false },
                    movedHint: { $0.anyWasMoved(comparedTo: $1) }
                )
            )
        )
    }
    
    //
    // MARK: Moving Items
    //
    
    internal func beginInteractiveMovementFor(item : AnyPresentationItemState) -> Bool
    {
        guard let indexPath = self.storage.presentationState.indexPath(for: item) else {
            return false
        }
        
        return self.collectionView.beginInteractiveMovementForItem(at: indexPath)
    }
    
    internal func updateInteractiveMovementTargetPosition(with recognizer : UIPanGestureRecognizer)
    {
        let position = recognizer.location(in: self.collectionView)
        
        self.collectionView.updateInteractiveMovementTargetPosition(position)
    }
    
    internal func endInteractiveMovement()
    {
        self.collectionView.endInteractiveMovement()
    }
    
    private func cancelInteractiveMovement()
    {
        self.collectionView.cancelInteractiveMovement()
    }
}


extension ListView : KeyboardObserverDelegate
{
    private func setContentInsetWithKeyboardFrame()
    {
        guard let frame = self.keyboardObserver.currentFrame(in: self) else {
            return
        }
        
        let inset : CGFloat
        
        switch frame {
        case .notVisible:
            inset = 0.0
        case .visible(let frame):
            if #available(iOS 11, *) {
                inset = (self.bounds.size.height - frame.origin.y) - self.safeAreaInsets.bottom
            } else {
                inset = (self.bounds.size.height - frame.origin.y)
            }
        }
        
        self.collectionView.contentInset.bottom = inset
        self.collectionView.scrollIndicatorInsets.bottom = inset
    }
    
    //
    // MARK: KeyboardObserverDelegate
    //
    
    func keyboardFrameWillChange(observer : KeyboardObserver)
    {
        self.setContentInsetWithKeyboardFrame()
    }
}



fileprivate extension UIScrollView
{

    /// The frame of the collection view inset by the adjusted content inset,
    /// i.e., the visible frame of the content.
    var contentFrame : CGRect {
        return self.bounds.inset(by: self.lst_adjustedContentInset)
    }

    /// `adjustedContentInset` on iOS >= 11, `contentInset` otherwise.
    var lst_adjustedContentInset : UIEdgeInsets {
        if #available(iOS 11, *) {
            return self.adjustedContentInset
        } else {
            return self.contentInset
        }
    }

    func isScrolledNearBottom() -> Bool
    {
        let viewHeight = self.bounds.size.height
        
        // We are within one half view height from the bottom of the content.
        return self.contentOffset.y + (viewHeight * 1.5) > self.contentSize.height
    }
    
    func setAlwaysBounce(_ bounce : Bool, direction : LayoutDirection)
    {
        switch direction {
        case .vertical:
            self.alwaysBounceVertical = bounce
            self.alwaysBounceHorizontal = false
        case .horizontal:
            self.alwaysBounceVertical = false
            self.alwaysBounceHorizontal = bounce
        }
    }
}

private extension Array where Element == Section {
    func contains(item: AnyItem) -> Bool {
        return self.flatMap { $0.items }
            .contains { $0.identifier == item.identifier }
    }
}
