//
//  Elements.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/21/19.
//

import ListableCore


public struct Content
{
    public let refreshControl : RefreshControl?
    
    public let header : AnyHeaderFooter?
    public let footer : AnyHeaderFooter?
    
    public var sections : [Section]
    
    public var rowCount : Int {
        return self.sections.reduce(0, { $0 + $1.rows.count })
    }
    
    public init(
        refreshControl : RefreshControl? = nil,
        header : AnyHeaderFooter? = nil,
        footer : AnyHeaderFooter? = nil,
        sections : [Section] = []
        )
    {
        self.refreshControl = refreshControl
        
        self.header = header
        self.footer = footer
        
        self.sections = sections
    }
    
    public func row(at indexPath : IndexPath) -> AnyRow
    {
        let section = self.sections[indexPath.section]
        let row = section.rows[indexPath.row]
        
        return row
    }
    
    public func indexPath(for identifier : AnyIdentifier) -> IndexPath?
    {
        return self.row(for: identifier)?.indexPath
    }
    
    func row(for identifier : AnyIdentifier) -> (indexPath:IndexPath, row:AnyRow)?
    {
        for (sectionIndex, section) in self.sections.enumerated() {
            for (rowIndex, row) in section.rows.enumerated() {
                if row.identifier == identifier {
                    return (IndexPath(row: rowIndex, section: sectionIndex), row)
                }
            }
        }
        
        return nil
    }
    
    mutating func remove(at indexPath : IndexPath)
    {
        self.sections[indexPath.section].rows.remove(at: indexPath.row)
    }
    
    //
    // MARK: Slicing
    //
    
    struct Slice
    {
        static let defaultSize : Int = 250
        
        let containsAllRows : Bool
        var content : Content
        
        init(containsAllRows : Bool, content : Content)
        {
            self.containsAllRows = containsAllRows
            self.content = content
        }
        
        init()
        {
            self.containsAllRows = true
            self.content = Content(sections: [])
        }
        
        enum UpdateReason : Equatable
        {
            case scrolledDown
            case didEndDecelerating
            
            case scrolledToTop
            
            case contentChanged(animated : Bool)
            
            var diffsChanges : Bool {
                /*
                 We only diff in the case of content change to avoid visual artifacts in the table view;
                 even with no animation type provided to batch update methods, the table view still moves
                 rows around in an animated manner.
                 */
                switch self {
                case .scrolledDown: return false
                case .didEndDecelerating: return false
                case .scrolledToTop: return false
                    
                case .contentChanged(_): return true
                }
            }
            
            var animated : Bool {
                switch self {
                case .scrolledDown: return false
                case .didEndDecelerating: return false
                case .scrolledToTop: return false
                    
                case .contentChanged(let animated): return animated
                }
            }
        }
    }
    
    internal func sliceTo(indexPath : IndexPath, plus additionalRows : Int) -> Slice
    {
        var sliced = self
        
        var remaining : Int = indexPath.row + additionalRows
        
        sliced.sections = self.sections.compactMapWithIndex { sectionIndex, section in
            if sectionIndex < indexPath.section {
                return section
            } else {
                guard remaining > 0 else {
                    return nil
                }
                
                var section = section
                section.rows = section.rowsUpTo(limit: remaining)
                remaining -= section.rows.count
                
                return section
            }
        }
        
        return Slice(
            containsAllRows: self.rowCount == sliced.rowCount,
            content: sliced
        )
    }
}


public extension Content
{
    func elementsEqual(to other : Content) -> Bool
    {
        if self.sections.count != other.sections.count {
            return false
        }
        
        let sections = zip(self.sections, other.sections)
        
        return sections.allSatisfy { both in
            both.0.elementsEqual(to: both.1)
        }
    }
}

private extension Array
{
    func compactMapWithIndex<Mapped>(_ block : (Int, Element) -> Mapped?) -> [Mapped]
    {
        var mapped = [Mapped]()
        mapped.reserveCapacity(self.count)
        
        for (index, element) in self.enumerated() {
            if let value = block(index, element) {
                mapped.append(value)
            }
        }
        
        return mapped
    }
}
