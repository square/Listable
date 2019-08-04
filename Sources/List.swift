//
//  List.swift
//  Listable
//
//  Created by Kyle Van Essen on 7/1/19.
//

import Foundation


public protocol AnyList
{
    var anyItems : [Any] { get }
}

public struct List<Element:Identifiable> : AnyList
{
    public let identifier : Identifier<List>
    
    public let validations : [Change.Validation] = []
    
    private(set) public var items : [Element]
    
    // MARK: AnyList
    
    public var anyItems : [Any] {
        return self.items
    }
    
    public func canPerform(change : Change) -> Change.Validation.Error?
    {
        switch change {
        case .move(let move): return canPerform(move: move)
        case .insert(let insert): return canPerform(insert: insert)
        case .remove(let remove): return canPerform(remove: remove)
        }
    }
    
    public func canPerform(move : Change.Move) -> Change.Validation.Error?
    {
        return nil
    }
    
    public func canPerform(insert : Change.Insert) -> Change.Validation.Error?
    {
        return nil
    }
    
    public func canPerform(remove : Change.Remove) -> Change.Validation.Error?
    {
        return nil
    }
    
    public mutating func perform(change : Change) throws
    {
        fatalError()
    }
    
    // MARK: Changes
    
    public enum Change
    {
        case move(Move)
        case remove(Remove)
        case insert(Insert)
        
        public struct Move
        {
            let from : Int
            let to : Int
        }
        
        public struct Remove
        {
            let from : Int
        }
        
        public struct Insert
        {
            let to : Int
            
            let element : Element
        }
        
        public enum Validation
        {
            public typealias Custom = (List, Element) throws -> ()
            
            case immutable
            
            case noRemovals
            case noInsertions
            
            case constraintedToCount(Range<Int>)
            
            case toSpecific([Identifier<List>])
            case fromSpecific([Identifier<List>])
            
            case custom(Custom)
            
            public struct Error : Swift.Error
            {
                public let failed : [Validation]
            }
        }
    }
}
