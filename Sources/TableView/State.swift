//
//  State.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/21/19.
//

import Foundation


public protocol TableViewContentSource
{
    associatedtype State:Equatable
    
    func tableViewContent(with state : TableView.State<State>, table : inout TableView.ContentBuilder)
}

public extension TableView
{
    final class Presenter<ContentSource:TableViewContentSource>
    {
        public let contentSource : ContentSource
        public let tableView : TableView
        
        public let state : State<ContentSource.State>
        
        public init(initial state : ContentSource.State, contentSource : ContentSource, tableView : TableView)
        {
            self.contentSource = contentSource
            self.tableView = tableView
            
            self.state = State(initial: state)
            self.state.onUpdate = self.stateUpdated // TODO is this a retain cycle?
            
            self.tableView.content = self.buildContent()
        }
        
        deinit
        {
            self.state.onUpdate = nil
        }
        
        public func update()
        {
            self.tableView.set(content: self.buildContent(), animated: true)
        }
        
        public func update(_ block : (inout ContentSource.State) -> ())
        {
            self.state.update(block)
        }
        
        private func stateUpdated(new : ContentSource.State)
        {
            // TODO: Somehow, we need to ignore updates from old state objects.
            
            self.state.ignoreUpdates = true
            self.tableView.set(content: self.buildContent(), animated: true)
            self.state.ignoreUpdates = false
        }
        
        private func buildContent() -> TableView.Content
        {
            var builder = TableView.ContentBuilder()
            
            self.contentSource.tableViewContent(with: self.state, table: &builder)
            
            return builder.content
        }
    }
    
    final class State<Value:Equatable>
    {
        private(set) public var value : Value
        
        typealias OnUpdate = (Value) -> ()
        fileprivate var onUpdate : OnUpdate?
        
        fileprivate var ignoreUpdates : Bool = false
        
        fileprivate init(initial value : Value)
        {
            self.value = value
        }
        
        public func update(_ block : (inout Value) -> ())
        {
            var updated = self.value
            
            block(&updated)
            
            if updated != self.value && self.ignoreUpdates == false {
                self.value = updated
                self.onUpdate?(updated)
            }
        }
        
        public subscript<Inner:Equatable>(keyPath: WritableKeyPath<Value, Inner>) -> State<Inner>
        {
            get {
                return self.subState(for: keyPath)
            }
        }
        
        public func subState<Inner:Equatable>(for keyPath : WritableKeyPath<Value, Inner>) -> State<Inner>
        {
            let value = self.value[keyPath: keyPath]
            
            let state = State<Inner>(initial: value)
            
            state.onUpdate = { updated in
                self.update { state in
                    state[keyPath: keyPath] = updated
                }
            }
            
            return state
        }
    }
}
