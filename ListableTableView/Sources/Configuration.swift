//
//  Configuration.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/21/19.
//

import UIKit
import ListableCore


public extension TableView
{
    struct Configuration : Equatable
    {
        public static var `default` : Configuration {
            return Configuration()
        }
        
        var rowHeight : CGFloat? = nil
        
        var sectionHeaderHeight : CGFloat? = nil
        var sectionFooterHeight : CGFloat? = nil
        
        public init() {}
        
        func apply(to tableView : UITableView)
        {
            if let height = self.rowHeight {
                tableView.rowHeight = height
            }
            
            if let height = self.sectionHeaderHeight {
                tableView.sectionHeaderHeight = height
            }
            
            if let height = self.sectionFooterHeight {
                tableView.sectionFooterHeight = height
            }
        }
    }
    
    struct CellConfiguration
    {
        public static var `default` : CellConfiguration {
            return CellConfiguration()
        }
        
        public init() {}
        
        public var accessoryType : UITableViewCell.AccessoryType = .none
        public var selectionStyle : UITableViewCell.SelectionStyle = .default
        
        public func apply(to cell : UITableViewCell)
        {
            cell.accessoryType = self.accessoryType
            cell.selectionStyle = self.selectionStyle
        }
    }
}
