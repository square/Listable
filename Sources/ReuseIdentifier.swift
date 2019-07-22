//
//  ReuseIdentifier.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/21/19.
//

import Foundation


public class ReuseIdentifier<Element> : Hashable
{    
    init(modifiers : [AnyHashable] = [])
    {
        self.identifier = ObjectIdentifier(Element.self)
        
        self.modifiers = modifiers
    }
    
    private let identifier : ObjectIdentifier
    private let modifiers : [AnyHashable]
    
    public lazy var stringValue : String = {
        
        // TODO Is this safe and unique? In theory the two items below are duplicative,
        // but are they guaranteed to always work the way they do?
        // TODO Is this fast enough?
        var string =  "\(String(reflecting: Element.self))(\(self.identifier))"
        
        if self.modifiers.count > 0 {
            
            string += "("
            
            modifiers.forEach {
                string += "\($0), "
            }
            
            string += ")"
        }
        
        return string

    }()
    
    // Equatable
    
    public static func == (lhs: ReuseIdentifier, rhs: ReuseIdentifier) -> Bool
    {
        if lhs.identifier != rhs.identifier {
            return false
        }
        
        if lhs.modifiers != rhs.modifiers {
            return false
        }
        
        return true
    }
    
    // Hashable
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(self.identifier)
        hasher.combine(self.modifiers)
    }
}
