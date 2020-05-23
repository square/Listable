//
//  PresentationState.ItemState.swift
//  Listable
//
//  Created by Kyle Van Essen on 5/22/20.
//

import Foundation


protocol AnyPresentationItemState : AnyObject
{
    var isDisplayed : Bool { get }
    func setAndPerform(isDisplayed: Bool)
    
    var itemPosition : ItemPosition { get set }
    
    var anyModel : AnyItem { get }
    
    var reorderingActions : ReorderingActions { get }
    
    var cellRegistrationInfo : (class:AnyClass, reuseIdentifier:String) { get }
    
    func dequeueAndPrepareCollectionViewCell(in collectionView : UICollectionView, for indexPath : IndexPath) -> UICollectionViewCell
    
    func applyTo(cell anyCell : UICollectionViewCell, itemState : Listable.ItemState, reason : ApplyReason)
    func applyToVisibleCell()
        
    func setNew(item anyItem : AnyItem, reason : PresentationState.ItemUpdateReason)
    
    func willDisplay(cell : UICollectionViewCell, in collectionView : UICollectionView, for indexPath : IndexPath)
    func didEndDisplay()
    
    func wasRemoved()
    
    var isSelected : Bool { get }
    func performUserDidSelectItem(isSelected: Bool)
    
    func resetCachedSizes()
    func size(in sizeConstraint : CGSize, layoutDirection : LayoutDirection, defaultSize : CGSize, measurementCache : ReusableViewCache) -> CGSize
    
    func moved(with result : Reordering.Result)
}


protocol ItemElementCoordinatorDelegate : AnyObject
{
    func coordinatorUpdated(for item : AnyItem)
}


public struct ItemStateDependencies
{
    internal var reorderingDelegate : ReorderingActionsDelegate
    internal var coordinatorDelegate : ItemElementCoordinatorDelegate
}


extension PresentationState
{
    enum ItemUpdateReason : CaseIterable
    {
        case move
        case updateFromList
        case updateFromItemCoordinator
        case noChange
    }
    
    final class ItemState<Element:ItemElement> : AnyPresentationItemState
    {
        var model : Item<Element> {
            self.storage.model
        }
        
        private(set) var coordination : Coordination
        
        struct Coordination {
            var coordinator : Element.Coordinator
            
            let actions : ItemElementCoordinatorActions<Element>
            let info : ItemElementCoordinatorInfo<Element>
        }
        
        let reorderingActions: ReorderingActions
        
        var itemPosition : ItemPosition
        
        let storage : Storage
                
        init(with model : Item<Element>, dependencies : ItemStateDependencies)
        {
            self.reorderingActions = ReorderingActions()
            self.itemPosition = .single
        
            self.cellRegistrationInfo = (ItemElementCell<Element>.self, model.reuseIdentifier.stringValue)
                        
            let storage = Storage(model)
            self.storage = storage
                        
            let actions = ItemElementCoordinatorActions(
                current: { storage.model },
                update: {
                    
                    /// This is a temporary update callback, in case the initialization of the
                    /// coordinator causes an update to the item itself.
                    
                    storage.model = $0
                }
            )

            let info = ItemElementCoordinatorInfo(
                original: storage.model,
                current: { storage.model }
            )
            
            let coordinator = model.element.makeCoordinator(actions: actions, info: info)
            
            self.coordination = Coordination(
                coordinator: coordinator,
                actions: actions,
                info: info
            )
            
            self.reorderingActions.item = self
            self.reorderingActions.delegate = dependencies.reorderingDelegate
            
            /// Now that the presentation state is entirely configured, set up the final
            /// update callback, which triggers a `setNew` call, alongside informing the
            /// `listView` that changes have occurred.
            
            weak var coordinatorDelegate = dependencies.coordinatorDelegate
            
            self.coordination.actions.updateCallback = { [weak coordinatorDelegate, weak self] new in
                guard let self = self, let delegate = coordinatorDelegate else {
                    return
                }
                
                self.setNew(item: new, reason: .updateFromItemCoordinator)
                
                delegate.coordinatorUpdated(for: self.anyModel)
                
                self.applyToVisibleCell()
            }
            
            self.storage.didSetState = { [weak self] old, new in
                self?.stateWasUpdated(old: old, new: new)
            }
            
            self.coordination.coordinator.wasCreated()
        }
        
        // MARK: AnyPresentationItemState
        
        private(set) var isDisplayed : Bool = false
        
        func setAndPerform(isDisplayed: Bool) {
            guard self.isDisplayed != isDisplayed else {
                return
            }
            
            self.isDisplayed = isDisplayed
            
            if self.isDisplayed {
                self.model.onDisplay?(self.model.element)
            } else {
                self.model.onEndDisplay?(self.model.element)
            }
        }
                
        var anyModel : AnyItem {
            return self.model
        }
        
        var cellRegistrationInfo : (class:AnyClass, reuseIdentifier:String)
        
        func dequeueAndPrepareCollectionViewCell(in collectionView : UICollectionView, for indexPath : IndexPath) -> UICollectionViewCell
        {
            let anyCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellRegistrationInfo.reuseIdentifier, for: indexPath)
            
            let cell = anyCell as! ItemElementCell<Element>
            
            // Theme cell & apply content.
            
            let itemState = Listable.ItemState(cell: cell)
            
            self.applyTo(
                cell: cell,
                itemState: itemState,
                reason: .willDisplay
            )
            
            return cell
        }
        
        func applyTo(cell anyCell : UICollectionViewCell, itemState : Listable.ItemState, reason : ApplyReason)
        {
            let cell = anyCell as! ItemElementCell<Element>
            
            let applyInfo = ApplyItemElementInfo(
                state: itemState,
                position: self.itemPosition,
                reordering: self.reorderingActions
            )
            
            // Apply Model State
            
            self.model.element.apply(
                to: ItemElementViews(content: cell.contentContainer.contentView, background: cell.background, selectedBackground: cell.selectedBackground),
                for: reason,
                with: applyInfo
            )
            
            // Apply Swipe To Action Appearance
            if let actions = self.model.swipeActions {
                cell.contentContainer.registerSwipeActionsIfNeeded(actions: actions, reason: reason)
            } else {
                cell.contentContainer.deregisterSwipeIfNeeded()
            }
        }
        
        func applyToVisibleCell()
        {
            guard let cell = self.storage.state.visibleCell else {
                return
            }
            
            self.applyTo(
                cell: cell,
                itemState: .init(cell: cell),
                reason: .wasUpdated
            )
        }
        
        func setNew(item anyItem: AnyItem, reason: ItemUpdateReason)
        {
            let old = self.model
            let new = anyItem as! Item<Element>
            
            self.storage.model = new
            self.storage.state.isSelected = new.selectionStyle.isSelected
            
            if reason == .updateFromList || reason == .move {
                self.coordination.info.original = new
                self.coordination.coordinator.wasUpdated(old: old, new: new)
            }
            
            if reason != .noChange {
                self.resetCachedSizes()
            }
        }
        
        func willDisplay(cell anyCell : UICollectionViewCell, in collectionView : UICollectionView, for indexPath : IndexPath)
        {
            let cell = (anyCell as! ItemElementCell<Element>)
            
            self.storage.state.visibleCell = cell
        }
        
        func didEndDisplay()
        {
            self.storage.state.visibleCell = nil
        }
        
        func wasRemoved()
        {
            self.coordination.coordinator.wasRemoved()
        }
        
        var isSelected: Bool {
            self.storage.state.isSelected
        }
                
        func performUserDidSelectItem(isSelected: Bool)
        {
            self.storage.state.isSelected = isSelected
            
            if isSelected {
                self.model.onSelect?(self.model.element)
            } else {
                self.model.onDeselect?(self.model.element)
            }
            
            self.applyToVisibleCell()
        }
        
        func stateWasUpdated(old : State, new : State)
        {
            let coordinator = self.coordination.coordinator
            
            if old.isSelected != new.isSelected {
                if new.isSelected {
                    coordinator.wasSelected()
                } else {
                    coordinator.wasDeselected()
                }
            }
            
            if old.visibleCell != new.visibleCell {
                if let cell = new.visibleCell {
                    let contentView = cell.contentContainer.contentView
                    
                    coordinator.view = contentView
                    coordinator.willDisplay(with: contentView)
                } else {
                    if let view = old.visibleCell?.contentContainer.contentView {
                        coordinator.didEndDisplay(with: view)
                    }
                }
            }
        }
        
        private var cachedSizes : [SizeKey:CGSize] = [:]
        
        func resetCachedSizes()
        {
            self.cachedSizes.removeAll()
        }
        
        func size(in sizeConstraint : CGSize, layoutDirection : LayoutDirection, defaultSize : CGSize, measurementCache : ReusableViewCache) -> CGSize
        {
            guard sizeConstraint.isEmpty == false else {
                return .zero
            }
            
            let key = SizeKey(
                width: sizeConstraint.width,
                height: sizeConstraint.height,
                layoutDirection: layoutDirection,
                sizing: self.model.sizing
            )
            
            if let size = self.cachedSizes[key] {
                return size
            } else {
                SignpostLogger.log(.begin, log: .updateContent, name: "Measure ItemElement", for: self.model)
                
                let size : CGSize = measurementCache.use(
                    with: self.model.reuseIdentifier,
                    create: {
                        return ItemElementCell<Element>()
                }, { cell in
                    let itemState = Listable.ItemState(isSelected: false, isHighlighted: false)
                    
                    self.applyTo(cell: cell, itemState: itemState, reason: .willDisplay)
                    
                    return self.model.sizing.measure(with: cell, in: sizeConstraint, layoutDirection: layoutDirection, defaultSize: defaultSize)
                })
                
                self.cachedSizes[key] = size
                
                SignpostLogger.log(.end, log: .updateContent, name: "Measure ItemElement", for: self.model)
                
                return size
            }
        }
        
        func moved(with result : Reordering.Result)
        {
            self.model.reordering?.didReorder(result)
        }
    }
}


extension PresentationState.ItemState
{
    final class Storage {
        
        var didSetState : (State, State) -> () = { _, _ in }
        
        var model : Item<Element> {
            willSet {
                guard self.model.identifier == newValue.identifier else {
                    fatalError("Cannot change the identifier of an item while updating it. Changed from '\(self.model.identifier)' to '\(newValue.identifier)'.")
                }
            }
        }
        
        var state : State {
            didSet {
                self.didSetState(oldValue, self.state)
            }
        }
        
        init(_ model : Item<Element>)
        {
            self.model = model
            
            self.state = State(isSelected: self.model.selectionStyle.isSelected, visibleCell: nil)
        }
    }
    
    internal struct State {
        var isSelected : Bool
        var visibleCell : ItemElementCell<Element>?
    }
}
