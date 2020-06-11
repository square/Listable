//
//  SizedViewIteration.swift
//  Snapshot
//
//  Created by Kyle Van Essen on 12/1/19.
//

import Foundation


public struct ViewIteration<ViewType:UIView> : SnapshotIteration
{
    public init(name: String)
    {
        self.name = name
    }
    
    // MARK: SnapshotIteration
    
    public typealias RenderingFormat = ViewType
    
    public var name : String
    
    public func prepare(render : ViewType) -> ViewType
    {
        return render
    }
}


public struct SizedViewIteration<ViewType:UIView> : SnapshotIteration
{
    public let size : CGSize
    
    public init(size: CGSize)
    {
        self.size = size
    }
    
    // MARK: SnapshotIteration
    
    public typealias RenderingFormat = ViewType
    
    public var name : String {
        return "\(self.size.width) x \(self.size.height)"
    }
    
    public func prepare(render : ViewType) -> ViewType
    {
        render.frame.origin = .zero
        render.frame.size = self.size
        
        return render
    }
}
