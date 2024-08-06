//
//  ListChangesQueue.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 7/19/21.
//

import Foundation


/// A queue used to synchronized and serialize changes made to the backing collection view,
/// to work around either bugs or confusing behavior.
///
/// ## Handling Applying Re-ordering / Move Events (`isQueuingToApplyReorderEvent`)
/// Collection View has an issue wherein if you perform a re-order event, and then within
/// the same runloop, deliver an update to the collection view as a result of that re-order event
/// that removes a row or section, the collection view will crash because it's internal index path
/// cache / data model has not yet been updated. Thus, in `collectionView(_:moveItemAt:to:)`,
/// we set this value to `true`, and then after one runloop, we set it back to `false`, after
/// the collection view's updates have "settled". Please see `sendEndQueuingEditsAfterDelay` for more.
///
/// ## Disabling Updates During In-Progress Re-orders (`listHasUncommittedReorderUpdates`)
/// If an update is pushed into a `UICollectionView` while a reorder is in progress, there will be a crash
/// as the collection view tries to layout an index path that does not exist in the data source, as the reordering event
/// has not yet been committed. As such, we'll queue external updates while reordering is in progress.
///
/// ```
/// 💥
/// Array.subscript.getter ()
/// ListLayoutContent.item(at:)
/// ListLayoutContent.layoutAttributes(at:)
/// CollectionViewLayout.layoutAttributesForItem(at:)
/// @objc CollectionViewLayout.layoutAttributesForItem(at:)
/// -[UICollectionViewData layoutAttributesForItemAtIndexPath:]
/// -[UICollectionViewData layoutAttributesForGlobalItemIndex:]
/// __107-[UICollectionView _attributesForItemsVisibleDuringCurrentUpdateWithOldVisibleViews:attributesForNewModel:]_block_invoke
/// __NSDICTIONARY_IS_CALLING_OUT_TO_A_BLOCK__
/// -[__NSDictionaryM enumerateKeysAndObjectsWithOptions:usingBlock:]
/// -[_UICollectionViewSubviewManager enumerateCellsWithEnumerator:]
/// -[UICollectionView _attributesForItemsVisibleDuringCurrentUpdateWithOldVisibleViews:attributesForNewModel:]
/// -[UICollectionView /// _createAndAppendViewAnimationsForExistingAndNewlyVisibleItemsInCurrentUpdate:animationsForOnScreenViews:newSubviewManager:oldVisibleViews:attributesF/// orNewModel:]
/// -[UICollectionView _viewAnimationsForCurrentUpdateWithCollectionViewAnimator:]
/// __102-[UICollectionView _updateWithItems:tentativelyForReordering:propertyAnimator:collectionViewAnimator:]_block_invoke.632
/// +[UIView(Animation) performWithoutAnimation:]
/// -[UICollectionView _updateWithItems:tentativelyForReordering:propertyAnimator:collectionViewAnimator:]
/// -[UICollectionView _endItemAnimationsWithInvalidationContext:tentativelyForReordering:animator:collectionViewAnimator:]
/// -[UICollectionView _performBatchUpdates:completion:invalidationContext:tentativelyForReordering:animator:animationHandler:]
/// ListView.IOS16_4_First_Responder_Bug_CollectionView.performBatchUpdates(_:changes:completion:)
/// closure #3 in ListView.performBatchUpdates(with:animated:updateBackingData:collectionViewUpdateCompletion:animationCompletion:)
/// ListView.performBatchUpdates(with:animated:updateBackingData:collectionViewUpdateCompletion:animationCompletion:)
/// closure #1 in ListView.updatePresentationStateWith(firstVisibleIndexPath:for:completion:)
/// closure #1 in ListChangesQueue.add(async:)
/// closure #2 in ListChangesQueue.runIfNeeded()
/// ListChangesQueue.Operation.ifSynchronous(_:ifAsynchronous:)
/// ListChangesQueue.runIfNeeded()
/// ListChangesQueue.add(sync:)
/// ListView.configure(with:)
/// ```
///
/// ## Handling async batch updates (`add(async:)`)
/// Because we perform updates to _our_ backing data model (`PresentationState`) alongside
/// our collection view in order to make sure they remain in sync, we need to handle cases where
/// `UICollectionView.performBatchUpdates(_:completion:)` does not synchronously
/// invoke its `update` block, which means state can get out of sync.
/// See `updatePresentationStateWith(firstVisibleIndexPath:for:completion:)` for more.
///
/// ## Misc
/// Why not use `NSOperationQueue` here?
/// Namely, because we want operations to be synchronous when possible.
///
/// Eg, if if you perform the following changes:
///
/// ```
/// list.something()
///
/// // A synchronous operation.
/// queue.add {
///     doSomethingElse()
/// }
///
/// // An operation which may be synchronous or asynchronous,
/// // depending on when the completion callback fires.
/// queue.add { completion in
///     doAnotherThing(onCompletion: completion.finished)
/// }
/// ```
/// Where the first block can be run immediately (eg the queue is not paused),
/// it will be performed once the queue callback returns, and without jumping threads at all.
///
/// The second block might invoke its `onCompletion` immediately,
/// or it might take a runloop or two to do so. This implementation ensures
/// that if the completion block is invoked immediately (eg inline), the operation will also be synchronous.
/// The main use case for this case is `UICollectionView` callbacks which are sometimes
/// executed after a few runloop cycles – we don't want _every_ event going through
/// the queue to delay its completion by a runloop cycle unless we have to.
///
/// Only one operation will execute at once. This is a FIFO queue.
///
final class ListChangesQueue {
        
    /// Adds a synchronous block to the queue, marked as done once the block exits.
    func add(sync block : @escaping () -> ()) {
        preconditionMainThread()
        
        let operation = Operation(
            kind: .synchronous(
                .new(.init(body: block))
            )
        )
        
        self.waiting.append(operation)
        
        self.runIfNeeded()
    }
    
    /// Adds an asynchronous block to the queue, marked as done once `Completion.finished()` is called.
    /// If `finished()` is called inline, the operation will be executed synchronously.
    func add(async block : @escaping (Completion) -> ()) {
        preconditionMainThread()
        
        let operation = Operation(
            kind: .asynchronous(
                .new(
                    .init(
                        completion: Completion(),
                        body: { operation, completion in
                            
                            completion.onFinish = { [weak self, weak operation] in
                                operation?.kind = .asynchronous(.completed)
                                self?.runIfNeeded()
                            }
                            
                            block(completion)
                        }
                    )
                )
            )
        )
        
        self.waiting.append(operation)
        
        self.runIfNeeded()
    }
    
    /// Set by consumers to enable and disable queueing when a reorder event is being applied.
    var isQueuingToApplyReorderEvent : Bool = false {
        didSet {
            self.runIfNeeded()
        }
    }
    
    /// Should be set to `{ collectionView.hasUncommittedUpdates }`.
    ///
    /// When this closure returns `true`, the queue is paused, to avoid crashes when applying
    /// content updates while there are index-changing reorder events in process.
    var listHasUncommittedReorderUpdates : () -> Bool = {
        fatalError("Must set `listHasUncommittedReorderUpdates` before using `ListChangesQueue`.")
    }
    
    /// Prevents processing other events in the queue.
    var isPaused : Bool {
        self.isQueuingToApplyReorderEvent || self.listHasUncommittedReorderUpdates()
    }
    
    var isEmpty : Bool {
        waiting.isEmpty
    }
    
    var count : Int {
        waiting.count
    }
    
    /// Operations waiting to execute, or in the case of asynchronous operations,
    /// they may already be operating.
    private var waiting : [Operation] = []
    
    private var isRunning : Bool = false
    
    /// Invoked to continue processing queue events.
    private func runIfNeeded() {
        preconditionMainThread()

        guard isRunning == false else { return }
        
        defer { isRunning = false }
        
        isRunning = true
        
        while let current = self.waiting.first {
            
            guard self.isPaused == false else { return }
            
            var shouldBreak : Bool = false
            
            current.ifSynchronous { sync in
                switch sync {
                case .new(let content):
                    content.body()
                    sync = .completed
                    
                    self.waiting.removeFirst()
                    
                case .completed:
                    fatalError("Should not be able to enumerate a completed synchronous operation.")
                }
                
                shouldBreak = false
                
            } ifAsynchronous: { async in
                switch async {
                case .new(let content):
                    async = .running(content)
                    content.body(current, content.completion)
                    
                    /// Even though this is an async operation;
                    /// its possible (and allowed) to call the completion
                    /// block synchronously – let's ensure we handle that!
                    
                    if current.kind.isCompleted {
                        shouldBreak = false
                        self.waiting.removeFirst()
                    } else {
                        shouldBreak = true
                    }
                case .running:
                    shouldBreak = true
                case .completed:
                    self.waiting.removeFirst()
                }
            }
            
            if shouldBreak {
                break
            }
        }
    }
    
    private func preconditionMainThread() {
        precondition(
            Thread.isMainThread,
            "ListChangesQueue must run on main thread. Instead, it was \(Thread.current)."
        )
    }
}


extension ListChangesQueue {
        
    final class Completion {

        fileprivate var onFinish : () -> () = {
            fatalError("onFinish must be set before the completion operation is used.")
        }
        
        private var isFinished : Bool = false
        
        /// Invoked by callers when their async work completed.
        /// If this method is called more than once, a fatal error occurs.
        func finish() {
            precondition(isFinished == false, "Cannot finish an operation more than once.")
            
            isFinished = true
            
            onFinish()
        }
    }
    
    fileprivate final class Operation {
        
        var kind : Kind
        
        init(kind : Kind) {
            self.kind = kind
        }
        
        /// Helper method for accessing (and mutating) the state
        /// of each separate type of operation.
        func ifSynchronous(
            _ synchronous : (inout Kind.Synchronous) -> (),
            ifAsynchronous asynchronous : (inout Kind.Asynchronous) -> ()
        ) {
            switch self.kind {
            case .synchronous(var content):
                synchronous(&content)
                self.kind = .synchronous(content)
                
            case .asynchronous(var content):
                asynchronous(&content)
                self.kind = .asynchronous(content)
            }
        }
        
        /// The kind of operation, sync or async. Note that
        /// the synchronous operation has to track less state,
        /// and thus has fewer cases and stored properties.
        enum Kind {
            case synchronous(Synchronous)
            case asynchronous(Asynchronous)
            
            var isCompleted : Bool {
                switch self {
                case .synchronous(let sync): return sync.isCompleted
                case .asynchronous(let async): return async.isCompleted
                }
            }
            
            enum Synchronous {
                case new(Content)
                case completed
                
                var isCompleted : Bool {
                    switch self {
                    case .new: return false
                    case .completed: return true
                    }
                }
                
                struct Content {
                    let body : () -> ()
                }
            }
            
            enum Asynchronous {
                case new(Content)
                case running(Content)
                case completed
                
                var isCompleted : Bool {
                    switch self {
                    case .new, .running: return false
                    case .completed: return true
                    }
                }
                
                struct Content {
                    let completion : Completion
                    let body : (Operation, Completion) -> ()
                }
            }
        }
    }
}
