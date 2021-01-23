//
//  ArrayDiff.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/22/19.
//

import Foundation


struct ArrayDiff<Element, Identifier:Hashable>
{
    var added : [Added]
    var removed : [Removed]
    
    var moved : [Moved]
    var updated : [Updated]
    var noChange : [NoChange]
    
    var changeCount : Int
    
    let usedFastPath : Bool
    
    struct Added
    {
        let identifier : Identifier
        
        let newIndex : Int
        
        let new : Element
    }
    
    struct Removed
    {
        let identifier : Identifier
        
        let oldIndex : Int
        
        let old : Element
    }
    
    struct Moved
    {
        let identifier : Identifier
        
        let old : Removed
        let new : Added
    }
    
    struct Updated
    {
        let identifier : Identifier
        
        let oldIndex : Int
        let newIndex : Int
        
        let old : Element
        let new : Element
    }
    
    struct NoChange
    {
        let identifier : Identifier
        
        let oldIndex : Int
        let newIndex : Int
        
        let old : Element
        let new : Element
    }
    
    init(
        old : [Element],
        new : [Element],
        identifierProvider : (Element) -> Identifier,
        movedHint : (Element, Element) -> Bool,
        updated : (Element, Element) -> Bool
        )
    {
        //
        // Fast Path: If the only changes were updates, bail.
        // This allows us to save ~90% of the time of an entire diff in many cases.
        //
        
        if let (updated, noChange) = Self.fastPastDiff(old: old, new: new, identifierProvider: identifierProvider, updated: updated) {
            
            self.added = []
            self.removed = []
            self.moved = []
            self.updated = updated
            self.noChange = noChange
            
            self.changeCount = updated.count
            self.usedFastPath = true
            
            return
        }
        
        //
        // Normal Path: There are inserts, removals, or moves.
        //
        
        self.usedFastPath = false
        
        // Create diffable collections for fast lookup.
        
        let old = DiffableCollection(elements: old, identifierProvider)
        let new = DiffableCollection(elements: new, identifierProvider)
        
        //
        // Additions and Removals.
        //
        
        let added = new.subtractDifference(from: old)
        let removed = old.subtractDifference(from: new)
        
        self.added = added.map {
            Added(
                identifier: $0.identifier.base,
                newIndex: $0.index,
                new: $0.value
            )
        }
        
        self.removed = removed.map {
            Removed(
                identifier: $0.identifier.base,
                oldIndex: $0.index,
                old: $0.value
            )
        }
        
        //
        // Moves, Updates, and No Change.
        //
        
        self.moved = []
        self.updated = []
        self.noChange = []
        
        // Create pairs and figure out move hints.
        
        let pairs = Pair.pairs(withNew: new, old: old, movedHint: movedHint, updated: updated)
        
        let (moveHinted, moveNotHinted) = pairs.separate { pair in pair.moveHinted }
        
        // We iterate over moves first, in order to ensure move hints have an effect.
        // If there are no move hints, then whatever transforms result in the new array will be applied.
        
        var sorted = [Pair]()
        sorted.reserveCapacity(moveHinted.count + moveNotHinted.count)
        
        sorted += moveHinted.sorted { $0.distance > $1.distance }
        sorted += moveNotHinted.sorted { $0.distance > $1.distance }
        
        for pair in sorted {
            let moved = old.index(of: pair.identifier) != new.index(of: pair.identifier)
            
            if moved {
                old.move(
                    from: old.index(of: pair.identifier),
                    to: new.index(of: pair.identifier)
                )
                
                self.moved.append(Moved(
                    identifier: pair.new.identifier.base,
                    
                    old: Removed(
                        identifier: pair.old.identifier.base,
                        oldIndex: pair.old.index,
                        old: pair.old.value
                    ),
                    new: Added(
                        identifier: pair.new.identifier.base,
                        newIndex: pair.new.index,
                        new: pair.new.value
                    )
                ))
            } else if pair.updated {
                self.updated.append(Updated(
                    identifier: pair.new.identifier.base,
                    oldIndex: pair.old.index,
                    newIndex: pair.new.index,
                    old: pair.old.value,
                    new: pair.new.value
                ))
            } else {
                self.noChange.append(NoChange(
                    identifier: pair.new.identifier.base,
                    oldIndex: pair.old.index,
                    newIndex: pair.new.index,
                    old: pair.old.value,
                    new: pair.new.value
                ))
            }
        }
        
        // We are done – sort arrays.
        
        self.added.sort { $0.newIndex < $1.newIndex }
        self.removed.sort { $0.oldIndex > $1.oldIndex }
        
        self.moved.sort { $0.new.newIndex > $1.new.newIndex }
        self.updated.sort { $0.newIndex < $1.newIndex }
        self.noChange.sort { $0.newIndex < $1.newIndex }
        
        self.changeCount = self.added.count
            + self.removed.count
            + self.moved.count
            + self.updated.count
    }
    
    static func fastPastDiff(
        old : [Element],
        new : [Element],
        identifierProvider : (Element) -> Identifier,
        updated : (Element, Element) -> Bool
    ) -> ([Updated], [NoChange])?
    {
        guard old.count == new.count else {
            return nil
        }
        
        var updates = [Updated]()
        
        var notChanged = [NoChange]()
        
        for index in 0..<new.count {
            let old = old[index]
            let new = new[index]
            
            let newID = identifierProvider(new)
            
            guard identifierProvider(old) == newID else {
                return nil
            }
            
            if updated(old, new) {
                updates.append(
                    Updated(
                        identifier: newID,
                        oldIndex: index,
                        newIndex: index,
                        old: old,
                        new: new
                    )
                )
            } else {
                notChanged.append(
                    NoChange(
                        identifier: newID,
                        oldIndex: index,
                        newIndex: index,
                        old: old,
                        new: new
                    )
                )
            }
        }
        
        return (updates, notChanged)
    }
    
    private final class Pair
    {
        let new : DiffContainer<Element, Identifier>
        let old : DiffContainer<Element, Identifier>
        
        let identifier : UniqueIdentifier<Element, Identifier>
        
        let distance : Int
        
        let moveHinted : Bool
        let updated : Bool
        
        init(
            new : DiffContainer<Element, Identifier>,
            old : DiffContainer<Element, Identifier>,
            identifier : UniqueIdentifier<Element, Identifier>,
            distance : Int,
            moveHinted : Bool,
            updated : Bool
            )
        {
            self.new = new
            self.old = old
            
            self.identifier = identifier
            
            self.distance = distance
            
            self.moveHinted = moveHinted
            self.updated = updated
        }
        
        static func pairs(
            withNew new : DiffableCollection<Element, Identifier>,
            old : DiffableCollection<Element, Identifier>,
            movedHint : (Element, Element) -> Bool,
            updated : (Element, Element) -> Bool
            ) -> [Pair]
        {
            return new.containers.map { newContainer in
                
                let identifier = newContainer.identifier
                let oldContainer = old.container(for: identifier)
                
                return Pair(
                    new: newContainer,
                    old: oldContainer,
                    identifier: identifier,
                    distance: abs(new.index(of: identifier) - old.index(of: identifier)),
                    moveHinted: movedHint(oldContainer.value, newContainer.value),
                    updated: updated(oldContainer.value, newContainer.value)
                )
            }
        }
    }
}

extension ArrayDiff : Equatable where Element : Equatable {}

extension ArrayDiff.Added : Equatable where Element : Equatable {}
extension ArrayDiff.Removed : Equatable where Element : Equatable {}
extension ArrayDiff.Moved : Equatable where Element : Equatable {}
extension ArrayDiff.Updated : Equatable where Element : Equatable {}
extension ArrayDiff.NoChange : Equatable where Element : Equatable {}


extension ArrayDiff
{
    func transform<Mapped>(
        old : [Mapped],
        removed : (Element, Mapped) -> (),
        added : (Element) -> Mapped,
        moved : (Element, Element, inout Mapped) -> (),
        updated : (Element, Element, inout Mapped) -> (),
        noChange : (Element, Element, inout Mapped) -> ()
        ) -> [Mapped]
    {
        // 1) Built mutative changes. Sort to ensure changes are not destructive (eg, we can mutate an array in place).
        
        // 1a) Removes
        
        var removes = [Removal<Mapped>]()
        removes.reserveCapacity(self.removed.count + self.moved.count)
        
        removes += self.removed.map {
            removed($0.old, old[$0.oldIndex])
            return Removal(mapped: old[$0.oldIndex], removed: $0)
        }
        
        removes += self.moved.map {
            return Removal(mapped: old[$0.old.oldIndex], removed: $0.old)
        }
        
        removes.sort { $0.removed.oldIndex > $1.removed.oldIndex }
        
        // 1b) Insertions
        
        var inserts = [Insertion<Mapped>]()
        inserts.reserveCapacity(self.added.count + self.moved.count)
        
        inserts += self.added.map {
            let value = added($0.new)
            return Insertion(mapped: value, insert: $0)
        }
        
        inserts += self.moved.map {
            var value = old[$0.old.oldIndex]
            moved($0.old.old, $0.new.new, &value)
            return Insertion(mapped: value, insert: $0.new)
        }
        
        inserts.sort { $0.insert.newIndex < $1.insert.newIndex }
        
        // 1c) Apply changes to original array.
        
        var new = old
        
        removes.forEach {
            new.remove(at: $0.removed.oldIndex)
        }
        
        inserts.forEach {
            new.insert($0.mapped, at: $0.insert.newIndex)
        }
        
        // 2) Now that index changes are complete, perform update and no change messaging.
        
        // 2a) Updates
        
        self.updated.forEach {
            var value = new[$0.newIndex]
            updated($0.old, $0.new, &value)
            new[$0.newIndex] = value
        }
        
        // 2b) No Changes
        
        self.noChange.forEach {
            var value = new[$0.newIndex]
            noChange($0.old, $0.new, &value)
            new[$0.newIndex] = value
        }
        
        return new
    }
    
    final private class Insertion<Mapped>
    {
        let mapped : Mapped
        let insert : Added
        
        init(mapped : Mapped, insert : Added)
        {
            self.mapped = mapped
            self.insert = insert
        }
    }
    
    final private class Removal<Mapped>
    {
        let mapped : Mapped
        let removed : Removed
        
        init(mapped : Mapped, removed : Removed)
        {
            self.mapped = mapped
            self.removed = removed
        }
    }
}


private class DiffContainer<Value, Identifier:Hashable>
{
    let identifier : UniqueIdentifier<Value, Identifier>
    let value : Value
    let index : Int
    
    init(
        value : Value,
        index : Int,
        identifierProvider : (Value) -> Identifier,
        identifierFactory : UniqueIdentifier<Value, Identifier>.Factory
        )
    {
        self.value = value
        self.index = index
        
        self.identifier = identifierFactory.identifier(for: identifierProvider(self.value))
    }
    
    static func containers(with elements : [Value], identifierProvider : (Value) -> Identifier) -> [DiffContainer]
    {
        let identifierFactory = UniqueIdentifier<Value, Identifier>.Factory()
        identifierFactory.reserveCapacity(elements.count)
        
        return elements.mapWithIndex { index, _, value in
            return DiffContainer(
                value: value,
                index: index,
                identifierProvider: identifierProvider,
                identifierFactory: identifierFactory
            )
        }
    }
}


private struct UniqueIdentifier<Type, Identifier:Hashable> : Hashable
{
    let base : Identifier
    
    private let modifier : Int
    
    private let hash : Int
    
    init(base : Identifier, modifier : Int)
    {
        self.base = base
        self.modifier = modifier
        
        var hasher = Hasher()
        hasher.combine(self.base)
        hasher.combine(self.modifier)
        self.hash = hasher.finalize()
    }
    
    static func == (lhs: UniqueIdentifier, rhs: UniqueIdentifier) -> Bool
    {
        return lhs.hash == rhs.hash && lhs.base == rhs.base && lhs.modifier == rhs.modifier
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(self.hash)
    }
    
    final class Factory
    {
        private var counts : [Identifier:Int] = [:]
        
        func reserveCapacity(_ minimumCapacity : Int)
        {
            self.counts.reserveCapacity(minimumCapacity)
        }
        
        func identifier(for base : Identifier) -> UniqueIdentifier
        {
            let count = self.counts[base, default:1]
            
            self.counts[base] = (count + 1)
            
            return UniqueIdentifier(base: base, modifier: count)
        }
    }
}

private final class DiffableCollection<Value, Identifier:Hashable>
{
    private(set) var containers : [DiffContainer<Value, Identifier>]
    private var containersByIdentifier : [UniqueIdentifier<Value, Identifier>:DiffContainer<Value, Identifier>]
    
    init(elements : [Value], _ identifierProvider : (Value) -> Identifier)
    {
        self.uniqueIdentifierIndexes.reserveCapacity(elements.count)
        
        self.containers = DiffContainer.containers(with: elements, identifierProvider: identifierProvider)
        
        self.containersByIdentifier = self.containers.toUniqueDictionary { _, container in
            return (container.identifier, container)
        }
    }
    
    // MARK: Querying The Collection
    
    func index(of identifier : UniqueIdentifier<Value, Identifier>) -> Int
    {
        self.generateIndexLookupsIfNeeded()
        
        return self.uniqueIdentifierIndexes[identifier]!
    }
    
    func contains(identifier : UniqueIdentifier<Value, Identifier>) -> Bool
    {
        return self.containersByIdentifier[identifier] != nil
    }
    
    func container(for identifier : UniqueIdentifier<Value, Identifier>) -> DiffContainer<Value, Identifier>
    {
        return self.containersByIdentifier[identifier]!
    }
    
    func difference(from other : DiffableCollection) -> [DiffContainer<Value, Identifier>]
    {
        return self.containers.compactMap { element in
            if other.contains(identifier: element.identifier) == false {
                return element
            } else {
                return nil
            }
        }
    }
    
    func subtractDifference(from other : DiffableCollection) -> [DiffContainer<Value, Identifier>]
    {
        let difference = self.difference(from: other)
        
        self.remove(containers: difference)
        
        return difference
    }
    
    // MARK: Core Mutating Methods
    
    func move(from : Int, to: Int)
    {
        guard from != to else {
            return
        }
        
        let value = self.containers[from]
        
        self.containers.remove(at: from)
        self.containers.insert(value, at: to)
        
        self.resetIndexLookups()
    }
    
    func remove(containers : [DiffContainer<Value, Identifier>])
    {
        containers.forEach {
            self.containersByIdentifier.removeValue(forKey: $0.identifier)
        }
        
        let indexes = containers.map({
            return self.index(of: $0.identifier)
        }).sorted(by: { $0 > $1 })
        
        indexes.forEach {
            self.containers.remove(at: $0)
        }
        
        self.resetIndexLookups()
    }
    
    // MARK: Private Methods
    
    private var uniqueIdentifierIndexes : [UniqueIdentifier<Value, Identifier>:Int] = [:]
    
    private func resetIndexLookups()
    {
        self.uniqueIdentifierIndexes.removeAll(keepingCapacity: true)
    }
    
    private func generateIndexLookupsIfNeeded()
    {
        guard self.uniqueIdentifierIndexes.isEmpty else {
            return
        }
        
        self.containers.forEachWithIndex { index, isLast, container in
            self.uniqueIdentifierIndexes[container.identifier] = index
        }
    }
}

private extension Array
{
    func separate(_ block : (Element) -> Bool) -> ([Element], [Element])
    {
        var left = [Element]()
        var right = [Element]()
        
        for element in self {
            if block(element) {
                left.append(element)
            } else {
                right.append(element)
            }
        }
        
        return (left, right)
    }
}

private extension Array
{
    func toUniqueDictionary<Key:Hashable, Value>(_ block : (Int, Element) -> (Key, Value)) -> Dictionary<Key,Value>
    {
        var dictionary = Dictionary<Key,Value>()
        dictionary.reserveCapacity(self.count)
        
        for (index, element) in self.enumerated() {
            let (key,value) = block(index, element)
            
            guard dictionary[key] == nil else {
                listableFatal("Existing entry for key '\(key)' not allowed for unique dictionaries.")
            }
            
            dictionary[key] = value
        }
        
        return dictionary
    }
}
