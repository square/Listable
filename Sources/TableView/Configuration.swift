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
        
        var rowHeight : CGFloat = 60.0
        
        public init() {}
        
        func apply(to tableView : UITableView)
        {
            tableView.rowHeight = self.rowHeight
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
