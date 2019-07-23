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
    
    internal typealias Apply = (Element) -> ()
    internal typealias Update = (AnyBindingContext, Element) -> Element
    
    internal enum State
    {
        case initializing
        case idle(AnyBindingContext, Update)
        case updating(AnyBindingContext, Update, Apply)
        case discarded
    }
    
    public init<Context:BindingContext>(
        initial element : Element,
        bind bindingContext : @escaping (Binding) -> Context,
        update : @escaping (Context, Element) -> Element
        )
    {
        self.element = element
        
        self.state = .initializing
        
        let context = bindingContext(self)
        
        self.state = .idle(context, { context, element in
            return update(context as! Context, element)
        })
    }
    
    deinit {
        self.discard()
    }
    
    public func signal()
    {
        switch self.state {
        case .initializing, .idle, .discarded: break
            
        case .updating(let context, let update, let apply):
            self.element = update(context, self.element)
            apply(self.element)
        }
    }
    
    internal func willDisplay(_ element : Element, apply : @escaping Apply)
    {
        self.element = element
        
        switch self.state {
        case .initializing, .updating, .discarded: break
            
        case .idle(let context, let update):
            self.state = .updating(context, update, apply)
        }
    }
    
    internal func didEndDisplay()
    {
        switch self.state {
        case .initializing, .idle, .discarded: break
        
        case .updating(let context, let update, _):
            self.state = .idle(context, update)
        }
    }
    
    internal func discard()
    {
        switch self.state {
        case .initializing: break
        case .idle(let context, _), .updating(let context, _, _): context.unbindAny(from: self)
        case .discarded: break
        }
        
        self.state = .discarded
    }
}

public extension Binding
{
    final class WrappingBindingContext<Wrapped> : BindingContext
    {
        private let wrapping : Binding<Wrapped>
        
        init(wrapping : Binding<Wrapped>)
        {
            self.wrapping = wrapping
            
            // TODO...
        }
        
        // MARK: BindingContext
        
        public func unbind(from binding: Binding)
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


extension Binding
{
    final class Container
    {
        private var state : State
        
        typealias CreateBinding = (Element) -> (Binding)
        
        enum State {
            case new(CreateBinding)
            case idle(Binding)
            case updating(Binding)
            case discarded
        }
        
        init?(_ create : CreateBinding?)
        {
            guard let create = create else {
                return nil
            }
            
            self.state = .new(create)
        }
        
        deinit {
            self.discard()
        }
        
        func willDisplay(_ element : Element, apply : @escaping Apply)
        {
            switch self.state {
            case .new(let create):
                let binding = create(element)
                self.state = .updating(binding)
                binding.willDisplay(element, apply: apply)
                
            case .idle(let binding):
                self.state = .updating(binding)
                binding.willDisplay(element, apply: apply)
                
            case .updating(let binding):
                binding.willDisplay(element, apply: apply)
                
            case .discarded: break
            }
        }
        
        func didEndDisplay()
        {
            switch self.state {
            case .new, .idle, .discarded: break
                
            case .updating(let binding):
                self.state = .idle(binding)
                binding.didEndDisplay()
            }
        }
        
        func discard()
        {
            switch self.state {
            case .new, .discarded: break
            case .idle(let binding), .updating(let binding): binding.discard()
            }
            
            self.state = .discarded
        }
    }
}

