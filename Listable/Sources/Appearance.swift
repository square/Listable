//
//  Appearance.swift
//  Listable
//
//  Created by Kyle Van Essen on 10/17/19.
//


public struct Appearance : Equatable
{
    public var backgroundColor : UIColor
    
    public var direction : LayoutDirection
    
    public var stickySectionHeaders : Bool

    public init(
        backgroundColor : UIColor = .white,
        direction : LayoutDirection = .vertical,
        stickySectionHeaders : Bool = true,
        configure : (inout Self) -> () = { _ in }
    )
    {
        self.backgroundColor = backgroundColor
        
        self.direction = direction
        
        self.stickySectionHeaders = stickySectionHeaders
        
        configure(&self)
    }
    
    public mutating func set(with block : (inout Appearance) -> ())
    {
        var edited = self
        block(&edited)
        self = edited
    }
    
    private var storage : LayoutStorage = LayoutStorage()
    
    public subscript<AppearanceType:Equatable>(
        type : AppearanceType.Type,
        default defaultValue : @autoclosure () -> AppearanceType
    ) -> AppearanceType
    {
        get {
            self.storage[type] ?? defaultValue()
        }
    }
    
    public subscript<AppearanceType:Equatable>(type : AppearanceType.Type) -> AppearanceType?
    {
        get {
            self.storage[type]
        }
        
        set {
            self.storage[type] = newValue
        }
    }
}


extension Appearance
{
    struct LayoutStorage : Equatable
    {
        private var byType : [ObjectIdentifier:AnyEquatable] = [:]
        
        subscript<AppearanceType:Equatable>(type : AppearanceType.Type) -> AppearanceType?
        {
            get {
                self.byType[ObjectIdentifier(type)]?.base as! AppearanceType?
            }
            
            set {
                self.byType[ObjectIdentifier(type)] = AnyEquatable(newValue)
            }
        }
    }


    fileprivate struct AnyEquatable : Equatable
    {
        let base : Any
        
        private let isEqual : (Any) -> Bool
        
        init<Value:Equatable>(_ value : Value)
        {
            self.base = value
            
            self.isEqual = {
                ($0 as? Value) == value
            }
        }
        
        static func == (lhs : Self, rhs : Self) -> Bool
        {
            lhs.isEqual(rhs)
        }
    }
}
