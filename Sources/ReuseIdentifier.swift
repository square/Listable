//
//  ReuseIdentifier.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/21/19.
//


private var identifiers : [ObjectIdentifier:Any] = [:]

public final class ReuseIdentifier<Element> : Hashable
{
    // MARK: Fetching Identifiers
    
    public static func identifier(for element : Element) -> ReuseIdentifier<Element>
    {
        let typeIdentifier = ObjectIdentifier(Element.self)
        
        if let identifier = identifiers[typeIdentifier] {
            return identifier as! ReuseIdentifier<Element>
        } else {
            let identifier = ReuseIdentifier<Element>()
            identifiers[typeIdentifier] = identifier
            return identifier
        }
    }
    
    public let stringValue : String
    
    // MARK: Private Methods
    
    private init()
    {
        self.identifier = ObjectIdentifier(Element.self)
        
        self.stringValue = "\(String(reflecting: Element.self))(\(self.identifier))"
    }
    
    private let identifier : ObjectIdentifier
    
    // Equatable
    
    public static func == (lhs: ReuseIdentifier, rhs: ReuseIdentifier) -> Bool
    {
        return lhs.identifier == rhs.identifier
    }
    
    // Hashable
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(self.identifier)
    }
}
