//
//  Diff.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/16/19.
//

import Foundation


struct SectionedDiff<Section, Item>
{
    let old : [Section]
    let new : [Section]
    
    let changes : SectionChanges
    let aggregatedChanges : AggregatedChanges
    
    init(old : [Section], new: [Section], configuration : Configuration)
    {
        self.old = old
        self.new = new
        
        self.changes = SectionChanges(
            old: old,
            new: new,
            configuration: configuration
        )
        
        self.aggregatedChanges = AggregatedChanges(sectionChanges: self.changes)
    }
    
    static func calculate(on queue : DispatchQueue, old : [Section], new: [Section], configuration : Configuration, completion : @escaping (SectionedDiff) -> ())
    {
        queue.async {
            let diff = SectionedDiff(old: old, new: new, configuration: configuration)
            completion(diff)
        }
    }
    
    struct Configuration
    {
        var moveDetection : MoveDetection
        
        var section : SectionProviders
        var item : ItemProviders
        
        init(moveDetection : MoveDetection = .checkAll, section : SectionProviders, item : ItemProviders)
        {
            self.moveDetection = moveDetection
            
            self.section = section
            self.item = item
        }
        
        struct SectionProviders
        {
            var identifier : (Section) -> AnyIdentifier
            
            var items : (Section) -> [Item]
            
            var movedHint : (Section, Section) -> Bool
            
            init(
                identifier : @escaping (Section) -> AnyIdentifier,
                items : @escaping (Section) -> [Item],
                movedHint : @escaping (Section, Section) -> Bool
            )
            {
                self.identifier = identifier
                self.items = items
                self.movedHint = movedHint
            }
        }
        
        struct ItemProviders
        {
            var identifier : (Item) -> AnyIdentifier
            
            var updated : (Item, Item) -> Bool
            var movedHint : (Item, Item) -> Bool
            
            init(
                identifier : @escaping (Item) -> AnyIdentifier,
                updated : @escaping (Item, Item) -> Bool,
                movedHint : @escaping (Item, Item) -> Bool
            )
            {
                self.identifier = identifier
                self.updated = updated
                self.movedHint = movedHint
            }
        }
    }
    
    struct SectionChanges
    {
        let added : [Added]
        let removed : [Removed]
        
        let moved : [Moved]
        let noChange : [NoChange]
        
        let sectionsChangeCount : Int
        let itemsChangeCount : Int
                
        private let diff : ArrayDiff<Section>
        
        init(old : [Section], new : [Section], configuration : Configuration)
        {
            self.diff = ArrayDiff(
                old: old,
                new: new,
                configuration: .init(moveDetection: configuration.moveDetection),
                identifierProvider: { configuration.section.identifier($0) },
                movedHint: { configuration.section.movedHint($0, $1) },
                updated: { _, _ in false }
            )
            
            self.added = diff.added.map {
                Added(
                    newIndex: $0.newIndex,
                    newValue: $0.new
                )
            }
            
            self.removed = diff.removed.map {
                Removed(
                    oldIndex: $0.oldIndex,
                    oldValue: $0.old
                )
            }
            
            self.moved = diff.moved.map {
                Moved(
                    oldIndex: $0.oldIndex,
                    newIndex: $0.newIndex,
                    oldValue: $0.old,
                    newValue: $0.new,
                    
                    itemChanges: SectionedDiff.ItemChanges(
                        old: $0.old,
                        oldIndex: $0.oldIndex,
                        new: $0.new,
                        newIndex: $0.newIndex,
                        configuration: configuration
                    )
                )
            }
                        
            self.noChange = diff.noChange.map {
                return NoChange(
                    oldIndex: $0.oldIndex,
                    newIndex: $0.newIndex,
                    oldValue: $0.old,
                    newValue: $0.new,
                    
                    itemChanges: SectionedDiff.ItemChanges(
                        old: $0.old,
                        oldIndex: $0.oldIndex,
                        new: $0.new,
                        newIndex: $0.newIndex,
                        configuration: configuration
                    )
                )
            }
            
            self.sectionsChangeCount = self.added.count
                + self.removed.count
                + self.moved.count
            
            self.itemsChangeCount =
                self.moved.reduce(0, { $0 + $1.itemChanges.changeCount }) +
                self.noChange.reduce(0, { $0 + $1.itemChanges.changeCount })
            
            precondition(diff.updated.isEmpty, "Must not have any updates for sections; sections can only move.")
        }
        
        struct Added
        {
            let newIndex : Int
            
            let newValue : Section
        }
        
        struct Removed
        {
            let oldIndex : Int
            
            let oldValue : Section
        }
        
        struct Moved
        {
            let oldIndex : Int
            let newIndex : Int
            
            let oldValue : Section
            let newValue : Section
            
            let itemChanges : ItemChanges
        }
        
        struct NoChange
        {
            let oldIndex : Int
            let newIndex : Int
            
            let oldValue : Section
            let newValue : Section
            
            let itemChanges : ItemChanges
        }
    }
    
    struct AggregatedChanges
    {
        var deletedSections : [SectionChanges.Removed] = []
        var insertedSections : [SectionChanges.Added] = []
        var movedSections : [SectionChanges.Moved] = []
        
        var deletedItems : [ItemChanges.Removed] = []
        var insertedItems : [ItemChanges.Added] = []
        var updatedItems : [ItemChanges.Updated] = []
        var movedItems : [ItemChanges.Moved] = []
        
        init(sectionChanges changes : SectionChanges)
        {
            // Inserted & Removed Sections

            self.deletedSections = changes.removed
            self.insertedSections = changes.added


            // Moved Sections
            
            self.movedSections = changes.moved

            // Deleted Items

            changes.moved.forEach {
                self.deletedItems += $0.itemChanges.removed
            }

            changes.noChange.forEach {
                self.deletedItems += $0.itemChanges.removed
            }

            // Inserted Items
            
            changes.moved.forEach {
                self.insertedItems += $0.itemChanges.added
            }

            changes.noChange.forEach {
                self.insertedItems += $0.itemChanges.added
            }
            
            // Updated Items
            
            changes.moved.forEach {
                self.updatedItems += $0.itemChanges.updated
            }

            changes.noChange.forEach {
                self.updatedItems += $0.itemChanges.updated
            }

            // Moved Items
            
            changes.moved.forEach {
                self.movedItems += $0.itemChanges.moved
            }

            changes.noChange.forEach {
                self.movedItems += $0.itemChanges.moved
            }
        }
    }
    
    struct ItemChanges
    {
        let added : [Added]
        let removed : [Removed]
        
        let moved : [Moved]
        let updated : [Updated]
        let noChange : [NoChange]
        
        let changeCount : Int
        
        let diff : ArrayDiff<Item>

        init(old : Section, oldIndex : Int, new : Section, newIndex : Int, configuration: Configuration)
        {
            self.init(
                old: configuration.section.items(old),
                oldIndex: oldIndex,
                new: configuration.section.items(new),
                newIndex: newIndex,
                configuration: configuration
            )
        }
        
        init(old : [Item], oldIndex : Int, new : [Item], newIndex : Int, configuration : Configuration)
        {
            self.diff = ArrayDiff(
                old: old,
                new: new,
                configuration: .init(moveDetection: configuration.moveDetection),
                identifierProvider: { configuration.item.identifier($0) },
                movedHint: { configuration.item.movedHint($0, $1) },
                updated: { configuration.item.updated($0, $1) }
            )
            
            self.added = diff.added.map {
                Added(
                    newIndex: IndexPath(item: $0.newIndex, section: newIndex),
                    newValue: $0.new
                )
            }
            
            self.removed = diff.removed.map {
                Removed(
                    oldIndex: IndexPath(item: $0.oldIndex, section: oldIndex),
                    oldValue: $0.old
                )
            }
            
            self.moved = diff.moved.map {
                Moved(
                    oldIndex: IndexPath(item: $0.oldIndex, section: oldIndex),
                    newIndex: IndexPath(item: $0.newIndex, section: newIndex),
                    oldValue: $0.old,
                    newValue: $0.new
                )
            }
            
            self.updated = diff.updated.map {
                Updated(
                    oldIndex: IndexPath(item: $0.oldIndex, section: oldIndex),
                    newIndex: IndexPath(item: $0.newIndex, section: newIndex),
                    oldValue: $0.old,
                    newValue: $0.new
                )
            }
            
            self.noChange = diff.noChange.map {
                NoChange(
                    oldIndex: IndexPath(item: $0.oldIndex, section: oldIndex),
                    newIndex: IndexPath(item: $0.newIndex, section: newIndex),
                    oldValue: $0.old,
                    newValue: $0.new
                )
            }
            
            self.changeCount = self.added.count
                + self.removed.count
                + self.moved.count
                + self.updated.count
        }
        
        struct Added
        {
            let newIndex : IndexPath
            
            let newValue : Item
        }
        
        struct Removed
        {
            let oldIndex : IndexPath
            
            let oldValue : Item
        }
        
        struct Moved
        {
            let oldIndex : IndexPath
            let newIndex : IndexPath
            
            var oldValue : Item
            var newValue : Item
        }
        
        struct Updated
        {
            let oldIndex : IndexPath
            let newIndex : IndexPath
            
            let oldValue : Item
            let newValue : Item
        }
        
        struct NoChange
        {
            let oldIndex : IndexPath
            let newIndex : IndexPath
            
            let oldValue : Item
            let newValue : Item
        }
    }
}


enum MoveDetection
{
    case onlyHinted
    case checkAll
}


struct ArrayDiff<Element>
{
    var added : [Added]
    var removed : [Removed]
    
    var moved : [Moved]
    var updated : [Updated]
    var noChange : [NoChange]
    
    var changeCount : Int
    
    struct Added
    {
        let newIndex : Int
        
        let new : Element
    }
    
    struct Removed
    {
        let oldIndex : Int
        
        let old : Element
    }
    
    struct Moved
    {
        let oldIndex : Int
        let newIndex : Int
        
        let old : Element
        let new : Element
    }
    
    struct Updated
    {
        let oldIndex : Int
        let newIndex : Int
        
        let old : Element
        let new : Element
    }
    
    struct NoChange
    {
        let oldIndex : Int
        let newIndex : Int
        
        let old : Element
        let new : Element
    }
    
    struct Configuration
    {
        var moveDetection : MoveDetection
        
        init(moveDetection : MoveDetection = .checkAll)
        {
            self.moveDetection = moveDetection
        }
    }
    
    init(
        old : [Element],
        new : [Element],
        configuration : Configuration = Configuration(),
        identifierProvider : (Element) -> AnyHashable,
        movedHint : (Element, Element) -> Bool,
        updated : (Element, Element) -> Bool
        )
    {
        // Create diffable collections for fast lookup.
        
        let old = DiffableCollection(elements: old, identifierProvider)
        let new = DiffableCollection(elements: new, identifierProvider)
        
        //
        // Additions and Removals.
        //
        
        let added = new.subtractDifference(from: old)
        let removed = old.subtractDifference(from: new)
        
        self.added = added.map {
            Added(newIndex: $0.index, new: $0.value)
        }
        
        self.removed = removed.map {
            Removed(oldIndex: $0.index, old: $0.value)
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
        sorted += moveHinted.sorted { $0.distance > $1.distance }
        sorted += moveNotHinted.sorted { $0.distance > $1.distance }
        
        for pair in sorted {
            let moved : Bool = {
                let indexChanged = { old.index(of: pair.identifier) != new.index(of: pair.identifier) }
                
                switch configuration.moveDetection {
                case .checkAll: return indexChanged()
                case .onlyHinted: return pair.moveHinted ? indexChanged() : false
                }
            }()
            
            if moved {
                old.move(
                    from: old.index(of: pair.identifier),
                    to: new.index(of: pair.identifier)
                )
                
                self.moved.append(Moved(
                    oldIndex: pair.old.index,
                    newIndex: pair.new.index,
                    old: pair.old.value,
                    new: pair.new.value
                ))
            } else if pair.updated {
                self.updated.append(Updated(
                    oldIndex: pair.old.index,
                    newIndex: pair.new.index,
                    old: pair.old.value,
                    new: pair.new.value
                ))
            } else {
                self.noChange.append(NoChange(
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
        
        self.moved.sort { $0.newIndex > $1.newIndex }
        self.updated.sort { $0.newIndex > $1.newIndex }
        self.noChange.sort { $0.newIndex > $1.newIndex }
        
        self.changeCount = self.added.count
            + self.removed.count
            + self.moved.count
            + self.updated.count
    }
    
    private final class Pair
    {
        let new : DiffContainer<Element>
        let old : DiffContainer<Element>
        
        let identifier : UniqueIdentifier<Element>
        
        let distance : Int
        
        let moveHinted : Bool
        let updated : Bool
        
        init(
            new : DiffContainer<Element>,
            old : DiffContainer<Element>,
            identifier : UniqueIdentifier<Element>,
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
            withNew new : DiffableCollection<Element>,
            old : DiffableCollection<Element>,
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


extension SectionedDiff.SectionChanges
{
    func transform<Mapped>(
        old : [Mapped],
        removed : (Section, Mapped) -> (),
        added : (Section) -> Mapped,
        moved : (Section, Section, SectionedDiff.ItemChanges, inout Mapped) -> (),
        noChange : (Section, Section, SectionedDiff.ItemChanges, inout Mapped) -> ()
        ) -> [Mapped]
    {
        let removes : [Removal<Mapped>] = (self.removed.map({
            removed($0.oldValue, old[$0.oldIndex])
            return .remove(old[$0.oldIndex], $0)
        }) + self.moved.map({
            .move(old[$0.oldIndex], $0)
        })).sorted(by: {$0.oldIndex > $1.oldIndex})
        
        let inserts : [Insertion<Mapped>] = (self.added.map({
            let value = added($0.newValue)
            return .add(value, $0)
        }) + self.moved.map({
            var value = old[$0.oldIndex]
            moved($0.oldValue, $0.newValue, $0.itemChanges, &value)
            return .move(value, $0)
        })).sorted(by: {$0.newIndex < $1.newIndex})
        
        var new = old
        
        removes.forEach {
            new.remove(at: $0.oldIndex)
        }
        
        inserts.forEach {
            new.insert($0.mapped, at: $0.newIndex)
        }
        
        // Now that index changes are complete, perform no change messaging.
        
        self.noChange.forEach {
            var value = new[$0.newIndex]
            noChange($0.oldValue, $0.newValue, $0.itemChanges, &value)
            new[$0.newIndex] = value
        }
        
        return new
    }
    
    private enum Insertion<Mapped>
    {
        case add(Mapped, Added)
        case move(Mapped, Moved)
        
        var mapped : Mapped {
            switch self {
            case .add(let mapped, _): return mapped
            case .move(let mapped, _): return mapped
            }
        }
        
        var newIndex : Int {
            switch self {
            case .add(_, let added): return added.newIndex
            case .move(_, let move): return move.newIndex
            }
        }
    }
    
    private enum Removal<Mapped>
    {
        case remove(Mapped, Removed)
        case move(Mapped, Moved)
        
        var mapped : Mapped {
            switch self {
            case .remove(let mapped, _): return mapped
            case .move(let mapped, _): return mapped
            }
        }
        
        var oldIndex : Int {
            switch self {
            case .remove(_, let remove): return remove.oldIndex
            case .move(_, let move): return move.oldIndex
            }
        }
    }
}


extension SectionedDiff.ItemChanges
{
    func transform<Mapped>(
        old : [Mapped],
        removed : (Item, Mapped) -> (),
        added : (Item) -> Mapped,
        moved : (Item, Item, inout Mapped) -> (),
        updated : (Item, Item, inout Mapped) -> (),
        noChange : (Item, Item, inout Mapped) -> ()
        ) -> [Mapped]
    {
        // Built mutative changes, sort to ensure changes are not destructive.
        
        let removes : [Removal<Mapped>] = (self.removed.map({
            removed($0.oldValue, old[$0.oldIndex.item])
            return .remove(old[$0.oldIndex.item], $0)
        }) + self.moved.map({
            return .move(old[$0.oldIndex.item], $0)
        })).sorted(by: { $0.oldIndex > $1.oldIndex })
        
        let inserts : [Insertion<Mapped>] = (self.added.map({
            let value = added($0.newValue)
            return .add(value, $0)
        }) + self.moved.map({
            var value = old[$0.oldIndex.item]
            moved($0.oldValue, $0.newValue, &value)
            return .move(value, $0)
        })).sorted(by: { $0.newIndex < $1.newIndex })
        
        var new = old
        
        removes.forEach {
            new.remove(at: $0.oldIndex)
        }
        
        inserts.forEach {
            new.insert($0.mapped, at: $0.newIndex)
        }
        
        // Now that index changes are complete, perform update and no change messaging.
        
        self.updated.forEach {
            var value = new[$0.newIndex.item]
            updated($0.oldValue, $0.newValue, &value)
            new[$0.newIndex.item] = value
        }
        
        self.noChange.forEach {
            var value = new[$0.newIndex.item]
            noChange($0.oldValue, $0.newValue, &value)
            new[$0.newIndex.item] = value
        }
        
        return new
    }
    
    private enum Insertion<Mapped>
    {
        case add(Mapped, Added)
        case move(Mapped, Moved)
        
        var mapped : Mapped {
            switch self {
            case .add(let mapped, _): return mapped
            case .move(let mapped, _): return mapped
            }
        }
        
        var newIndex : Int {
            switch self {
            case .add(_, let added): return added.newIndex.item
            case .move(_, let move): return move.newIndex.item
            }
        }
    }
    
    private enum Removal<Mapped>
    {
        case remove(Mapped, Removed)
        case move(Mapped, Moved)
        
        var mapped : Mapped {
            switch self {
            case .remove(let mapped, _): return mapped
            case .move(let mapped, _): return mapped
            }
        }
    
        var oldIndex : Int {
            switch self {
            case .remove(_, let remove): return remove.oldIndex.item
            case .move(_, let move): return move.oldIndex.item
            }
        }
    }
}

fileprivate class DiffContainer<Value>
{
    let identifier : UniqueIdentifier<Value>
    let value : Value
    let index : Int
    
    init(
        value : Value,
        index : Int,
        identifierProvider : (Value) -> AnyHashable,
        identifierFactory : UniqueIdentifier<Value>.Factory
        )
    {
        self.value = value
        self.index = index
        
        self.identifier = identifierFactory.identifier(for: identifierProvider(self.value))
    }
    
    static func containers(with elements : [Value], identifierProvider : (Value) -> AnyHashable) -> [DiffContainer]
    {
        let identifierFactory = UniqueIdentifier<Value>.Factory()
        identifierFactory.reserveCapacity(elements.count)
        
        return elements.mapWithIndex { index, value in
            return DiffContainer(
                value: value,
                index: index,
                identifierProvider: identifierProvider,
                identifierFactory: identifierFactory
            )
        }
    }
}


private final class UniqueIdentifier<Type> : Hashable
{
    private let base : AnyHashable
    private let modifier : Int
    
    private let hash : Int
    
    init(base : AnyHashable, modifier : Int)
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
        private var counts : [AnyHashable:Int] = [:]
        
        func reserveCapacity(_ minimumCapacity : Int)
        {
            self.counts.reserveCapacity(minimumCapacity)
        }
        
        func identifier(for base : AnyHashable) -> UniqueIdentifier
        {
            let count = self.counts[base, default:1]
            
            self.counts[base] = (count + 1)
            
            return UniqueIdentifier(base: base, modifier: count)
        }
    }
}

private final class DiffableCollection<Value>
{
    private(set) var containers : [DiffContainer<Value>]
    private var containersByIdentifier : [UniqueIdentifier<Value>:DiffContainer<Value>]
    
    init(elements : [Value], _ identifierProvider : (Value) -> AnyHashable)
    {
        self.identifierContainerIndexes.reserveCapacity(elements.count)
        
        self.containers = DiffContainer.containers(with: elements, identifierProvider: identifierProvider)
        
        self.containersByIdentifier = self.containers.toUniqueDictionary { _, container in
            return (container.identifier, container)
        }
    }
    
    // MARK: Querying The Collection
    
    func index(of identifier : UniqueIdentifier<Value>) -> Int
    {
        self.generateIndexLookupsIfNeeded()
        
        return self.identifierContainerIndexes[identifier]!
    }
    
    func contains(identifier : UniqueIdentifier<Value>) -> Bool
    {
        return self.containersByIdentifier[identifier] != nil
    }
    
    func container(for identifier : UniqueIdentifier<Value>) -> DiffContainer<Value>
    {
        return self.containersByIdentifier[identifier]!
    }
    
    func difference(from other : DiffableCollection) -> [DiffContainer<Value>]
    {
        return self.containers.compactMap { element in
            if other.contains(identifier: element.identifier) == false {
                return element
            } else {
                return nil
            }
        }
    }
    
    func subtractDifference(from other : DiffableCollection) -> [DiffContainer<Value>]
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
    
    func remove(containers : [DiffContainer<Value>])
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
    
    private var identifierContainerIndexes : [UniqueIdentifier<Value>:Int] = [:]
    
    private func resetIndexLookups()
    {
        self.identifierContainerIndexes.removeAll(keepingCapacity: true)
    }
    
    private func generateIndexLookupsIfNeeded()
    {
        guard self.identifierContainerIndexes.isEmpty else {
            return
        }
        
        for (index, container) in self.containers.enumerated() {
            self.identifierContainerIndexes[container.identifier] = index
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
                fatalError("Existing entry for key '\(key)' not allowed for unique dictionaries.")
            }
            
            dictionary[key] = value
        }
        
        return dictionary
    }
}
