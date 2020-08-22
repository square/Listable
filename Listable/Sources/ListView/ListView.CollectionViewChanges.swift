//
//  ListView.CollectionViewChanges.swift
//  Listable
//
//  Created by Kyle Van Essen on 1/10/20.
//

import Foundation


internal extension ListView
{
    struct CollectionViewChanges
    {
        typealias SectionChanges = SectionedDiff<Section, AnyIdentifier, AnyItem, AnyIdentifier>.SectionChanges
        typealias ItemChanges = SectionedDiff<Section, AnyIdentifier, AnyItem, AnyIdentifier>.ItemChanges
        
        var deletedSections : [SectionChanges.Removed] = []
        var insertedSections : [SectionChanges.Added] = []
        var movedSections : [SectionChanges.Moved] = []
        
        var deletedItems : [ItemChanges.Removed] = []
        var insertedItems : [ItemChanges.Added] = []
        var updatedItems : [ItemChanges.Updated] = []
        var movedItems : [ItemChanges.Moved] = []
                
        var hasIndexAffectingChanges : Bool {
            return
                self.deletedSections.isEmpty == false ||
                    self.insertedItems.isEmpty == false ||
                    self.movedSections.isEmpty == false ||
                    self.deletedItems.isEmpty == false ||
                    self.insertedItems.isEmpty == false ||
                    self.movedItems.isEmpty == false
        }
        
        init(sectionChanges changes : SectionChanges)
        {
            // Inserted & Removed Sections
            
            self.deletedSections = changes.removed
            self.insertedSections = changes.added
            
            // Moved Sections
            
            self.movedSections = changes.moved
            
            // Deleted Items
            
            changes.moved.forEach {
                self.deletedItems += $0.itemChanges.removed
            }
            
            changes.noChange.forEach {
                self.deletedItems += $0.itemChanges.removed
            }
            
            // Inserted Items
            
            changes.moved.forEach {
                self.insertedItems += $0.itemChanges.added
            }
            
            changes.noChange.forEach {
                self.insertedItems += $0.itemChanges.added
            }
            
            // Updated Items
            
            changes.moved.forEach {
                self.updatedItems += $0.itemChanges.updated
            }
            
            changes.noChange.forEach {
                self.updatedItems += $0.itemChanges.updated
            }
            
            // Moved Items
            
            changes.moved.forEach {
                self.movedItems += $0.itemChanges.moved
            }
            
            changes.noChange.forEach {
                self.movedItems += $0.itemChanges.moved
            }
        }
    }
}
