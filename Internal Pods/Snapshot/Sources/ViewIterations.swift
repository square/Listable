//
//  SizedViewIteration.swift
//  Snapshot
//
//  Created by Kyle Van Essen on 12/1/19.
//

import UIKit


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
        render.frame = CGRect(origin: .zero, size: self.size)
        render.layoutIfNeeded()
        
        // Some views, like UICollectionView, do not lay out properly
        // without spinning the runloop once, in order to update the onscreen cells.
        self.waitForOneRunloop()
        
        return render
    }
    
    private func waitForOneRunloop()
    {
        let finalDate = Date(timeIntervalSinceNow: 1.0)
        
        repeat {
            RunLoop.main.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
        } while Date() < finalDate
    }
}
