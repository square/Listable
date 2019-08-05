//
//  TableViewSource.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/4/19.
//

import Foundation


public protocol TableViewSource
{
    associatedtype Input:Equatable
    
    func content(with state : State<Input>, in table : inout TableView.ContentBuilder)
}

internal protocol TableViewSourcePresenter
{
    func discard()
    
    func content() -> TableView.Content
}

internal extension TableView
{
    final class SourcePresenter<Source:TableViewSource> : TableViewSourcePresenter
    {
        let source : Source
        
        var value : Source.Input {
            get { return self.state.value }
            set { self.state.value = newValue }
        }
        
        typealias DidChange = () -> ()
        var didChange : DidChange?
        
        private var state : State<Source.Input>
        
        init(initial : Source.Input, source : Source, didChange : @escaping DidChange)
        {
            self.source = source

            self.state = State(initial: initial)
            
            self.didChange = didChange
        }
        
        // MARK: TableViewSourceController
        
        func discard()
        {
            self.didChange = nil
            
            self.state.discard()
        }
        
        internal func content() -> TableView.Content
        {
            // Throw out old state object so changes do not leak between render passes.
            
            self.state.discard()
            
            self.state = State(initial: self.state.value)
            self.state.didChange = self.didChange
            
            // Create and return new content.
            
            var builder = TableView.ContentBuilder()
            
            self.source.content(with: self.state, in: &builder)
            
            return builder.content
        }
    }
}

public final class ValueAccess<Value:Equatable>
{
    public var value : Value {
        get { return self.get() }
        set { self.set(newValue) }
    }
    
    private let get : () -> Value
    private let set : (Value) -> ()
    
    internal init(get : @escaping () -> Value, set : @escaping (Value) -> ())
    {
        self.get = get
        self.set = set
    }
}

public final class State<Value:Equatable>
{
    public var value : Value {
        didSet {
            guard self.value != oldValue else { return }
            
            self.didChange?()
        }
    }
    
    public func set(_ block : (inout Value) -> ())
    {
        var new = self.value
        
        block(&new)
        
        self.value = new
    }
    
    public init(initial value : Value)
    {
        self.value = value
        
        self.didChange = nil
    }
    
    public func discard()
    {
        self.didChange = nil
    }
    
    public typealias DidChange = () -> ()
    public var didChange : DidChange?
}


public extension TableView
{
    final class StaticSource : TableViewSource
    {
        public struct Input : Equatable {}
        
        public typealias Build = (inout TableView.ContentBuilder) -> ()
        
        public let builder : TableView.ContentBuilder
        
        public init(_ build : @escaping Build)
        {
            var builder = TableView.ContentBuilder()
            build(&builder)
            
            self.builder = builder
        }
        
        public func content(with state : State<Input>, in table : inout TableView.ContentBuilder)
        {
            table = self.builder
        }
    }
}
