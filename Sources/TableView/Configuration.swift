//
//  Configuration.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/21/19.
//

import Foundation


public extension TableView
{
    struct Configuration : Equatable
    {
        public static var `default` : Configuration {
            return Configuration()
        }
        
        var rowHeight : CGFloat = 44.0
        
        var sectionHeaderHeight : CGFloat = 30.0
        var sectionFooterHeight : CGFloat = 30.0
        
        public init() {}
        
        func apply(to tableView : UITableView)
        {
            tableView.rowHeight = self.rowHeight
            
            tableView.sectionHeaderHeight = self.sectionHeaderHeight
            tableView.sectionFooterHeight = self.sectionFooterHeight
        }
    }
    
    struct CellConfiguration
    {
        public static var `default` : CellConfiguration {
            return CellConfiguration()
        }
        
        public var accessoryType : UITableViewCell.AccessoryType = .none
        public var selectionStyle : UITableViewCell.SelectionStyle = .default
        
        public func apply(to cell : UITableViewCell)
        {
            cell.accessoryType = self.accessoryType
            cell.selectionStyle = self.selectionStyle
        }
    }
}
