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
        
        self.spinTheRunloop_toMakeUICollectionView_call_updateVisibleCellsNow()
        
        return render
    }
    
    private func spinTheRunloop_toMakeUICollectionView_call_updateVisibleCellsNow()
    {
        /// I don't know why this is the only way I can make UICollectionView call `_updateVisibleCellsNow:`.
        
        let finalDate = Date(timeIntervalSinceNow: 0.1)
        
        repeat {
            RunLoop.main.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
        } while Date() < finalDate
    }
}
