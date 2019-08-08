//
//  TableViewSource.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/4/19.
//

import Foundation


public protocol TableViewSource
{
    associatedtype State:Equatable
    
    func content(with state : SourceState<State>, table : inout TableView.ContentBuilder)
    
    func content(with state : SourceState<State>) -> TableView.Content
}

public extension TableViewSource
{
    func content(with state : SourceState<State>) -> TableView.Content
    {
        return TableView.ContentBuilder.build { table in
            self.content(with: state, table: &table)
        }
    }
}

internal protocol TableViewSourcePresenter
{
    func discard()
    
    func reloadContent() -> TableView.Content
}

internal extension TableView
{
    final class SourcePresenter<Source:TableViewSource> : TableViewSourcePresenter
    {
        let source : Source
        
        var state : Source.State {
            get { return self.sourceState.value }
            set { self.sourceState.value = newValue }
        }
        
        typealias DidChange = () -> ()
        var didChange : DidChange?
        
        private var sourceState : SourceState<Source.State>
        
        init(initial : Source.State, source : Source, didChange : @escaping DidChange = {})
        {
            self.source = source

            self.sourceState = SourceState(initial: initial)
            
            self.didChange = didChange
        }
        
        // MARK: TableViewSourceController
        
        func discard()
        {
            self.didChange = nil
            
            self.sourceState.discard()
        }
        
        internal func reloadContent() -> TableView.Content
        {
            // Throw out old state object so changes do not leak between render passes.
            
            self.sourceState.discard()
            
            self.sourceState = SourceState(initial: self.sourceState.value)
            self.sourceState.didChange = self.didChange
            
            // Create and return new content.
            
            return self.source.content(with: self.sourceState)
        }
    }
}

public final class StateAccessor<State:Equatable>
{
    public var value : State {
        get { return self.get() }
        set { self.set(newValue) }
    }
    
    private let get : () -> State
    private let set : (State) -> ()
    
    internal init(get : @escaping () -> State, set : @escaping (State) -> ())
    {
        self.get = get
        self.set = set
    }
}

public final class SourceState<Value:Equatable>
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


internal extension TableView
{
    final class DynamicSource<Input:Equatable> : TableViewSource
    {
        typealias Builder = (SourceState<Input>, inout TableView.ContentBuilder) -> ()
        let builder : Builder
        
        init(with builder : @escaping Builder)
        {
            self.builder = builder
        }
        
        public func content(with state: SourceState<Input>, table: inout TableView.ContentBuilder)
        {
            self.builder(state, &table)
        }
    }
    
    final class StaticSource : TableViewSource
    {
        public struct State : Equatable {}
        
        public let content : TableView.Content
        
        public init(with content : TableView.Content = .init())
        {
            self.content = content
        }
        
        public convenience init(with build : TableView.ContentBuilder.Build)
        {
            self.init(with: TableView.ContentBuilder.build(with: build))
        }
        
        func content(with state: SourceState<TableView.StaticSource.State>, table: inout TableView.ContentBuilder)
        {
            fatalError()
        }
        
        func content(with state: SourceState<TableView.StaticSource.State>) -> TableView.Content
        {
            return self.content
        }
    }
}
