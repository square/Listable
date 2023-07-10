//
//  PresentationState.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 7/22/19.
//

import UIKit


/// A class used to manage the "live" / mutable state of the visible items in the list,
/// which is persistent across diffs of content (instances are only created or destroyed when an item enters or leaves the list).
final class PresentationState
{
    //
    // MARK: Properties
    //
        
    var refreshControl : RefreshControlState?
    
    var context : ContentContext? {
        didSet {
            guard oldValue != context else { return }
            
            self.resetAllCachedSizes()
        }
    }
    
    let containerHeader : HeaderFooterViewStatePair
    let header : HeaderFooterViewStatePair
    let footer : HeaderFooterViewStatePair
    let overscrollFooter : HeaderFooterViewStatePair
    
    var sections : [PresentationState.SectionState]
    
    var performsContentCallbacks : Bool = true
        
    private(set) var containsAllItems : Bool
    
    private(set) var contentIdentifier : AnyHashable?
    
    private let itemMeasurementCache : ReusableViewCache
    private let headerFooterMeasurementCache : ReusableViewCache
    
    //
    // MARK: Initialization
    //
        
    init()
    {
        self.refreshControl = nil
        
        self.containerHeader = .init(state: nil)
        self.header = .init(state: nil)
        self.footer = .init(state: nil)
        self.overscrollFooter = .init(state: nil)
        
        self.sections = []
        
        self.containsAllItems = true
        
        self.contentIdentifier = nil
        
        self.itemMeasurementCache = ReusableViewCache()
        self.headerFooterMeasurementCache = ReusableViewCache()
    }
    
    init(
        forMeasuringOrTestsWith content : Content,
        environment : ListEnvironment,
        itemMeasurementCache : ReusableViewCache,
        headerFooterMeasurementCache : ReusableViewCache
    ) {
        self.itemMeasurementCache = itemMeasurementCache
        self.headerFooterMeasurementCache = headerFooterMeasurementCache
        
        self.refreshControl = {
            if let refreshControl = content.refreshControl {
                return RefreshControlState(refreshControl)
            } else {
                return nil
            }
        }()
        
        /// Note: We are passing `performsContentCallbacks:false` because this
        /// initializer is only used for one-pass measurement provided by ``ListView/contentSize(in:for:itemLimit:)``,
        /// as well as for testing purposes.
        
        self.containerHeader = .init(state: SectionState.newHeaderFooterState(
            with: content.containerHeader,
            kind: .listContainerHeader,
            performsContentCallbacks: false
        ))
        
        self.header = .init(state: SectionState.newHeaderFooterState(
            with: content.header,
            kind: .listHeader,
            performsContentCallbacks: false
        ))
        
        self.footer = .init(state: SectionState.newHeaderFooterState(
            with: content.footer,
            kind: .listFooter,
            performsContentCallbacks: false
        ))
        
        self.overscrollFooter = .init(state: SectionState.newHeaderFooterState(
            with: content.overscrollFooter,
            kind: .overscrollFooter,
            performsContentCallbacks: false
        ))
        
        self.sections = content.sections.map { section in
            SectionState(
                with: section,
                dependencies: .init(reorderingDelegate: nil, coordinatorDelegate: nil, environmentProvider: { environment }),
                updateCallbacks: .init(.immediate, wantsAnimations: false),
                performsContentCallbacks: false
            )
        }
        
        self.containsAllItems = true
        
        self.contentIdentifier = content.identifier
    }
    
    //
    // MARK: Accessing Data
    //
    
    var sectionModels : [Section] {
        self.sections.map { section in
            var sectionModel = section.model
            
            sectionModel.items = section.items.map {
                $0.anyModel
            }
            
            return sectionModel
        }
    }
    
    var selectedItems : [AnyPresentationItemState] {
        let items : [[AnyPresentationItemState]] = self.sections.compactMap { section in
            section.items.compactMap { item in
                item.isSelected ? item : nil
            }
        }
        
        return items.flatMap { $0 }
    }
    
    var selectedIndexPaths : [IndexPath] {
        let indexes : [[IndexPath]] = self.sections.compactMapWithIndex { sectionIndex, _, section in
            section.items.compactMapWithIndex { itemIndex, _, item in
                item.isSelected ? IndexPath(item: itemIndex, section: sectionIndex) : nil
            }
        }
        
        return indexes.flatMap { $0 }
    }
    
    func headerFooter(of kind : SupplementaryKind, in section : Int) -> HeaderFooterViewStatePair
    {
        switch kind {
        case .listContainerHeader: return self.containerHeader
        case .listHeader: return self.header
        case .listFooter: return self.footer
        case .sectionHeader: return self.sections[section].header
        case .sectionFooter: return self.sections[section].footer
        case .overscrollFooter: return self.overscrollFooter
        }
    }
    
    func item(at indexPath : IndexPath) -> AnyPresentationItemState
    {
        let section = self.sections[indexPath.section]
        let item = section.items[indexPath.item]
        
        return item
    }
    
    func sections(at indexes : [Int]) -> [SectionState]
    {
        var sections : [SectionState] = []
        
        indexes.forEach {
            sections.append(self.sections[$0])
        }
        
        return sections
    }
    
    public var lastIndexPath : IndexPath?
    {
        let nonEmptySections : [(index:Int, section:SectionState)] = self.sections.compactMapWithIndex { index, _, state in
            return state.items.isEmpty ? nil : (index, state)
        }
        
        guard let lastSection = nonEmptySections.last else {
            return nil
        }
        
        return IndexPath(item: (lastSection.section.items.count - 1), section: lastSection.index)
    }
    
    internal func indexPath(for itemToFind : AnyPresentationItemState) -> IndexPath?
    {
        for (sectionIndex, section) in self.sections.enumerated() {
            for (itemIndex, item) in section.items.enumerated() {
                if item === itemToFind {
                    return IndexPath(item: itemIndex, section: sectionIndex)
                }
            }
        }
        
        return nil
    }
    
    internal func forEachItem(_ block : (IndexPath, AnyPresentationItemState) -> ())
    {
        self.sections.forEachWithIndex { sectionIndex, _, section in
            section.items.forEachWithIndex { itemIndex, _, item in
                block(IndexPath(item: itemIndex, section: sectionIndex), item)
            }
        }
    }
    
    //
    // MARK: Mutating Data
    //
    
    func moveItem(from : IndexPath, to : IndexPath)
    {
        guard from != to else {
            return
        }
        
        let item = self.item(at: from)
        
        self.remove(at: from)
        self.insert(item: item, at: to)
    }
    
    @discardableResult
    func remove(at indexPath : IndexPath) -> AnyPresentationItemState
    {
        let section = self.sections[indexPath.section]
        
        return section.removeItem(at: indexPath.item)
    }
    
    func remove(item itemToRemove : AnyPresentationItemState) -> IndexPath?
    {
        guard let indexPath = self.indexPath(for: itemToRemove) else {
            return nil
        }
        
        self.remove(at: indexPath)
        
        return indexPath
    }
    
    func insert(item : AnyPresentationItemState, at indexPath : IndexPath)
    {
        let section = self.sections[indexPath.section]
                
        section.insert(item: item, at: indexPath.item)
    }
    
    //
    // MARK: Height Caching
    //
    
    // Exposed for testing only.
    var onResetCachedSizes : () -> () = {}
    
    func resetAllCachedSizes()
    {
        containerHeader.state?.resetCachedSizes()
        header.state?.resetCachedSizes()
        footer.state?.resetCachedSizes()
        overscrollFooter.state?.resetCachedSizes()
        
        self.sections.forEach { section in
            section.resetAllCachedSizes()
        }
        
        onResetCachedSizes()
    }
    
    //
    // MARK: Updating Content & State
    //
    
    func update(
        with diff : SectionedDiff<Section, AnyIdentifier, AnyItem, AnyIdentifier>,
        slice : Content.Slice,
        reason: ApplyReason,
        animated : Bool,
        dependencies: ItemStateDependencies,
        updateCallbacks : UpdateCallbacks,
        loggable : SignpostLoggable?
    ) {
        SignpostLogger.log(.begin, log: .updateContent, name: "Update Presentation State", for: loggable)
        
        defer {
            SignpostLogger.log(.end, log: .updateContent, name: "Update Presentation State", for: loggable)
        }
        
        self.containsAllItems = slice.containsAllItems
        
        self.contentIdentifier = slice.content.identifier
        
        let environment = dependencies.environmentProvider()
        
        updateOldIndexPaths()
        
        self.containerHeader.update(
            with: SectionState.headerFooterState(
                current: self.containerHeader.state,
                new: slice.content.containerHeader,
                kind: .listContainerHeader,
                performsContentCallbacks: self.performsContentCallbacks
            ),
            new: slice.content.containerHeader,
            reason: reason,
            animated: animated,
            updateCallbacks: updateCallbacks,
            environment: environment
        )
        
        self.header.update(
            with: SectionState.headerFooterState(
                current: self.header.state,
                new: slice.content.header,
                kind: .listHeader,
                performsContentCallbacks: self.performsContentCallbacks
            ),
            new: slice.content.header,
            reason: reason,
            animated: animated,
            updateCallbacks: updateCallbacks,
            environment: environment
        )
        
        self.footer.update(
            with: SectionState.headerFooterState(
                current: self.footer.state,
                new: slice.content.footer,
                kind: .listFooter,
                performsContentCallbacks: self.performsContentCallbacks
            ),
            new: slice.content.footer,
            reason: reason,
            animated: animated,
            updateCallbacks: updateCallbacks,
            environment: environment
        )
        
        self.overscrollFooter.update(
            with: SectionState.headerFooterState(
                current: self.overscrollFooter.state,
                new: slice.content.overscrollFooter,
                kind: .overscrollFooter,
                performsContentCallbacks: self.performsContentCallbacks
            ),
            new: slice.content.overscrollFooter,
            reason: reason,
            animated: animated,
            updateCallbacks: updateCallbacks,
            environment: environment
        )
        
        self.sections = diff.transform(
            input: self.sections,
            removed: { _, section in
                section.wasRemoved(updateCallbacks: updateCallbacks)
            },
            added: { section in
                SectionState(
                    with: section,
                    dependencies: dependencies,
                    updateCallbacks: updateCallbacks,
                    performsContentCallbacks: self.performsContentCallbacks
                )
            },
            moved: { old, new, changes, section in
                section.update(
                    with: old,
                    new: new,
                    changes: changes,
                    reason: reason,
                    animated: animated,
                    dependencies: dependencies,
                    updateCallbacks: updateCallbacks
                )
            },
            noChange: { old, new, changes, section in
                section.update(
                    with: old,
                    new: new,
                    changes: changes,
                    reason: reason,
                    animated: animated,
                    dependencies: dependencies,
                    updateCallbacks: updateCallbacks
                )
            },
            mappedItemCount: \.items.count,
            sectionItemCount: \.items.count
        )
    }
    
    private func updateOldIndexPaths() {
        
        self.containerHeader.updateOldIndexPath(in: 0)
        self.header.updateOldIndexPath(in: 0)
        self.footer.updateOldIndexPath(in: 0)
        self.overscrollFooter.updateOldIndexPath(in: 0)
        
        for (index, section) in sections.enumerated() {
            section.updateOldIndexPath(in: index)
        }
    }
    
    internal func updateRefreshControl(with new : RefreshControl?, in view : UIScrollView, color : UIColor?)
    {
        if let existing = self.refreshControl, let new = new {
            existing.update(with: new, color: color)
        } else if self.refreshControl == nil, let new = new {
            let newControl = RefreshControlState(new)
            view.refreshControl = newControl.view
            self.refreshControl = newControl
            newControl.update(with: new, color: color)
        } else if self.refreshControl != nil, new == nil {
            view.refreshControl = nil
            self.refreshControl = nil
        }
    }

    internal func adjustContentOffsetForRefreshControl(in view : UIScrollView)
    {
        guard let control = refreshControl, control.model.isRefreshing else {
            return
        }

        switch control.model.offsetAdjustmentBehavior {
        case .displayWhenRefreshing(let animate, let scrollToTop):
            // If we are not scrolled to the top or don't enable scroll to top, don't do anything
            guard view.isScrolledToTop || scrollToTop else {
                return
            }

            let contentOffset = CGPoint(x: 0, y: -view.adjustedContentInset.top)
            view.setContentOffset(contentOffset, animated: animate)

        case .none:
            return
        }
    }
    
    //
    // MARK: Cell & Supplementary View Registration
    //
    
    private var registeredCellObjectIdentifiers : Set<ObjectIdentifier> = Set()
    
    func registerCell(for item : AnyPresentationItemState, in view : UICollectionView)
    {
        let info = item.cellRegistrationInfo
        
        let identifier = ObjectIdentifier(info.class)
        
        guard self.registeredCellObjectIdentifiers.contains(identifier) == false else {
            return
        }
        
        self.registeredCellObjectIdentifiers.insert(identifier)
        
        view.register(info.class, forCellWithReuseIdentifier: info.reuseIdentifier)
    }
}


extension PresentationState
{    
    enum UpdateReason : Equatable
    {
        case scrolledDown
        case didEndDecelerating
        
        case scrolledToTop
        
        case contentChanged(animated : Bool, identifierChanged : Bool)
        
        case transitionedToBounds(isEmpty : Bool)
        
        case programaticScrollDownTo(IndexPath)
    
        var animated : Bool {
            switch self {
            case .scrolledDown: return false
            case .didEndDecelerating: return false
            case .scrolledToTop: return false
                
            case .contentChanged(let animated, let identifierChanged): return animated && identifierChanged == false
                
            case .transitionedToBounds(_): return false
                
            case .programaticScrollDownTo(_): return false
            }
        }
    }
}


extension PresentationState
{
    struct SizeKey : Hashable
    {
        var width : CGFloat
        var height : CGFloat
        var layoutDirection : LayoutDirection
        var sizing : Sizing
    }
}


extension PresentationState
{
    func toListLayoutContent(
        defaults: ListLayoutDefaults,
        environment : ListEnvironment
    ) -> ListLayoutContent
    {
        ListLayoutContent(
            containerHeader: {
                guard let header = self.containerHeader.state else { return nil }
                
                return .init(
                    state: header,
                    kind: .listContainerHeader,
                    isPopulated: true,
                    measurer: { info in
                        header.size(for: info, cache: self.headerFooterMeasurementCache, environment: environment)
                    }
                )
            }(),
            header: {
                guard let header = self.header.state else { return nil }
                
                return .init(
                    state: header,
                    kind: .listHeader,
                    isPopulated: true,
                    measurer: { info in
                        header.size(for: info, cache: self.headerFooterMeasurementCache, environment: environment)
                    }
                )
            }(),
            footer: {
                guard let footer = self.footer.state else { return nil }
                
                return .init(
                    state: footer,
                    kind: .listFooter,
                    isPopulated: true,
                    measurer: { info in
                        footer.size(for: info, cache: self.headerFooterMeasurementCache, environment: environment)
                    }
                )
            }(),
            overscrollFooter: {
                guard let footer = self.overscrollFooter.state else { return nil }
                
                return .init(
                    state: footer,
                    kind: .overscrollFooter,
                    isPopulated: true,
                    measurer: { info in
                        footer.size(for: info, cache: self.headerFooterMeasurementCache, environment: environment)
                    }
                )
            }(),
            sections: self.sections.mapWithIndex { sectionIndex, _, section in
                .init(
                    state: section,
                    header: {
                        guard let header = section.header.state else { return nil }
                        
                        return .init(
                            state: header,
                            kind: .sectionHeader,
                            isPopulated: true,
                            measurer: { info in
                                header.size(for: info, cache: self.headerFooterMeasurementCache, environment: environment)
                            }
                        )
                    }(),
                    footer: {
                        guard let footer = section.footer.state else { return nil }
                        
                        return .init(
                            state: footer,
                            kind: .sectionFooter,
                            isPopulated: true,
                            measurer: { info in
                                footer.size(for: info, cache: self.headerFooterMeasurementCache, environment: environment)
                            }
                        )
                    }(),
                    items: section.items.mapWithIndex { itemIndex, _, item in
                        .init(
                            state: item,
                            indexPath: IndexPath(item: itemIndex, section: sectionIndex),
                            insertAndRemoveAnimations: item.anyModel.insertAndRemoveAnimations ?? defaults.itemInsertAndRemoveAnimations,
                            measurer: { info in
                                item.size(for: info, cache: self.itemMeasurementCache, environment: environment)
                            }
                        )
                    }
                )
            }
        )
    }
}

fileprivate extension UIScrollView
{
    var isScrolledToTop: Bool
    {
        // adjustedContentInset includes the refresh control height, subtract that to
        // get the top point at rest
        var topInset = adjustedContentInset.top
        if let refreshControl = self.refreshControl {
            topInset -= refreshControl.frame.height
        }

        return contentOffset.y <= -topInset
    }
}
