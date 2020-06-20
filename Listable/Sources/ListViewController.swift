//
//  ListViewController.swift
//  Listable
//
//  Created by Kyle Van Essen on 6/21/20.
//

import Foundation


open class ListViewController : UIViewController
{
    private var listView : ListView?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable) required public init?(coder: NSCoder) { fatalError() }
    
    public override func loadView() {
        let listView = ListView()
        
        self.listView = listView
        self.view = listView
    }
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.reload(animated: false)
    }
    
    public func reload(animated : Bool = false)
    {
        guard let listView = self.listView else {
            return
        }

        listView.setProperties { list in
            list.animatesChanges = animated
            self.configure(list: &list)
        }
    }
    
    open func configure(list : inout ListProperties)
    {
        // Subclasses override to customize their list.
    }
}
