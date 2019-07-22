//
//  Diff.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/16/19.
//

import Foundation


public struct SectionedDiff<Section, Row>
{
    public let old : [Section]
    public let new : [Section]
    
    public let changes : SectionChanges
    
    public init(old : [Section], new: [Section], configuration : Configuration)
    {
        // Set up base state.
        
        self.old = old
        self.new = new
        
        self.changes = SectionChanges(
            old: old,
            new: new,
            configuration: configuration
        )
    }
    
    public static func calculate(on queue : DispatchQueue, old : [Section], new: [Section], configuration : Configuration, completion : @escaping (SectionedDiff) -> ())
    {
        queue.async {
            let diff = SectionedDiff(old: old, new: new, configuration: configuration)
            completion(diff)
        }
    }
    
    public struct Configuration
    {
        public var moveDetection : MoveDetection
        
        public var section : SectionProviders
        public var row : RowProviders
        
        public init(moveDetection : MoveDetection = .checkAll, section : SectionProviders, row : RowProviders)
        {
            self.moveDetection = moveDetection
            
            self.section = section
            self.row = row
        }
        
        public struct SectionProviders
        {
            public var identifier : (Section) -> AnyHashable
            
            public var rows : (Section) -> [Row]
            
            public var updated : (Section, Section) -> Bool
            public var movedHint : (Section, Section) -> Bool
            
            public init(
                identifier : @escaping (Section) -> AnyHashable,
                rows : @escaping (Section) -> [Row],
                updated : @escaping (Section, Section) -> Bool,
                movedHint : @escaping (Section, Section) -> Bool
            )
            {
                self.identifier = identifier
                self.rows = rows
                self.updated = updated
                self.movedHint = movedHint
            }
        }
        
        public struct RowProviders
        {
            public var identifier : (Row) -> AnyHashable
            
            public var updated : (Row, Row) -> Bool
            public var movedHint : (Row, Row) -> Bool
            
            public init(
                identifier : @escaping (Row) -> AnyHashable,
                updated : @escaping (Row, Row) -> Bool,
                movedHint : @escaping (Row, Row) -> Bool
            )
            {
                self.identifier = identifier
                self.updated = updated
                self.movedHint = movedHint
            }
        }
    }
    
    public struct SectionChanges
    {
        public var added : [Added]
        public var removed : [Removed]
        
        public var moved : [Moved]
        public var updated : [Updated]
        public var noChange : [NoChange]
        
        public var sectionsChangeCount : Int
        public var rowsChangeCount : Int
        
        private let diff : ArrayDiff<Section>
        
        public init(old : [Section], new : [Section], configuration : Configuration)
        {
            self.diff = ArrayDiff(
                old: old,
                new: new,
                configuration: .init(moveDetection: configuration.moveDetection),
                identifierProvider: { configuration.section.identifier($0) },
                movedHint: { configuration.section.movedHint($0, $1) },
                updated: { configuration.section.updated($0, $1) }
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
                    
                    rowChanges: SectionedDiff.RowChanges(
                        old: $0.old,
                        new: $0.new,
                        configuration: configuration
                    )
                )
            }
            
            self.updated = diff.updated.map {
                Updated(
                    oldIndex: $0.oldIndex,
                    newIndex: $0.newIndex,
                    oldValue: $0.old,
                    newValue: $0.new,
                    
                    rowChanges: SectionedDiff.RowChanges(
                        old: $0.old,
                        new: $0.new,
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
                    
                    rowChanges: SectionedDiff.RowChanges(
                        old: $0.old,
                        new: $0.new,
                        configuration: configuration
                    )
                )
            }
            
            self.sectionsChangeCount = self.added.count
                + self.removed.count
                + self.moved.count
                + self.updated.count
            
            self.rowsChangeCount =
                self.moved.reduce(0, { $0 + $1.rowChanges.changeCount }) +
                self.updated.reduce(0, { $0 + $1.rowChanges.changeCount }) +
                self.noChange.reduce(0, { $0 + $1.rowChanges.changeCount })
        }
        
        public struct Added
        {
            let newIndex : Int
            
            let newValue : Section
        }
        
        public struct Removed
        {
            let oldIndex : Int
            
            let oldValue : Section
        }
        
        public struct Moved
        {
            let oldIndex : Int
            let newIndex : Int
            
            let oldValue : Section
            let newValue : Section
            
            let rowChanges : RowChanges
        }
        
        public struct Updated
        {
            let oldIndex : Int
            let newIndex : Int
            
            let oldValue : Section
            let newValue : Section
            
            let rowChanges : RowChanges
        }
        
        public struct NoChange
        {
            let oldIndex : Int
            let newIndex : Int
            
            let oldValue : Section
            let newValue : Section
            
            let rowChanges : RowChanges
        }
    }
    
    public struct RowChanges
    {
        public var added : [Added]
        public var removed : [Removed]
        
        public var moved : [Moved]
        public var updated : [Updated]
        public var noChange : [NoChange]
        
        public var changeCount : Int
        
        public let diff : ArrayDiff<Row>

        public init(old : Section, new : Section, configuration: Configuration)
        {
            self.init(
                old: configuration.section.rows(old),
                new: configuration.section.rows(new),
                configuration: configuration
            )
        }
        
        public init(old : [Row], new : [Row], configuration : Configuration)
        {
            self.diff = ArrayDiff(
                old: old,
                new: new,
                configuration: .init(moveDetection: configuration.moveDetection),
                identifierProvider: { configuration.row.identifier($0) },
                movedHint: { configuration.row.movedHint($0, $1) },
                updated: { configuration.row.updated($0, $1) }
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
                    newValue: $0.new
                )
            }
            
            self.updated = diff.updated.map {
                Updated(
                    oldIndex: $0.oldIndex,
                    newIndex: $0.newIndex,
                    oldValue: $0.old,
                    newValue: $0.new
                )
            }
            
            self.noChange = diff.noChange.map {
                NoChange(
                    oldIndex: $0.oldIndex,
                    newIndex: $0.newIndex,
                    oldValue: $0.old,
                    newValue: $0.new
                )
            }
            
            self.changeCount = self.added.count
                + self.removed.count
                + self.moved.count
                + self.updated.count
        }
        
        public struct Added
        {
            let newIndex : Int
            
            let newValue : Row
        }
        
        public struct Removed
        {
            let oldIndex : Int
            
            let oldValue : Row
        }
        
        public struct Moved
        {
            var oldIndex : Int
            var newIndex : Int
            
            var oldValue : Row
            var newValue : Row
        }
        
        public struct Updated
        {
            var oldIndex : Int
            var newIndex : Int
            
            var oldValue : Row
            var newValue : Row
        }
        
        public struct NoChange
        {
            var oldIndex : Int
            var newIndex : Int
            
            var oldValue : Row
            var newValue : Row
        }
    }
}


public enum MoveDetection
{
    case onlyHinted
    case checkAll
}


public struct ArrayDiff<Element>
{
    public var added : [Added]
    public var removed : [Removed]
    
    public var moved : [Moved]
    public var updated : [Updated]
    public var noChange : [NoChange]
    
    public var changeCount : Int
    
    public struct Added
    {
        let newIndex : Int
        
        let new : Element
    }
    
    public struct Removed
    {
        let oldIndex : Int
        
        let old : Element
    }
    
    public struct Moved
    {
        let oldIndex : Int
        let newIndex : Int
        
        let old : Element
        let new : Element
    }
    
    public struct Updated
    {
        let oldIndex : Int
        let newIndex : Int
        
        let old : Element
        let new : Element
    }
    
    public struct NoChange
    {
        let oldIndex : Int
        let newIndex : Int
        
        let old : Element
        let new : Element
    }
    
    public struct Configuration
    {
        var moveDetection : MoveDetection
        
        public init(moveDetection : MoveDetection = .checkAll)
        {
            self.moveDetection = moveDetection
        }
    }
    
    public init(
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
        
        // TODO ARE THESE ORDERS RIGHT?
        
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
    
    private class Pair
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
                let oldContainer = old.containersByIdentifier[identifier]!
                
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


public extension SectionedDiff.SectionChanges
{
    func transform<Mapped>(
        old : [Mapped],
        removed : (Section, Mapped) -> (),
        added : (Section) -> Mapped,
        moved : (Section, Section, SectionedDiff.RowChanges, inout Mapped) -> (),
        updated : (Section, Section, SectionedDiff.RowChanges, inout Mapped) -> (),
        noChange : (Section, Section, SectionedDiff.RowChanges, inout Mapped) -> ()
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
            moved($0.oldValue, $0.newValue, $0.rowChanges, &value)
            return .move(value, $0)
        })).sorted(by: {$0.newIndex < $1.newIndex})
        
        var new = old
        
        removes.forEach {
            new.remove(at: $0.oldIndex)
        }
        
        inserts.forEach {
            new.insert($0.mapped, at: $0.newIndex)
        }
        
        // Now that index changes are complete, perform update and no change messaging.
        
        self.updated.forEach {
            var value = new[$0.newIndex]
            updated($0.oldValue, $0.newValue, $0.rowChanges, &value)
            new[$0.newIndex] = value
        }
        
        self.noChange.forEach {
            var value = new[$0.newIndex]
            updated($0.oldValue, $0.newValue, $0.rowChanges, &value)
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


public extension SectionedDiff.RowChanges
{
    func transform<Mapped>(
        old : [Mapped],
        removed : (Row, Mapped) -> (),
        added : (Row) -> Mapped,
        moved : (Row, Row, inout Mapped) -> (),
        updated : (Row, Row, inout Mapped) -> (),
        noChange : (Row, Row, inout Mapped) -> ()
        ) -> [Mapped]
    {
        // Built mutative changes, sort to ensure changes are not destructive.
        
        let removes : [Removal<Mapped>] = (self.removed.map({
            removed($0.oldValue, old[$0.oldIndex])
            return .remove(old[$0.oldIndex], $0)
        }) + self.moved.map({
            .move(old[$0.oldIndex], $0)
        })).sorted(by: { $0.oldIndex > $1.oldIndex })
        
        let inserts : [Insertion<Mapped>] = (self.added.map({
            let value = added($0.newValue)
            return .add(value, $0)
        }) + self.moved.map({
            var value = old[$0.oldIndex]
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
            var value = new[$0.newIndex]
            updated($0.oldValue, $0.newValue, &value)
            new[$0.newIndex] = value
        }
        
        self.noChange.forEach {
            var value = new[$0.newIndex]
            updated($0.oldValue, $0.newValue, &value)
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


private class UniqueIdentifier<Type> : Hashable
{
    private let base : AnyHashable
    private let modifier : Int
    
    init(base : AnyHashable, modifier : Int)
    {
        self.base = base
        self.modifier = modifier
    }
    
    static func == (lhs: UniqueIdentifier, rhs: UniqueIdentifier) -> Bool
    {
        return lhs.base == rhs.base && lhs.modifier == rhs.modifier
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(self.base)
        hasher.combine(self.modifier)
    }
    
    final class Factory
    {
        private var counts : [AnyHashable:Int] = [:]
        
        func identifier(for base : AnyHashable) -> UniqueIdentifier
        {
            let count = self.counts[base, default:1]
            
            self.counts[base] = (count + 1)
            
            return UniqueIdentifier(base: base, modifier: count)
        }
    }
}

private class DiffableCollection<Value>
{
    private(set) var containers : [DiffContainer<Value>]
    private(set) var containersByIdentifier : [UniqueIdentifier<Value>:DiffContainer<Value>]
    
    init(elements : [Value], _ identifierProvider : (Value) -> AnyHashable)
    {
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
    
    // MARK: Passthrough Mutating Methods
    
    func remove(elements : [DiffContainer<Value>])
    {
        self.remove(byIdentifier: elements.map { $0.identifier })
    }
    
    func subtractDifference(from other : DiffableCollection) -> [DiffContainer<Value>]
    {
        let difference = self.difference(from: other)
        
        self.remove(elements: difference)
        
        return difference
    }
    
    @discardableResult
    func remove(byIdentifier identifier : UniqueIdentifier<Value>) -> DiffContainer<Value>?
    {
        let removed = self.remove(byIdentifier: [identifier])
        
        return removed.first
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
    
    @discardableResult
    func remove(byIdentifier identifiers : [UniqueIdentifier<Value>]) -> [DiffContainer<Value>]
    {
        let containers : [DiffContainer<Value>] = identifiers.map {
            return self.containersByIdentifier.removeValue(forKey: $0)!
        }
        
        let indexes = containers.map({
            return self.index(of: $0.identifier)
        }).sorted(by: { $0 > $1 })
        
        indexes.forEach {
            self.containers.remove(at: $0)
        }
        
        self.resetIndexLookups()
        
        return containers
    }
    
    // MARK: Private Methods
    
    private var identifierContainerIndexes : [UniqueIdentifier<Value>:Int] = [:]
    
    private func resetIndexLookups()
    {
        self.identifierContainerIndexes = [:]
    }
    
    private func generateIndexLookupsIfNeeded()
    {
        guard self.identifierContainerIndexes.count == 0 else {
            return
        }
        
        self.identifierContainerIndexes = self.containers.toUniqueDictionary { index, container in
            return (container.identifier, index)
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
    func mapWithIndex<Mapped>(_ block : (Int, Element) throws -> Mapped) rethrows -> [Mapped]
    {
        var mapped = [Mapped]()
        
        for index in 0..<self.count {
            mapped.append(try block(index, self[index]))
        }
        
        return mapped
    }
    
    func toUniqueDictionary<Key:Hashable, Value>(_ block : (Int, Element) throws -> (Key, Value)) rethrows -> Dictionary<Key,Value>
    {
        var dictionary = Dictionary<Key,Value>()
        
        for (index, element) in self.enumerated() {
            let (key,value) = try block(index, element)
            
            guard dictionary[key] == nil else {
                fatalError("Existing entry for key '\(key)' not allowed for unique dictionaries.")
            }
            
            dictionary[key] = value
        }
        
        return dictionary
    }
}
