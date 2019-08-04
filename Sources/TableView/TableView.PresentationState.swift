//
//  TableView.PresentationState.swift
//  Listable
//
//  Created by Kyle Van Essen on 7/22/19.
//


internal extension TableView
{
    /*
     A class used to manage the "live" / mutable state of the visible rows in the table view,
     which is persistent across diffs of content (instances are only created or destroyed when a row enters or leaves the table).
     
     This is where bindings or other update-driving objects live,
     which then push the changes to the row and section content back into view models.
     */
    final class PresentationState
    {
        unowned var tableView : UITableView!
        
        var refreshControl : RefreshControl.PresentationState?
        
        var sections : [PresentationState.Section]
        
        init()
        {
            self.refreshControl = nil
            self.sections = []
        }
        
        // TODO: Add header and footer.
        
        func remove(row rowToRemove : TableViewPresentationStateRow) -> IndexPath?
        {
            for (sectionIndex, section) in self.sections.enumerated() {
                for (rowIndex, row) in section.rows.enumerated() {
                    if row === rowToRemove {
                        return IndexPath(row: rowIndex, section: sectionIndex)
                    }
                }
            }
            
            return nil
        }
        
        func row(at indexPath : IndexPath) -> TableViewPresentationStateRow
        {
            let section = self.sections[indexPath.section]
            let row = section.rows[indexPath.row]
            
            return row
        }
        
        func update(with diff : SectionedDiff<TableView.Section, TableViewRow>, for content : Content)
        {
            // TODO: Handle header footer changing.
            
            self.updateRefreshControl(with: content)
            
            self.sections = diff.changes.transform(
                old: self.sections,
                removed: { _, _ in },
                added: { section in Section(section: section) },
                moved: { old, new, changes, section in section.update(with: old, new: new, changes: changes) },
                updated: { old, new, changes, section in section.update(with: old, new: new, changes: changes) },
                noChange: { old, new, changes, section in section.update(with: old, new: new, changes: changes) }
            )
        }
        
        func updateRefreshControl(with content : Content)
        {
            guard #available(iOS 10.0, *) else { return }
            
            syncOptionals(
                left: self.refreshControl,
                right: content.refreshControl,
                created: { model in
                    let new = RefreshControl.PresentationState(model)
                    self.tableView.refreshControl = new.view
                    self.refreshControl = new
            },
                removed: { _ in
                    self.refreshControl = nil
                    self.tableView.refreshControl = nil
            },
                overlapping: { control, model in
                    model.apply(to: control.view)
            })
        }
        
        final class Section
        {
            let section : TableView.Section
            
            var rows : [TableViewPresentationStateRow]
            
            // TODO: Add header and footer.
            
            init(section : TableView.Section)
            {
                self.section = section
                
                self.rows = self.section.rows.map {
                    $0.newPresentationRow()
                }
            }
            
            func update(
                with oldSection : TableView.Section,
                new newSection : TableView.Section,
                changes : SectionedDiff<TableView.Section, TableViewRow>.RowChanges
                )
            {
                // TODO: Handle header footer changing.
                
                self.rows = changes.transform(
                    old: self.rows,
                    removed: { _, _ in },
                    added: { $0.newPresentationRow() },
                    moved: { old, new, row in row.update(with: old, new: new) },
                    updated: { old, new, row in row.update(with: old, new: new) },
                    noChange: { old, new, row in row.update(with: old, new: new) }
                )
            }
        }
        
        final class Row<Element:TableViewRowElement> : TableViewPresentationStateRow
        {
            var model : TableView.Row<Element>
            
            let binding : Binding<Element>?
            
            private var visibleCell : Element.TableViewCell?
            
            init(_ model : TableView.Row<Element>)
            {
                self.model = model
                
                self.anyIdentifier = self.model.identifier
                
                if let binding = self.model.bind?(self.model.element)
                {
                    self.binding =  binding
                    
                    binding.start()

                    binding.onChange { [weak self] element in
                        guard let self = self else { return }
                        
                        self.model.element = element
                        
                        if let cell = self.visibleCell {
                            self.model.element.applyTo(cell: cell, reason: .willDisplay)
                        }
                    }
                    
                    // Pull the current element off the binding in case it changed
                    // during initialization, from the provider.
                    
                    self.model.element = binding.element
                } else {
                    self.binding = nil
                }
            }
            
            deinit {
                self.binding?.discard()
            }
            
            // MARK: TableViewPresentationStateRow
            
            let anyIdentifier : AnyIdentifier
            
            var anyModel : TableViewRow {
                return self.model
            }
            
            public func update(with old : TableViewRow, new : TableViewRow)
            {
                self.model = new as! TableView.Row<Element>
            }
            
            public func willDisplay(with cell : UITableViewCell)
            {
                self.visibleCell = (cell as! Element.TableViewCell)
                
                self.model.onDisplay?(self.model.element)
            }
            
            public func didEndDisplay()
            {
                self.visibleCell = nil
            }
        }
    }
}

func syncOptionals<Left,Right>(left : Left?, right : Right?, created : (Right) -> (), removed : (Left) -> (), overlapping: (Left, Right) -> ())
{
    if left == nil, let right = right {
        created(right)
    } else if let left = left, right == nil {
        removed(left)
    } else if let left = left, let right = right {
        overlapping(left, right)
    }
}
