//
//  Section.swift
//  ListableTableView
//
//  Created by Kyle Van Essen on 8/10/19.
//

import ListableCore


public struct Section
{
    public let identifier : AnyIdentifier
    
    public var header : AnyHeaderFooter?
    public var footer : AnyHeaderFooter?
    
    public var rows : [AnyRow]
    
    public init(
        header headerString: String,
        footer footerString: String? = nil,
        content contentBuilder : (inout SectionBuilder) -> ()
        )
    {
        var builder = SectionBuilder()
        
        contentBuilder(&builder)
        
        var footer : AnyHeaderFooter?
        
        if let footerString = footerString {
            footer = HeaderFooter(footerString)
        }
        
        self.init(
            identifier: footerString,
            header: HeaderFooter(headerString),
            footer: footer,
            rows: builder.rows
        )
    }
    
    public init<Identifier:Hashable>(
        identifier : Identifier,
        header : AnyHeaderFooter? = nil,
        footer : AnyHeaderFooter? = nil,
        content contentBuilder : (inout SectionBuilder) -> ()
        )
    {
        var builder = SectionBuilder()
        
        contentBuilder(&builder)
        
        self.init(
            identifier: identifier,
            header: header,
            footer: footer,
            rows: builder.rows
        )
    }
    
    public init<Header:HeaderFooterElement>(
        header : HeaderFooter<Header>,
        footer : AnyHeaderFooter? = nil,
        content contentBuilder : (inout SectionBuilder) -> ()
        )
    {
        var builder = SectionBuilder()
        
        contentBuilder(&builder)
        
        self.init(
            identifier: header.element.identifier,
            header: header,
            footer: footer,
            rows: builder.rows
        )
    }
    
    public init<Identifier:Hashable>(
        identifier : Identifier,
        header : AnyHeaderFooter? = nil,
        footer : AnyHeaderFooter? = nil,
        rows : [AnyRow] = []
        )
    {
        self.identifier = AnyIdentifier(ListableCore.Identifier<Identifier>(identifier))
        
        self.header = header
        self.footer = footer
        
        self.rows = rows
    }
    
    // MARK: TableViewSection
    
    public func updatedComparedTo(old : Section) -> Bool
    {
        let headerChanged = self.headerFooterChanged(self.header, old.header, { $0.updatedComparedTo(old: $1) })
        let footerChanged = self.headerFooterChanged(self.footer, old.footer, { $0.updatedComparedTo(old: $1) })
        
        return headerChanged || footerChanged
    }
    
    public func movedComparedTo(old : Section) -> Bool
    {
        let headerChanged = self.headerFooterChanged(self.header, old.header, { $0.movedComparedTo(old: $1) })
        let footerChanged = self.headerFooterChanged(self.footer, old.footer, { $0.movedComparedTo(old: $1) })
        
        return headerChanged || footerChanged
    }
    
    // MARK: Slicing
    
    func rowsUpTo(limit : Int) -> [AnyRow]
    {
        let end = min(self.rows.count, limit)
        
        return Array(self.rows[0..<end])
    }
    
    private func headerFooterChanged(
        _ lhs : AnyHeaderFooter?,
        _ rhs : AnyHeaderFooter?,
        _ compare : (AnyHeaderFooter, AnyHeaderFooter) -> Bool
        ) -> Bool
    {
        if let lhs = lhs, let rhs = rhs {
            return compare(lhs, rhs)
        } else {
            if lhs != nil && rhs == nil {
                return true
            } else if lhs == nil && rhs != nil {
                return true
            } else {
                return false
            }
        }
    }
}


public extension Section
{
    func elementsEqual(to other : Section) -> Bool
    {
        if self.rows.count != other.rows.count {
            return false
        }
        
        return self.rows.elementsEqual(to: other.rows)
    }
}

