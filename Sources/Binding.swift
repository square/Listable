//
//  Binding.swift
//  Listable
//
//  Created by Kyle Van Essen on 6/27/19.
//

import Foundation


public final class Binding<Element>
{
    private(set) public var element : Element

    private var state : State
    
    internal typealias DidChange = (Element) -> ()
    internal typealias UpdateValue = (AnyBindingContext, inout Element) -> ()
    
    internal enum State
    {
        case initializing
        case updating(Updating)
        case discarded
        
        struct Updating
        {
            let context : AnyBindingContext
            let updateValue : UpdateValue
            
            var didChange : DidChange? = nil
        }
    }
    
    public init<Context:BindingContext>(
        initial element : Element,
        bind bindingContext : @escaping (Binding) -> Context,
        update : @escaping (Context, inout Element) -> ()
        )
    {
        self.element = element
        
        self.state = .initializing
        
        let context = bindingContext(self)
        
        self.state = .updating(.init(
            context: context,
            updateValue: { context, element in
                update(context as! Context, &element)
        },
            didChange: nil
            )
        )
    }
    
    deinit {
        self.discard()
    }
    
    public func signal()
    {
        switch self.state {
        case .initializing, .discarded: break
            
        case .updating(let state):
            state.updateValue(state.context, &self.element)
            state.didChange?(self.element)
        }
    }
    
    internal func setDidChange(_ didChange : DidChange?)
    {
        switch self.state {
        case .initializing, .discarded: break
            
        case .updating(let state):
            var newState = state
            newState.didChange = didChange
            
            self.state = .updating(newState)
        }
    }
    
    internal func discard()
    {
        switch self.state {
        case .initializing, .discarded: break
            
        case .updating(let state):
            state.context.unbindAny(from: self)
        }
        
        self.state = .discarded
    }
}

internal final class BindingWrappingContext<Element, Wrapping> : BindingContext
{
    private let wrapping : Binding<Wrapping>
    private weak var binding : Binding<Element>?
    
    init(wrapping : Binding<Wrapping>, onChange : @escaping () -> ())
    {
        self.wrapping = wrapping
        
        self.wrapping.setDidChange { context in
            onChange()
        }
    }
    
    func unbind(from binding : Binding<Element>)
    {
        self.wrapping.discard()
    }
}

public extension Binding
{
    final class NotificationContext : BindingContext
    {
        private weak var binding : Binding?
        
        public let center : NotificationCenter
        public let name : Notification.Name
        public let object : AnyObject?
        
        public init(
            with binding : Binding<Element>,
            center : NotificationCenter = .default,
            name : Notification.Name,
            object : AnyObject? = nil
            )
        {
            self.binding = binding
            
            self.center = center
            self.name = name
            self.object = object
            
            self.center.addObserver(self, selector: #selector(recievedNotification(_:)), name: self.name, object: self.object)
        }
        
        public func unbind(from binding : Binding)
        {
            self.center.removeObserver(self)
        }
        
        @objc private func recievedNotification(_ notification : Notification)
        {
            // TODO: Could come in on any thread...
            
            self.binding?.signal()
        }
    }
}

public protocol AnyBindingContext : AnyObject
{
    func unbindAny<AnyElement>(from binding : Binding<AnyElement>)
}

public protocol BindingContext : AnyBindingContext
{
    associatedtype Element
    
    func unbind(from binding : Binding<Element>)
}

public extension BindingContext
{
    // MARK: AnyBindingContext
    
    func unbindAny<AnyElement>(from binding : Binding<AnyElement>)
    {
        let binding = binding as! Binding<Element>
        
        self.unbind(from: binding)
    }
}
