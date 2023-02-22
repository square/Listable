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
/// ## Handling Re-ordering (`isQueuingForReorderEvent`)
/// Collection View has an issue wherein if you perform a re-order event, and then within
/// the same runloop, deliver an update to the collection view as a result of that re-order event
/// that removes a row or section, the collection view will crash because it's internal index path
/// cache / data model has not yet been updated. Thus, in `collectionView(_:moveItemAt:to:)`,
/// we set this value to `true`, and then after one runloop, we set it back to `false`, after
/// the collection view's updates have "settled". Please see `sendEndQueuingEditsAfterDelay` for more.
///
/// ## Handling async batch updates (`add(async:)`)
/// Because we peform updates to _our_ backing data model (`PresentationState`) alongside
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
    func add(_ id : AnyHashable? = nil, sync block : @escaping () -> ()) {
        add(id) { operation in
            block()
            operation.finish()
        }
    }
    
    /// Adds an asynchronous block to the queue, marked as done once `Completion.finished()` is called.
    /// If `finished()` is called inline, the operation will be executed synchronously.
    func add(_ id : AnyHashable? = nil, async block : @escaping (Completion) -> ()) {
        preconditionMainThread()
        
        let operation = Operation(
            identifier: id,
            state: .new(
                .init(
                    completion: Completion(),
                    body: { operation, completion in
                        
                        completion.onFinish = { [weak self, weak operation] in
                            operation?.state = .completed
                            self?.runIfNeeded()
                        }
                        
                        block(completion)
                    }
                )
            )
        )
        
        operationToAppendTo()
            .children
            .append(operation)
        
        runIfNeeded()
    }
    
    /// Set by consumers to enable and disable queueing during a reorder event.
    var isQueuingForReorderEvent : Bool = false {
        didSet {
            self.runIfNeeded()
        }
    }
    
    /// Prevents processing other events in the queue.
    ///
    /// Note: Right now this just checks `isQueuingForReorderEvent`, but may check more props in the future.
    var isPaused : Bool {
        self.isQueuingForReorderEvent
    }
    
    var isEmpty : Bool {
        root.children.isEmpty
    }
    
    var count : Int {
        fatalError()
    }
    
    /// A root operation we use as the base operation for the queue.
    /// It is always "running" and never completes.
    let root : Operation = Operation(
        state: .running(
            .init(
                completion: .init(),
                body: { _, _ in }
            )
        )
    )
    
    var runIDs : [AnyHashable]? = nil
    
    private func operationToAppendTo() -> Operation {
        
        /// Find the deepest running operation in the tree,
        /// that will be the operation we append to. If we don't have one,
        /// then the root operation will take on the operation as a child.
        
        if let running = root.flattenedChildren.last(where: { operation in
            operation.state.isRunning
        }) {
            return running
        } else {
            return root
        }
    }
    
    private func nextRunnableOperation() -> Operation? {
        
        /// Digs in to find the first runnable operation, eg if we have:
        ///
        /// ```
        ///  Operation1 (Running)
        ///     Operation2 (Complete)
        ///         Operation3 (New)
        ///     Operation4 (New)
        ///  Operation5 (New)
        /// ```
        /// We'll run `Operation3` first. This is intentionally a DFS.
        /// At the top level `root` operation, there must only be one
        /// in-progress operation at one time.
        
        root.flattenedChildren.first { operation in
            operation.state.isNew
        }
    }
    
    /// Invoked to continue processing queue events.
    private func runIfNeeded() {
        preconditionMainThread()
        
        /// Note: We intentionally iterate through available operations,
        /// instead of recursively re-calling this method, to avoid the
        /// stack trace getting deeper and deeper if there are multiple
        /// synchronous operations to execute.
        
        while let current = nextRunnableOperation() {
            
            guard self.isPaused == false else { return }
            
            /// Run before we iterate to remove any asynchronously completed operations.
            root.removeAllCompleted()
                        
            switch current.state {
            case .new(let content):
                
                /// This is for testing; so we can follow the run operations.
                /// It's going to always be `nil` in production.
                if let id = current.identifier {
                    runIDs?.append(id)
                }
                
                current.state = .running(content)
                content.body(current, content.completion)
                
            case .running, .completed:
                break
            }
            
            /// Run after, to remove any synchronously completed operations as well.
            root.removeAllCompleted()
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
            finish({})
        }
        
        /// Invoked by callers when their async work completed.
        /// If this method is called more than once, a fatal error occurs.
        func finish(_ action : () -> ()) {
            precondition(isFinished == false, "Cannot finish an operation more than once.")
            
            action()
            
            isFinished = true
            
            onFinish()
        }
    }
    
    final class Operation {
        
        var state : State
        
        var children : [Operation] = []
        
        var identifier : AnyHashable?
        
        init(identifier: AnyHashable? = nil, state : State) {
            self.identifier = identifier
            self.state = state
        }
        
        /// Removes all operations that are fully completed from
        /// the tree. Note that this also ensures all children are
        /// completed. If not all children are completed, then
        /// the operation is not removed.
        func removeAllCompleted() {
            filter { child in
                child.allChildrenPass { child in
                    child.state.isCompleted == true
                }
            }
        }
        
        var flattenedChildren : [Operation] {
            
            children.flatMap {
                [$0] + $0.flattenedChildren
            }
            
        }
        
        func allChildrenPass(_ passing : (Operation) -> Bool) -> Bool {
            for child in children {
                if passing(child) == false {
                    return false
                } else {
                    return child.allChildrenPass(passing)
                }
            }
            
            return false
        }
        
        func hasAnyChildren(passing : (Operation) -> Bool) -> Bool {
            for child in children {
                if passing(child) {
                    return true
                } else {
                    return child.hasAnyChildren(passing: passing)
                }
            }
            
            return false
        }
        
        func first(passing : (Operation) -> Bool) -> Operation? {
            for child in children {
                if passing(child) {
                    return child
                } else {
                    return child.first(passing: passing)
                }
            }
            
            return nil
        }
        
        func filter(passing keep : (Operation) -> Bool) {
            children = children.compactMap { child in
                keep(child) ? child : nil
            }
        }
        
        /// The state of the operation. As the operation progresses,
        /// we proceed down each cases. Should never go backwards.
        enum State {
            case new(Content)
            case running(Content)
            case completed
            
            var isNew : Bool {
                switch self {
                case .new: return true
                case .running, .completed: return false
                }
            }
            
            var isCompleted : Bool {
                switch self {
                case .completed: return true
                case .new, .running: return false
                }
            }
            
            var isRunning : Bool {
                switch self {
                case .running: return true
                case .new, .completed: return false
                }
            }
            
            struct Content {
                let completion : Completion
                let body : (Operation, Completion) -> ()
            }
        }
    }
}
