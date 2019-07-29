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
    
    internal typealias OnChange = (Element) -> ()

    private var state : State
    
    private typealias UpdateElement = (AnyBindingContext, Any, inout Element) -> ()
    
    private enum State
    {
        case initializing
        case new(New)
        case updating(Updating)
        case discarded
        
        struct New
        {
            let context : AnyBindingContext
            let updateElement : UpdateElement
        }
        
        struct Updating
        {
            let context : AnyBindingContext
            let updateElement : UpdateElement
            
            var onChange : OnChange? = nil
        }
    }
    
    public init<Context:BindingContext>(
        initial element : Element,
        bind bindingContext : (Element) -> Context,
        update updateElement : @escaping (Context, Context.Update, inout Element) -> ()
        )
    {
        self.element = element
        self.state = .initializing
        
        let context = bindingContext(element)
        
        context.didUpdate = { [weak self] (update : Context.Update) -> () in
            self?.contextUpdated(with: update)
        }
        
        self.state = .new(.init(
            context: context,
            updateElement: { context, contextUpdate, element in
                updateElement(context as! Context, contextUpdate as! Context.Update, &element)
        }))
    }
    
    deinit {
        self.discard()
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
            self.state = .updating(
                .init(
                    context: new.context,
                    updateElement: new.updateElement,
                    onChange: nil
                )
            )
            
            new.context.anyBind(to: self)
        }
    }
    
    internal func discard()
    {
        switch self.state {
        case .initializing, .new, .discarded: break
            
        case .updating(let state):
            self.state = .discarded
            state.context.anyUnbind(from: self)
        }
    }
    
    private func contextUpdated(with update: Any)
    {
        switch self.state {
        case .initializing, .new, .discarded: break
            
        case .updating(let state):
            OperationQueue.main.addOperation {
                state.updateElement(state.context, update, &self.element)
                state.onChange?(self.element)
            }
        }
    }
}


public protocol AnyBindingContext : AnyObject
{
    func anyBind<AnyElement>(to binding : Binding<AnyElement>)
    func anyFetchLatestUpdate<AnyUpdate>() -> AnyUpdate
    
    func anyUnbind<AnyElement>(from binding : Binding<AnyElement>)
}


public protocol BindingContext : AnyBindingContext
{
    associatedtype Element
    associatedtype Update
    
    typealias DidUpdate = (Update) -> ()
    
    // Call this closure when your context needs to signal an update.
    // Set by the system when creating the context. You should not set this value yourself.
    var didUpdate : DidUpdate? { get set }
    
    func bind(to binding : Binding<Element>)
    func fetchLatestUpdate() -> Update
    
    func unbind(from binding : Binding<Element>)
}

public extension BindingContext
{
    // MARK: AnyBindingContext
    
    func anyBind<AnyElement>(to binding : Binding<AnyElement>)
    {
        let binding = binding as! Binding<Element>
        
        self.bind(to: binding)
    }
    
    func anyFetchLatestUpdate<AnyUpdate>() -> AnyUpdate
    {
        // TODO
        fatalError()
    }
    
    func anyUnbind<AnyElement>(from binding : Binding<AnyElement>)
    {
        let binding = binding as! Binding<Element>
        
        self.unbind(from: binding)
    }
}


public final class NotificationContext<Element, Update> : BindingContext
{
    public var didUpdate : DidUpdate?
    
    public let center : NotificationCenter
    public let name : Notification.Name
    public let object : AnyObject?
    
    public let createUpdate : (Notification) -> Update
    
    public init(
        center : NotificationCenter = .default,
        name : Notification.Name,
        object : AnyObject? = nil,
        createUpdate : @escaping (Notification) -> Update
        )
    {
        self.center = center
        self.name = name
        self.object = object
        
        self.createUpdate = createUpdate
    }
    
    deinit {
        self.center.removeObserver(self)
    }
    
    @objc private func recievedNotification(_ notification : Notification)
    {
        self.didUpdate?(self.createUpdate(notification))
    }
    
    // MARK: BindingContext
    
    public func bind(to binding: Binding<Element>)
    {
        self.center.addObserver(self, selector: #selector(recievedNotification(_:)), name: self.name, object: self.object)
    }
    
    // TODO Implement me...
    public func fetchLatestUpdate() -> Update
    {
        fatalError()
    }
    
    public func unbind(from binding : Binding<Element>)
    {
        self.center.removeObserver(self)
    }
}

public extension NotificationContext where Update == Notification
{
    convenience init(
        center : NotificationCenter = .default,
        name : Notification.Name,
        object : AnyObject? = nil
        )
    {
        self.init(
            center: center,
            name: name,
            object: object,
            createUpdate: { $0 }
        )
    }
}
