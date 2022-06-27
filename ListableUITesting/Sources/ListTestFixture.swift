//
//  ListTestFixture.swift
//  ListableUITesting
//
//  Created by Kyle Van Essen on 12/30/21.
//

import Foundation


public final class ListTestFixture {
    
    public private(set) var events : RecordedEvents = .init()
    
    public func removeAllEvents() {
        events.removeAll()
    }
}


extension ListTestFixture {
    
    public struct RecordedEvents {
        public private(set) var all : [AnyListTestFixtureEvent] = []
        
        public mutating func removeAll() {
            all.removeAll()
        }
        
        public func filtered(to kindPaths : Set<KeyPath<EventKind.Type, EventKind>>) -> [AnyListTestFixtureEvent] {
            
            let included = kindPaths.map { path in
                EventKind.self[keyPath: path]
            }
            
            return all.filter { event in
                included.contains(event.kind)
            }
        }
    }
    
    public struct Event<Data:Hashable> : AnyListTestFixtureEvent {

        public let kind : EventKind
        
        public let value : Data
    }
    
    public struct EventKind : Hashable {
        
        public let type : Any.Type
        public let name : String
        
        public init<Represented>(type: Represented.Type, name: String) {
            self.type = type
            self.name = name
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.type == rhs.type && lhs.name == rhs.name
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(type))
            hasher.combine(name)
        }
    }
}

public protocol AnyListTestFixtureEvent {
    
    var kind : ListTestFixture.EventKind { get }
    
    
}
