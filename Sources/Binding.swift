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
    
    internal typealias OnChange = (Element) -> ()
    internal typealias UpdateValue = (AnyBindingContext, inout Element) -> ()
    
    internal enum State
    {
        case initializing
        case new(New)
        case updating(Updating)
        case discarded
        
        struct New
        {
            let context : AnyBindingContext
            let updateValue : UpdateValue
        }
        
        struct Updating
        {
            let context : AnyBindingContext
            let updateValue : UpdateValue
            
            var onChange : OnChange? = nil
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
        
        self.state = .new(.init(
            context: context,
            updateValue: { context, element in
                update(context as! Context, &element)
        }))
    }
    
    deinit {
        self.discard()
    }
    
    public func signal()
    {
        switch self.state {
        case .initializing, .new, .discarded: break
            
        case .updating(let state):
            state.updateValue(state.context, &self.element)
            state.onChange?(self.element)
        }
    }
    
    internal func onChange(_ onChange : OnChange?)
    {
        switch self.state {
        case .initializing, .new, .discarded: break
            
        case .updating(let state):
            var newState = state
            newState.onChange = onChange
            
            self.state = .updating(newState)
        }
    }
    
    internal func start()
    {
        switch self.state {
        case .initializing, .updating, .discarded: break
            
        case .new(let new):
            new.context.bindAny(to: self)
        }
    }
    
    internal func discard()
    {
        switch self.state {
        case .initializing, .new, .discarded: break
            
        case .updating(let state):
            state.context.unbindAny(from: self)
        }
        
        self.state = .discarded
    }
}

public extension Binding
{
    final class WrapperContext<Wrapped> : BindingContext
    {
        private let wrapping : Binding<Wrapped>
        private weak var binding : Binding<Element>?
        
        internal var latest : Wrapped
        
        init(wrapping : Binding<Wrapped>, for binding : Binding<Element>)
        {
            self.wrapping = wrapping
            self.binding = binding
            
            self.latest = self.wrapping.element
            
            self.wrapping.onChange { [weak self] wrapped in
                self?.latest = wrapped
                self?.binding?.signal()
            }
        }
        
        public func bind(to binding: Binding<Element>)
        {
            self.wrapping.start()
        }
        
        public func unbind(from binding : Binding<Element>)
        {
            self.wrapping.discard()
        }
    }

    
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
        }
        
        @objc private func recievedNotification(_ notification : Notification)
        {
            // TODO: Could come in on any thread...
            
            self.binding?.signal()
        }
    
        // MARK: BindingContext
        
        public func bind(to binding: Binding<Element>)
        {
            self.center.addObserver(self, selector: #selector(recievedNotification(_:)), name: self.name, object: self.object)
        }
        
        public func unbind(from binding : Binding)
        {
            self.center.removeObserver(self)
        }
    }
}

public protocol AnyBindingContext : AnyObject
{
    func bindAny<AnyElement>(to binding : Binding<AnyElement>)
    func unbindAny<AnyElement>(from binding : Binding<AnyElement>)
}

public protocol BindingContext : AnyBindingContext
{
    associatedtype Element
    
    func bind(to binding : Binding<Element>)
    func unbind(from binding : Binding<Element>)
}

public extension BindingContext
{
    // MARK: AnyBindingContext
    
    func bindAny<AnyElement>(to binding : Binding<AnyElement>)
    {
        let binding = binding as! Binding<Element>
        
        self.bind(to: binding)
    }
    
    func unbindAny<AnyElement>(from binding : Binding<AnyElement>)
    {
        let binding = binding as! Binding<Element>
        
        self.unbind(from: binding)
    }
}
