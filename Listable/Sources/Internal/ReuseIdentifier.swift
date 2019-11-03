//
//  ReuseIdentifier.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/21/19.
//


private var identifiers : [ObjectIdentifier:Any] = [:]


final class ReuseIdentifier<Element> : Hashable
{
    // MARK: Fetching Identifiers
    
    static func identifier(for element : Element) -> ReuseIdentifier<Element>
    {
        // TODO is this right?
        return self.identifier(for: type(of: element))
    }
    
    static func identifier(for element : Element.Type) -> ReuseIdentifier<Element>
    {
        let typeIdentifier = ObjectIdentifier(element)
        
        if let identifier = identifiers[typeIdentifier] {
            return identifier as! ReuseIdentifier<Element>
        } else {
            let identifier = ReuseIdentifier<Element>()
            identifiers[typeIdentifier] = identifier
            return identifier
        }
    }
    
    
    let stringValue : String
    
    // MARK: Private Methods
    
    private init()
    {
        self.identifier = ObjectIdentifier(Element.self)
        
        self.stringValue = "\(String(reflecting: Element.self))(\(self.identifier))"
    }
    
    private let identifier : ObjectIdentifier
    
    // Equatable
    
    static func == (lhs: ReuseIdentifier, rhs: ReuseIdentifier) -> Bool
    {
        return lhs.identifier == rhs.identifier
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(self.identifier)
    }
}
