//
//  Appearance.swift
//  Listable
//
//  Created by Kyle Van Essen on 10/17/19.
//


public struct Appearance : Equatable
{
    public var backgroundColor : UIColor
    
    public var showsScrollIndicators : Bool
        
    public init(
        backgroundColor : UIColor = .white,
        showsScrollIndicators : Bool = true,
        configure : (inout Self) -> () = { _ in }
    ) {
        self.backgroundColor = backgroundColor
        
        self.showsScrollIndicators = showsScrollIndicators
        
        configure(&self)
    }
}
