//
//  TableView.PresentationState.swift
//  Listable
//
//  Created by Kyle Van Essen on 7/22/19.
//

import ListableCore


public protocol PresentationStateRowState : PresentationStateRowState_Internal
{
}

public protocol PresentationStateRowState_Internal : AnyObject
{
    var anyIdentifier : AnyIdentifier { get }
    var anyModel : AnyRow { get }
    
    func update(with old : AnyRow, new : AnyRow)
    
    func willDisplay(with cell : UITableViewCell)
    func didEndDisplay()
}


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
    
    var sections : [PresentationState.SectionState]
    
    private(set) var containsAllRows : Bool
    
    init()
    {
        self.refreshControl = nil
        self.sections = []
        
        self.containsAllRows = true
    }
    
    // TODO: Add table header and footer.
    
    func remove(row rowToRemove : PresentationStateRowState) -> IndexPath?
    {
        for (sectionIndex, section) in self.sections.enumerated() {
            for (rowIndex, row) in section.rows.enumerated() {
                if row === rowToRemove {
                    self.sections[sectionIndex].removeRow(at: rowIndex)
                    return IndexPath(row: rowIndex, section: sectionIndex)
                }
            }
        }
        
        return nil
    }
    
    func row(at indexPath : IndexPath) -> PresentationStateRowState
    {
        let section = self.sections[indexPath.section]
        let row = section.rows[indexPath.row]
        
        return row
    }
    
    func update(with diff : SectionedDiff<Section, AnyRow>, slice : Content.Slice)
    {
        self.containsAllRows = slice.containsAllRows
        
        // TODO: Handle header footer changing.
        
        self.updateRefreshControl(with: slice.content.refreshControl)
        
        self.sections = diff.changes.transform(
            old: self.sections,
            removed: { _, _ in },
            added: { section in SectionState(model: section) },
            moved: { old, new, changes, section in section.update(with: old, new: new, changes: changes) },
            noChange: { old, new, changes, section in section.update(with: old, new: new, changes: changes) }
        )
    }
    
    var sectionModels : [Section] {
        return self.sections.map { section in
            var sectionModel = section.model
            
            sectionModel.rows = section.rows.map {
                $0.anyModel
            }
            
            return sectionModel
        }
    }
    
    private func updateRefreshControl(with refreshControl : RefreshControl?)
    {
        guard #available(iOS 10.0, *) else { return }
        
        syncOptionals(
            left: self.refreshControl,
            right: refreshControl,
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
    
    final class SectionState
    {
        var model : Section
        
        var rows : [PresentationStateRowState]
        
        // TODO: Add header and footer.
        
        init(model : Section)
        {
            self.model = model
            
            self.rows = self.model.rows.map {
                $0.newPresentationContainer()
            }
        }
        
        fileprivate func removeRow(at index : Int)
        {
            self.model.rows.remove(at: index)
            self.rows.remove(at: index)
        }
        
        fileprivate func update(
            with oldSection : Section,
            new newSection : Section,
            changes : SectionedDiff<Section, AnyRow>.ItemChanges
            )
        {
            self.model = newSection
            
            self.rows = changes.transform(
                old: self.rows,
                removed: { _, _ in },
                added: { $0.newPresentationContainer() },
                moved: { old, new, row in row.update(with: old, new: new) },
                updated: { old, new, row in row.update(with: old, new: new) },
                noChange: { old, new, row in row.update(with: old, new: new) }
            )
        }
    }
    
    final class RowState<Element:RowElement> : PresentationStateRowState
    {
        var model : Row<Element>
        
        let binding : Binding<Element>?
        
        private var visibleCell : Element.TableViewCell?
        
        init(_ model : Row<Element>)
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
                        self.model.element.apply(to: cell, reason: .willDisplay)
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
        
        var anyModel : AnyRow {
            return self.model
        }
        
        public func update(with old : AnyRow, new : AnyRow)
        {
            self.model = new as! Row<Element>
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
