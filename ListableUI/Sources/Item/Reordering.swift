//
//  Reordering.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 12/14/20.
//

import Foundation


public struct Reordering
{
    public var sections : Sections
    
    public typealias CanReorder = (Result) -> Bool
    public var canReorder : CanReorder?
    
    public typealias DidReorder = (Result) -> ()
    public var didReorder : DidReorder
    
    public init(
        sections : Sections = .same,
        canReorder : CanReorder? = nil,
        didReorder : @escaping DidReorder
    ) {
        self.sections = sections
        self.canReorder = canReorder
        self.didReorder = didReorder
    }
    
    public enum Sections : Equatable
    {
        case same
    }
    
    public struct Result
    {
        public var fromSection : Section
        public var fromIndexPath : IndexPath
        
        public var toSection : Section
        public var toIndexPath : IndexPath
    }
}
