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
        self.appearance = appearance
        
        self.behavior = Behavior()
        self.scrollInsets = ScrollInsets(top: nil, bottom:  nil)
        
        self.storage = Storage()
        self.sourcePresenter = SourcePresenter(initial: StaticSource.State(), source: StaticSource())
        
        self.dataSource = DataSource()
        self.delegate = Delegate()
        
        self.layout = ListViewLayout(
            delegate: self.delegate,
            appearance: self.appearance
        )
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        
        self.keyboardObserver = KeyboardObserver()
        
        if #available(iOS 10.0, *) {
            self.collectionView.isPrefetchingEnabled = false
        }
                
        self.collectionView.dataSource = self.dataSource
        self.collectionView.delegate = self.delegate
        
        super.init(frame: frame)
        
        self.storage.presentationState.listView = self
        self.storage.presentationState.collectionView = self.collectionView
        
        self.dataSource.view = self
        self.delegate.view = self
        
        self.keyboardObserver.delegate = self
        
        self.collectionView.frame = self.bounds
        self.addSubview(self.collectionView)
        
        self.applyAppearance()
        self.applyScrollInsets()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    //
    // MARK: Private Properties
    //
    
    private let storage : Storage
    private var sourcePresenter : AnySourcePresenter
    
    private let dataSource : DataSource
    private let delegate : Delegate
    
    private let collectionView : UICollectionView
    private let layout : ListViewLayout
    
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
        self.layout.appearance = self.appearance
        self.backgroundColor = self.appearance.backgroundColor
        
        self.storage.presentationState.resetAllCachedHeights()
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
        self.collectionView.contentInset = self.scrollInsets.insets(
            with: self.collectionView.contentInset,
            layoutDirection: self.appearance.direction
        )
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
        
        guard let lastLoadedIndexPath = self.storage.presentationState.lastIndexPath else {
            return false
        }
        
        // If the item is already visible and that's good enough, return.
        
        let isAlreadyVisible = self.collectionView.indexPathsForVisibleItems.contains(toIndexPath)
        
        if  isAlreadyVisible && position.ifAlreadyVisible == .doNothing {
            return true
        }
        
        // Otherwise, perform scrolling.
        
        let scroll = {
            self.collectionView.scrollToItem(
                at: toIndexPath,
                at: position.position.UICollectionViewScrollPosition,
                animated: animated
            )
        }
        
        if lastLoadedIndexPath < toIndexPath {
            self.updatePresentationState(for: .programaticScrollDownTo(toIndexPath)) { _ in
                scroll()
            }
        } else {
            scroll()
        }
    
        return true
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
            animated: true,
            appearance: self.appearance,
            behavior: self.behavior,
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
        self.scrollInsets = description.scrollInsets
        
        self.setContent(animated: description.animated, description.content)
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
    
    fileprivate func updateVisibleCellPositions()
    {
        let indexPaths = self.collectionView.indexPathsForVisibleItems
        
        let items : [(IndexPath, AnyPresentationItemState)] = indexPaths.map {
            return ($0, self.storage.presentationState.item(at: $0))
        }
        
        for (indexPath, item) in items {
            let cell = self.collectionView.cellForItem(at: indexPath)!
            item.updatePosition(with: cell, in: collectionView, for: indexPath)
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
    
    private func updateVisibleItemsAndSections()
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
    
    private func updatePresentationState(for reason : Content.Slice.UpdateReason, completion : @escaping (Bool) -> () = { _ in })
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
        let indexPath = indexPath ?? IndexPath(item: 0, section: 0)
        
        let visibleSlice = self.bounds.isEmpty ? Content.Slice() : self.storage.allContent.sliceTo(indexPath: indexPath, plus: Content.Slice.defaultSize)
        
        let diff = ListView.diffWith(old: self.storage.presentationState.sectionModels, new: visibleSlice.content.sections)
                
        let updateBackingData = {
            self.storage.presentationState.update(with: diff, slice: visibleSlice)
        }
        
        self.storage.presentationState.updateRefreshControl(with: visibleSlice.content.refreshControl)
        
        self.performBatchUpdates(with: diff, animated: reason.animated, updateBackingData: updateBackingData) { finished in
            self.updateVisibleItemsAndSections()
            callerCompletion(finished)
        }
        
        self.updateCollectionViewSelections(animated: reason.animated)
    }
        
    private func performBatchUpdates(
        with diff : SectionedDiff<Section,AnyItem>,
        animated: Bool,
        updateBackingData : @escaping () -> (),
        completion : @escaping (Bool) -> ()
    )
    {
        let view = self.collectionView
        
        let changes = diff.aggregatedChanges
                
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
            
            // Perform Updates Of Visible Section Headers & Footers
            
            self.visibleSections.forEach {
                $0.section.header?.applyToVisibleView()
                $0.section.footer?.applyToVisibleView()
            }
            
            // Perform Updates Of Visible Items
            
            self.visibleItems.forEach {
                $0.item.applyToVisibleCell()
            }
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
                    updated: { $0.anyWasUpdated(comparedTo: $1) },
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
        
        var inset : CGFloat
        
        switch frame {
        case .notVisible: inset = 0.0
        case .visible(let frame): inset = (self.bounds.size.height - frame.origin.y)
        }
        
        self.collectionView.contentInset.bottom = inset
    }
    
    //
    // MARK: KeyboardObserverDelegate
    //
    
    func keyboardFrameWillChange(observer : KeyboardObserver)
    {
        self.setContentInsetWithKeyboardFrame()
    }
}


fileprivate extension ListView
{
    final class Storage
    {
        var allContent : Content = Content()

        let presentationState : PresentationState = PresentationState()
        
        func moveItem(from : IndexPath, to : IndexPath)
        {
            self.allContent.moveItem(from: from, to: to)
            self.presentationState.moveItem(from: from, to: to)
        }
        
        func remove(item itemToRemove : AnyPresentationItemState) -> IndexPath?
        {
            if let indexPath = self.presentationState.remove(item: itemToRemove) {
                self.allContent.remove(at: indexPath)
                return indexPath
            } else {
                return nil
            }
        }
    }
    
    final class DataSource : NSObject, UICollectionViewDataSource
    {
        unowned var view : ListView!
        
        var presentationState : PresentationState {
            return self.view.storage.presentationState
        }
        
        func numberOfSections(in collectionView: UICollectionView) -> Int
        {
            return self.presentationState.sections.count
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
        {
            let section = self.presentationState.sections[section]
            
            return section.items.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
        {
            let item = self.presentationState.item(at: indexPath)
            
            self.presentationState.registerCell(for: item)
            
            return item.dequeueAndPrepareCollectionViewCell(in: collectionView, for: indexPath)
        }

        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
        {
            switch ListViewLayout.SupplementaryKind(rawValue: kind)! {
            case .listHeader:
                if let header = self.presentationState.header {
                    self.presentationState.registerSupplementaryView(of: kind, for: header)
                    return header.dequeueAndPrepareCollectionReusableView(in: collectionView, of: kind, for: indexPath)
                }
                
            case .listFooter:
                if let footer = self.presentationState.footer {
                    self.presentationState.registerSupplementaryView(of: kind, for: footer)
                    return footer.dequeueAndPrepareCollectionReusableView(in: collectionView, of: kind, for: indexPath)
                }
                
            case .sectionHeader:
                let section = self.presentationState.sections[indexPath.section]

                if let header = section.header {
                    self.presentationState.registerSupplementaryView(of: kind, for: header)
                    return header.dequeueAndPrepareCollectionReusableView(in: collectionView, of: kind, for: indexPath)
                }
                
            case .sectionFooter:
                let section = self.presentationState.sections[indexPath.section]

                if let footer = section.footer {
                    self.presentationState.registerSupplementaryView(of: kind, for: footer)
                    return footer.dequeueAndPrepareCollectionReusableView(in: collectionView, of: kind, for: indexPath)
                }
            }
            
            fatalError()
        }

        func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
        {
            let item = self.presentationState.item(at: indexPath)
            
            return item.anyModel.reordering != nil
        }
        
        func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
        {
            let item = self.presentationState.item(at: destinationIndexPath)
            
            print("Moved item from \(sourceIndexPath) to \(destinationIndexPath)")
            
            self.view.updateVisibleCellPositions()
            
            item.moved(with: Reordering.Result(
                fromSection: self.presentationState.sections[sourceIndexPath.section].model,
                fromIndexPath: sourceIndexPath,
                toSection: self.presentationState.sections[destinationIndexPath.section].model,
                toIndexPath: destinationIndexPath
            ))
        }
    }
    
    final class Delegate : NSObject, UICollectionViewDelegate, ListViewLayoutDelegate
    {
        unowned var view : ListView!
        
        var presentationState : PresentationState {
            return self.view.storage.presentationState
        }
        
        // MARK: UICollectionViewDelegate
        
        func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool
        {
            return true
        }

        func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath)
        {
            let item = self.presentationState.item(at: indexPath)
            
            item.applyToVisibleCell()
        }
        
        func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath)
        {
            let item = self.presentationState.item(at: indexPath)

            item.applyToVisibleCell()
        }

        func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool
        {
            let item = self.presentationState.item(at: indexPath)
            
            return item.anyModel.selection.isSelectable
        }
        
        func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool
        {
            return true
        }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
        {
            let item = self.presentationState.item(at: indexPath)
            
            item.performUserDidSelectItem(isSelected: true)
        }

        func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
        {
            let item = self.presentationState.item(at: indexPath)
            
            item.performUserDidSelectItem(isSelected: false)
        }
        
        private var displayedItems : [ObjectIdentifier:AnyPresentationItemState] = [:]
        
        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
        {
            let item = self.presentationState.item(at: indexPath)
            
            item.willDisplay(cell: cell, in: collectionView, for: indexPath)
            
            self.displayedItems[ObjectIdentifier(cell)] = item
        }
        
        func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
        {
            guard let item = self.displayedItems.removeValue(forKey: ObjectIdentifier(cell)) else {
                return
            }
                        
            item.didEndDisplay()
        }
        
        private var displayedSupplementaryItems : [ObjectIdentifier:AnyPresentationHeaderFooterState] = [:]
        
        func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath)
        {
            let item : AnyPresentationHeaderFooterState = {
                switch ListViewLayout.SupplementaryKind(rawValue: elementKind)! {
                case .listHeader:
                    return self.presentationState.header!
                    
                case .listFooter:
                    return self.presentationState.footer!
                    
                case .sectionHeader:
                    let section = self.presentationState.sections[indexPath.section]
                    return section.header!
                    
                case .sectionFooter:
                    let section = self.presentationState.sections[indexPath.section]
                    return section.footer!
                }
            }()
            
            item.willDisplay(view: view, in: collectionView, for: indexPath)
            
            self.displayedSupplementaryItems[ObjectIdentifier(view)] = item
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            didEndDisplayingSupplementaryView view: UICollectionReusableView,
            forElementOfKind elementKind: String,
            at indexPath: IndexPath
        )
        {
            guard let item = self.displayedSupplementaryItems.removeValue(forKey: ObjectIdentifier(view)) else {
                return
            }
            
            item.didEndDisplay()
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
            toProposedIndexPath proposedIndexPath: IndexPath
            ) -> IndexPath
        {
            let item = self.presentationState.item(at: originalIndexPath)
            
            if originalIndexPath != proposedIndexPath {
                // TODO: Validate
                
                if originalIndexPath.section == proposedIndexPath.section {
                    self.view.storage.moveItem(from: originalIndexPath, to: proposedIndexPath)

                    return proposedIndexPath
                } else {
                    return originalIndexPath
                }
            } else {
                return proposedIndexPath
            }
        }
        
        // MARK: ListViewLayoutDelegate
        
        private let cellMeasurementCache = ReusableViewCache()
        
        func heightForItem(at indexPath : IndexPath, in collectionView : UICollectionView, width : CGFloat, layoutDirection : LayoutDirection) -> CGFloat
        {
            let item = self.presentationState.item(at: indexPath)
            
            return item.height(
                width: width,
                layoutDirection : layoutDirection,
                defaultHeight: self.view.layout.appearance.sizing.itemHeight,
                measurementCache: self.cellMeasurementCache
            )
        }
        
        func layoutForItem(at indexPath : IndexPath, in collectionView : UICollectionView) -> ItemLayout
        {
            let item = self.presentationState.item(at: indexPath)
            
            return item.anyModel.layout
        }
        
        func hasListHeader(in collectionView : UICollectionView) -> Bool
        {
            return self.presentationState.header != nil
        }
        
        func heightForListHeader(in collectionView : UICollectionView, width : CGFloat, layoutDirection : LayoutDirection) -> CGFloat
        {
            let header = self.presentationState.header!
            
            return header.height(
                width: width,
                layoutDirection : layoutDirection,
                defaultHeight: self.view.layout.appearance.sizing.listHeaderHeight,
                measurementCache: self.headerMeasurementCache
            )
        }
        
        func layoutForListHeader(in collectionView : UICollectionView) -> HeaderFooterLayout
        {
            let header = self.presentationState.header!
            
            return header.anyModel.layout
        }
        
        func hasListFooter(in collectionView : UICollectionView) -> Bool
        {
            return self.presentationState.footer != nil
        }
        
        func heightForListFooter(in collectionView : UICollectionView, width : CGFloat, layoutDirection : LayoutDirection) -> CGFloat
        {
            let footer = self.presentationState.footer!
            
            return footer.height(
                width: width,
                layoutDirection: layoutDirection,
                defaultHeight: self.view.layout.appearance.sizing.listFooterHeight,
                measurementCache: self.headerMeasurementCache
            )
        }
        
        func layoutForListFooter(in collectionView : UICollectionView) -> HeaderFooterLayout
        {
            let footer = self.presentationState.footer!
            
            return footer.anyModel.layout
        }
        
        func layoutFor(section sectionIndex : Int, in collectionView : UICollectionView) -> Section.Layout
        {
            let section = self.presentationState.sections[sectionIndex]

            return section.model.layout
        }
        
        func hasHeader(in sectionIndex : Int, in collectionView : UICollectionView) -> Bool
        {
            let section = self.presentationState.sections[sectionIndex]
            
            return section.header != nil
        }
        
        private let headerMeasurementCache = ReusableViewCache()
        
        func heightForHeader(in sectionIndex : Int, in collectionView : UICollectionView, width : CGFloat, layoutDirection : LayoutDirection) -> CGFloat
        {
            let section = self.presentationState.sections[sectionIndex]
            let header = section.header!
            
            return header.height(
                width: width,
                layoutDirection: layoutDirection,
                defaultHeight: self.view.layout.appearance.sizing.sectionHeaderHeight,
                measurementCache: self.headerMeasurementCache
            )
        }
        
        func layoutForHeader(in sectionIndex : Int, in collectionView : UICollectionView) -> HeaderFooterLayout
        {
            let section = self.presentationState.sections[sectionIndex]
            let header = section.header!
            
            return header.anyModel.layout
        }
        
        func hasFooter(in sectionIndex : Int, in collectionView : UICollectionView) -> Bool
        {
            let section = self.presentationState.sections[sectionIndex]
            
            return section.footer != nil
        }
        
        private let footerMeasurementCache = ReusableViewCache()
        
        func heightForFooter(in sectionIndex : Int, in collectionView : UICollectionView, width : CGFloat, layoutDirection : LayoutDirection) -> CGFloat
        {
            let section = self.presentationState.sections[sectionIndex]
            let footer = section.footer!
                        
            return footer.height(
                width: width,
                layoutDirection: layoutDirection,
                defaultHeight: self.view.layout.appearance.sizing.sectionFooterHeight,
                measurementCache: self.headerMeasurementCache
            )
        }
        
        func layoutForFooter(in sectionIndex : Int, in collectionView : UICollectionView) -> HeaderFooterLayout
        {
            let section = self.presentationState.sections[sectionIndex]
            let footer = section.footer!
            
            return footer.anyModel.layout
        }
        
        func columnLayout(for sectionIndex : Int, in collectionView : UICollectionView) -> Section.Columns
        {
            let section = self.presentationState.sections[sectionIndex]
            
            return section.model.columns
        }
        
        // MARK: UIScrollViewDelegate
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
        {
            self.view.updatePresentationState(for: .didEndDecelerating)
        }
        
        func scrollViewDidScrollToTop(_ scrollView: UIScrollView)
        {
            self.view.updatePresentationState(for: .scrolledToTop)
        }
        
        private var lastPosition : CGFloat = 0.0
        
        func scrollViewDidScroll(_ scrollView: UIScrollView)
        {
            guard scrollView.bounds.size.height > 0 else { return }
            
            // Updating Paged Content
            
            let scrollingDown = self.lastPosition < scrollView.contentOffset.y
            
            self.lastPosition = scrollView.contentOffset.y
            
            if scrollingDown {
                self.view.updatePresentationState(for: .scrolledDown)
            }
            
            // Update Item Visibility
            
            self.view.updateVisibleItemsAndSections()
            
            // Dismiss Keyboard
            
            if self.view.behavior.dismissesKeyboardOnScroll {
                self.view.endEditing(true)
            }
        }
    }
}


fileprivate extension UICollectionView
{    
    func isScrolledNearBottom() -> Bool
    {
        let viewHeight = self.bounds.size.height
        
        // We are within one half view height from the bottom of the content.
        return self.contentOffset.y + (viewHeight * 1.5) > self.contentSize.height
    }
}
