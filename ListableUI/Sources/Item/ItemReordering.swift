//
//  ItemReordering.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 12/14/20.
//

import Foundation


///
/// Provides configuration options to control how an ``Item`` can be reordered within a list.
///
/// To enable reordering on your ``Item``, assign the ``Item/reordering`` property,
/// configured as you need to control where the item can be reordered to.
///
/// In the example below, we set a ``ItemReordering`` config which allows
/// reordering the item within the current section, and when the reorder completes,
/// a controller is called to update the underlying data model.
/// ```swift
/// item.reordering = .init(sections: .current)
///
/// item.onWasReordered = { result in
///     myController.move(from: result.from, to: result.to)
/// }
/// ```
///
/// If you have many items, providing a ``Item/onWasReordered-swift.property`` callback for every item can be tedious.
///
/// In these cases, you can instead provide a ``ListStateObserver/onItemReordered(_:)`` callback,
/// which receives a ``ListStateObserver/ItemReordered`` value:
/// ```swift
/// list.stateObserver.onItemReordered { change in
///     myController.move(from: change.result.from, to: change.result.to)
/// }
/// ```
/// From which you can then read any changes and pass them through to your data model.
///
public struct ItemReordering
{
    // MARK: Controlling Reordering Behavior
    
    /// The sections in which the `Item` can be reordered into.
    public var sections : Sections
    
    public typealias CanReorder = (Result) throws -> Bool
    
    /// A predicate closure which allows more fine-grained validation of a reorder event,
    /// allowing you to control reordering on an index by index basis.
    public var canReorder : CanReorder?
    
    // MARK: Initialization
    
    /// Creates a new `Reorder` instance with the provided options.
    public init(
        sections : Sections,
        canReorder : CanReorder? = nil
    ) {
        self.sections = sections
        self.canReorder = canReorder
    }
}


extension ItemReordering {
    
    /// Controls which sections a reorderable ``Item`` can be moved to during a reorder event.
    public enum Sections : Equatable {
        
        /// The ``Item`` can be moved to any section during a reorder
        case all
        
        /// The ``Item`` can only be moved within the current section during a reorder.
        case current
        
        /// The ``Item`` can only be moved within the specified sections during a reorder.
        /// The values passed should be the value of the ``Section``'s ``Identifier``.
        case specific(current: Bool, IDs: Set<AnyHashable>)
    }
    
    /// Provides information about the current state of a reorder event.
    ///
    /// When used as part of ``canReorder-swift.property``, the state of the sections
    /// and identifiers reflect the current state of the list – the item has not yet been moved.
    ///
    /// When used as part of ``Item/onWasReordered-swift.property``, the state of the sections
    /// and identifiers reflect the state of the list after the move has been committed.
    ///
    public struct Result {
        
        // MARK: Public Properties
        
        /// The index path the ``Item`` is being moved from.
        public var from : IndexPath
        /// The ``Section`` the ``Item`` is being moved from.
        public var fromSection : Section
        
        /// The index path the ``Item`` is being moved to.
        public var to : IndexPath
        /// The ``Section`` the ``Item`` is being moved to.
        public var toSection : Section
        
        /// If the item moved between sections during the reorder operation.
        public var sectionChanged : Bool
        
        // MARK: Initialization
        
        /// Creates a new instance of ``ItemReordering/Result`` with the provided options.
        public init(
            from: IndexPath,
            fromSection: Section,
            to: IndexPath,
            toSection: Section
        ) {
            self.from = from
            self.fromSection = fromSection
            self.to = to
            self.toSection = toSection
            self.sectionChanged = from.section != to.section
        }
        
        // MARK: Reading Values
        
        /// A short, readable description of the index path changes involved with the move.
        public var indexPathsDescription : String {
            "(\(from) -> \(to))"
        }
    }
    
    ///
    /// A gesture recognizer that you should use when implementing a reorderable ``Item`` in your list.
    ///
    /// In order to connect your gesture recognizer instance to the list, utilize the ``ReorderingActions``
    /// that you get off of the ``ApplyItemContentInfo`` passed to your `apply(to...)` method.
    ///
    /// Note that when using `BlueprintUILists`, you do not need to use this gesture recognizer
    /// directly. Instead, wrap your reorder control in a `ListReorderGesture` element, which will
    /// create and manage the underlying recognizer for you:
    ///
    /// ```swift
    /// func element(with info : ApplyItemContentInfo) -> Element {
    ///     Row { row in
    ///         row.add(child: Label(...))
    ///         row.add(child: Spacer())
    ///
    ///         row.add(
    ///             child: MyReorderControl()
    ///                    .listReorderGesture(with: info.reorderingActions)
    ///         )
    ///     }
    /// }
    /// ```
    public class GestureRecognizer : UIPanGestureRecognizer
    {
        private typealias OnStart = () -> Bool
        private typealias OnMove = (GestureRecognizer) -> ()
        private typealias OnEnd = (ReorderingActions.Result) -> ()

        private var onStart : OnStart? = nil
        private var onMove : OnMove? = nil
        private var onEnd : OnEnd? = nil
        
        /// Creates a gesture recognizer with the provided target and selector.
        public override init(target: Any?, action: Selector?)
        {
            super.init(target: target, action: action)
            
            self.addTarget(self, action: #selector(updated))
            
            self.minimumNumberOfTouches = 1
            self.maximumNumberOfTouches = 1
        }
        
        /// Applies the actions from the ``ReorderingActions`` to the gesture recognizer,
        /// so that it can communicate with the list during reorder actions.
        public func apply(actions : ReorderingActions) {
            
            self.onStart = actions.start
            self.onMove = actions.moved(with:)
            self.onEnd = actions.end(_:)
        }
        
        func reorderPosition(in collectionView : UIView) -> CGPoint? {
            
            guard let initial = self.initialCenter else {
                return nil
            }
            
            let translation = self.translation(in: collectionView)
            
            return CGPoint(
                x: initial.x + translation.x,
                y: initial.y + translation.y
            )
        }
        
        private var initialCenter : CGPoint? = nil
                
        @objc private func updated()
        {
            switch self.state {
            case .possible: break
            case .began:
                let center = self.view?.firstSuperview(ofType: UICollectionViewCell.self)?.center
                
                if let center = center {
                    if self.onStart?() == true {
                        self.initialCenter = center
                    } else {
                        self.state = .cancelled
                    }
                } else {
                    self.state = .cancelled
                }
            case .changed:
                self.onMove?(self)

            case .ended:
                self.onEnd?(.finished)
                self.initialCenter = nil
                
            case .cancelled, .failed:
                self.onEnd?(.cancelled)
                self.initialCenter = nil
                
            @unknown default: listableFatal()
            }
        }
    }
}


extension ItemReordering {
    
    func destination(
        from : IndexPath,
        fromSection : PresentationState.SectionState,
        to : IndexPath,
        toSection : PresentationState.SectionState
    ) -> IndexPath
    {
        let result = Result(
            from: from,
            fromSection: fromSection.model,
            to: to,
            toSection: toSection.model
        )
                
        if from == to {
            return to
        }
        
        let checks : [() -> Bool] = [
            { self.sections.canMove(from: fromSection, to: toSection) },
            
            { fromSection.model.reordering.canReorderOut(with: result) },
            { toSection.model.reordering.canReorderIn(with: result) },
            
            { result.allowed(with: self.canReorder) },
        ]
        
        for check in checks {
            if check() == false {
                return from
            }
        }
        
        return to
    }
}


extension ItemReordering.Result {
    
    func allowed(with check : ((ItemReordering.Result) throws -> Bool)?) -> Bool {
        
        guard let check = check else {
            return true
        }
        
        do {
            if try check(self) == false {
                return false
            }
        } catch {
            return false
        }
        
        return true
    }
}


extension ItemReordering.Sections {
    
    func canMove(from : PresentationState.SectionState, to : PresentationState.SectionState) -> Bool {
        
        switch self {
        case .current:
            return from === to
            
        case .all:
            return true
            
        case .specific(let current, let IDs):
            return (current && from === to) || IDs.contains(to.model.identifier.value)
        }
    }
}
