//
//  KeyPathEquatable.swift
//  Listable
//
//  Created by Kyle Van Essen on 3/9/20.
//

import Foundation


public protocol KeyPathEquivalency
{
    //
    // Base Implementation
    //
    
    func isEquivalent(to other : Self, using keyPaths : (inout EquivalencyDescription<Self>) -> ()) -> Bool
    
    //
    // Shortcuts
    //
    
    func isEquivalent<
        Key1:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>
    ) -> Bool
    
    func isEquivalent<
        Key1:Equatable,
        Key2:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>,
        _ key2 : KeyPath<Self,Key2>
    ) -> Bool
    
    func isEquivalent<
        Key1:Equatable,
        Key2:Equatable,
        Key3:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>,
        _ key2 : KeyPath<Self,Key2>,
        _ key3 : KeyPath<Self,Key3>
    ) -> Bool
    
    func isEquivalent<
        Key1:Equatable,
        Key2:Equatable,
        Key3:Equatable,
        Key4:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>,
        _ key2 : KeyPath<Self,Key2>,
        _ key3 : KeyPath<Self,Key3>,
        _ key4 : KeyPath<Self,Key4>
    ) -> Bool
    
    func isEquivalent<
        Key1:Equatable,
        Key2:Equatable,
        Key3:Equatable,
        Key4:Equatable,
        Key5:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>,
        _ key2 : KeyPath<Self,Key2>,
        _ key3 : KeyPath<Self,Key3>,
        _ key4 : KeyPath<Self,Key4>,
        _ key5 : KeyPath<Self,Key5>
    ) -> Bool
    
    func isEquivalent<
        Key1:Equatable,
        Key2:Equatable,
        Key3:Equatable,
        Key4:Equatable,
        Key5:Equatable,
        Key6:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>,
        _ key2 : KeyPath<Self,Key2>,
        _ key3 : KeyPath<Self,Key3>,
        _ key4 : KeyPath<Self,Key4>,
        _ key5 : KeyPath<Self,Key5>,
        _ key6 : KeyPath<Self,Key6>
    ) -> Bool
    
    func isEquivalent<
        Key1:Equatable,
        Key2:Equatable,
        Key3:Equatable,
        Key4:Equatable,
        Key5:Equatable,
        Key6:Equatable,
        Key7:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>,
        _ key2 : KeyPath<Self,Key2>,
        _ key3 : KeyPath<Self,Key3>,
        _ key4 : KeyPath<Self,Key4>,
        _ key5 : KeyPath<Self,Key5>,
        _ key6 : KeyPath<Self,Key6>,
        _ key7 : KeyPath<Self,Key7>
    ) -> Bool
    
    func isEquivalent<
        Key1:Equatable,
        Key2:Equatable,
        Key3:Equatable,
        Key4:Equatable,
        Key5:Equatable,
        Key6:Equatable,
        Key7:Equatable,
        Key8:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>,
        _ key2 : KeyPath<Self,Key2>,
        _ key3 : KeyPath<Self,Key3>,
        _ key4 : KeyPath<Self,Key4>,
        _ key5 : KeyPath<Self,Key5>,
        _ key6 : KeyPath<Self,Key6>,
        _ key7 : KeyPath<Self,Key7>,
        _ key8 : KeyPath<Self,Key8>
    ) -> Bool
    
    func isEquivalent<
        Key1:Equatable,
        Key2:Equatable,
        Key3:Equatable,
        Key4:Equatable,
        Key5:Equatable,
        Key6:Equatable,
        Key7:Equatable,
        Key8:Equatable,
        Key9:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>,
        _ key2 : KeyPath<Self,Key2>,
        _ key3 : KeyPath<Self,Key3>,
        _ key4 : KeyPath<Self,Key4>,
        _ key5 : KeyPath<Self,Key5>,
        _ key6 : KeyPath<Self,Key6>,
        _ key7 : KeyPath<Self,Key7>,
        _ key8 : KeyPath<Self,Key8>,
        _ key9 : KeyPath<Self,Key9>
    ) -> Bool
    
    func isEquivalent<
        Key1:Equatable,
        Key2:Equatable,
        Key3:Equatable,
        Key4:Equatable,
        Key5:Equatable,
        Key6:Equatable,
        Key7:Equatable,
        Key8:Equatable,
        Key9:Equatable,
        Key10:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>,
        _ key2 : KeyPath<Self,Key2>,
        _ key3 : KeyPath<Self,Key3>,
        _ key4 : KeyPath<Self,Key4>,
        _ key5 : KeyPath<Self,Key5>,
        _ key6 : KeyPath<Self,Key6>,
        _ key7 : KeyPath<Self,Key7>,
        _ key8 : KeyPath<Self,Key8>,
        _ key9 : KeyPath<Self,Key9>,
        _ key10 : KeyPath<Self,Key10>
    ) -> Bool
}


public extension KeyPathEquivalency
{
    func isEquivalent(to other : Self, using keyPaths : (inout EquivalencyDescription<Self>) -> ()) -> Bool
    {
        var description = EquivalencyDescription(self, other)
        
        keyPaths(&description)
        
        return description.isEqual
    }
    
    func isEquivalent<
        Key1:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>
    ) -> Bool
    {
        return self.isEquivalent(to: other) {
            $0.add(key1)
        }
    }
    
    func isEquivalent<
        Key1:Equatable,
        Key2:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>,
        _ key2 : KeyPath<Self,Key2>
    ) -> Bool
    {
        return self.isEquivalent(to: other) {
            $0.add(key1)
            $0.add(key2)
        }
    }
    
    func isEquivalent<
        Key1:Equatable,
        Key2:Equatable,
        Key3:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>,
        _ key2 : KeyPath<Self,Key2>,
        _ key3 : KeyPath<Self,Key3>
    ) -> Bool
    {
        return self.isEquivalent(to: other) {
            $0.add(key1)
            $0.add(key2)
            $0.add(key3)
        }
    }
    
    func isEquivalent<
        Key1:Equatable,
        Key2:Equatable,
        Key3:Equatable,
        Key4:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>,
        _ key2 : KeyPath<Self,Key2>,
        _ key3 : KeyPath<Self,Key3>,
        _ key4 : KeyPath<Self,Key4>
    ) -> Bool
    {
        return self.isEquivalent(to: other) {
            $0.add(key1)
            $0.add(key2)
            $0.add(key3)
            $0.add(key4)
        }
    }
    
    func isEquivalent<
        Key1:Equatable,
        Key2:Equatable,
        Key3:Equatable,
        Key4:Equatable,
        Key5:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>,
        _ key2 : KeyPath<Self,Key2>,
        _ key3 : KeyPath<Self,Key3>,
        _ key4 : KeyPath<Self,Key4>,
        _ key5 : KeyPath<Self,Key5>
    ) -> Bool
    {
        return self.isEquivalent(to: other) {
            $0.add(key1)
            $0.add(key2)
            $0.add(key3)
            $0.add(key4)
            $0.add(key5)
        }
    }
    
    func isEquivalent<
        Key1:Equatable,
        Key2:Equatable,
        Key3:Equatable,
        Key4:Equatable,
        Key5:Equatable,
        Key6:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>,
        _ key2 : KeyPath<Self,Key2>,
        _ key3 : KeyPath<Self,Key3>,
        _ key4 : KeyPath<Self,Key4>,
        _ key5 : KeyPath<Self,Key5>,
        _ key6 : KeyPath<Self,Key6>
    ) -> Bool
    {
        return self.isEquivalent(to: other) {
            $0.add(key1)
            $0.add(key2)
            $0.add(key3)
            $0.add(key4)
            $0.add(key5)
            $0.add(key6)
        }
    }
    
    func isEquivalent<
        Key1:Equatable,
        Key2:Equatable,
        Key3:Equatable,
        Key4:Equatable,
        Key5:Equatable,
        Key6:Equatable,
        Key7:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>,
        _ key2 : KeyPath<Self,Key2>,
        _ key3 : KeyPath<Self,Key3>,
        _ key4 : KeyPath<Self,Key4>,
        _ key5 : KeyPath<Self,Key5>,
        _ key6 : KeyPath<Self,Key6>,
        _ key7 : KeyPath<Self,Key7>
    ) -> Bool
    {
        return self.isEquivalent(to: other) {
            $0.add(key1)
            $0.add(key2)
            $0.add(key3)
            $0.add(key4)
            $0.add(key5)
            $0.add(key6)
            $0.add(key7)
        }
    }
    
    func isEquivalent<
        Key1:Equatable,
        Key2:Equatable,
        Key3:Equatable,
        Key4:Equatable,
        Key5:Equatable,
        Key6:Equatable,
        Key7:Equatable,
        Key8:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>,
        _ key2 : KeyPath<Self,Key2>,
        _ key3 : KeyPath<Self,Key3>,
        _ key4 : KeyPath<Self,Key4>,
        _ key5 : KeyPath<Self,Key5>,
        _ key6 : KeyPath<Self,Key6>,
        _ key7 : KeyPath<Self,Key7>,
        _ key8 : KeyPath<Self,Key8>
    ) -> Bool
    {
        return self.isEquivalent(to: other) {
            $0.add(key1)
            $0.add(key2)
            $0.add(key3)
            $0.add(key4)
            $0.add(key5)
            $0.add(key6)
            $0.add(key7)
            $0.add(key8)
        }
    }
    
    func isEquivalent<
        Key1:Equatable,
        Key2:Equatable,
        Key3:Equatable,
        Key4:Equatable,
        Key5:Equatable,
        Key6:Equatable,
        Key7:Equatable,
        Key8:Equatable,
        Key9:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>,
        _ key2 : KeyPath<Self,Key2>,
        _ key3 : KeyPath<Self,Key3>,
        _ key4 : KeyPath<Self,Key4>,
        _ key5 : KeyPath<Self,Key5>,
        _ key6 : KeyPath<Self,Key6>,
        _ key7 : KeyPath<Self,Key7>,
        _ key8 : KeyPath<Self,Key8>,
        _ key9 : KeyPath<Self,Key9>
    ) -> Bool
    {
        return self.isEquivalent(to: other) {
            $0.add(key1)
            $0.add(key2)
            $0.add(key3)
            $0.add(key4)
            $0.add(key5)
            $0.add(key6)
            $0.add(key7)
            $0.add(key8)
            $0.add(key9)
        }
    }
    
    func isEquivalent<
        Key1:Equatable,
        Key2:Equatable,
        Key3:Equatable,
        Key4:Equatable,
        Key5:Equatable,
        Key6:Equatable,
        Key7:Equatable,
        Key8:Equatable,
        Key9:Equatable,
        Key10:Equatable
        >(
        to other : Self,
        using key1 : KeyPath<Self,Key1>,
        _ key2 : KeyPath<Self,Key2>,
        _ key3 : KeyPath<Self,Key3>,
        _ key4 : KeyPath<Self,Key4>,
        _ key5 : KeyPath<Self,Key5>,
        _ key6 : KeyPath<Self,Key6>,
        _ key7 : KeyPath<Self,Key7>,
        _ key8 : KeyPath<Self,Key8>,
        _ key9 : KeyPath<Self,Key9>,
        _ key10 : KeyPath<Self,Key10>
    ) -> Bool
    {
        return self.isEquivalent(to: other) {
            $0.add(key1)
            $0.add(key2)
            $0.add(key3)
            $0.add(key4)
            $0.add(key5)
            $0.add(key6)
            $0.add(key7)
            $0.add(key8)
            $0.add(key9)
            $0.add(key10)
        }
    }
}


public struct EquivalencyDescription<Value>
{
    public let lhs : Value
    public let rhs : Value
    
    public private(set) var isEqual : Bool
        
    init(_ lhs : Value, _ rhs : Value)
    {
        self.lhs = lhs
        self.rhs = rhs
        
        self.isEqual = true
    }
    
    mutating public func add<KeyType:Equatable>(_ keyPath : KeyPath<Value, KeyType>)
    {
        guard self.isEqual else {
            return
        }
        
        let value1 = self.rhs[keyPath: keyPath]
        let value2 = self.lhs[keyPath: keyPath]
        
        self.isEqual = self.isEqual && value1 == value2
    }
}
