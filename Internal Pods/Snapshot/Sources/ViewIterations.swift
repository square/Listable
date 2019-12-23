//
//  SizedViewIteration.swift
//  Snapshot
//
//  Created by Kyle Van Essen on 12/1/19.
//

import Foundation


public struct ViewIteration : SnapshotIteration
{
    public init(name: String)
    {
        self.name = name
    }
    
    // MARK: SnapshotIteration
    
    public typealias RenderingFormat = UIView
    
    public var name : String
    
    public func prepare(render : UIView) -> UIView
    {
        return render
    }
}


public struct SizedViewIteration : SnapshotIteration
{
    public let size : CGSize
    
    public init(size: CGSize)
    {
        self.size = size
    }
    
    // MARK: SnapshotIteration
    
    public typealias RenderingFormat = UIView
    
    public var name : String {
        return "\(self.size.width) x \(self.size.height)"
    }
    
    public func prepare(render : UIView) -> UIView
    {
        render.frame.origin = .zero
        render.frame.size = self.size
        
        render.layoutIfNeeded()
        
        return render
    }
}
