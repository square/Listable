//
//  ListView.DataSource.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/19/19.
//


internal extension ListView
{
    final class DataSource : NSObject, UICollectionViewDataSource
    {
        unowned var presentationState : PresentationState!

        func numberOfSections(in collectionView: UICollectionView) -> Int
        {
            return self.presentationState.sections.count
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
        {
            let section = self.presentationState.sections[section]
            
            return section.items.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
        {
            let item = self.presentationState.item(at: indexPath)
            
            self.presentationState.registerCell(for: item)
            
            return item.dequeueAndPrepareCollectionViewCell(in: collectionView, for: indexPath)
        }
        
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
        {
            switch ListViewLayout.SupplementaryKind(rawValue: kind)! {
            case .listHeader:
                if let header = self.presentationState.header {
                    self.presentationState.registerSupplementaryView(of: kind, for: header)
                    return header.dequeueAndPrepareCollectionReusableView(in: collectionView, of: kind, for: indexPath)
                }
                
            case .listFooter:
                if let footer = self.presentationState.footer {
                    self.presentationState.registerSupplementaryView(of: kind, for: footer)
                    return footer.dequeueAndPrepareCollectionReusableView(in: collectionView, of: kind, for: indexPath)
                }
                
            case .sectionHeader:
                let section = self.presentationState.sections[indexPath.section]
                
                if let header = section.header {
                    self.presentationState.registerSupplementaryView(of: kind, for: header)
                    return header.dequeueAndPrepareCollectionReusableView(in: collectionView, of: kind, for: indexPath)
                }
                
            case .sectionFooter:
                let section = self.presentationState.sections[indexPath.section]
                
                if let footer = section.footer {
                    self.presentationState.registerSupplementaryView(of: kind, for: footer)
                    return footer.dequeueAndPrepareCollectionReusableView(in: collectionView, of: kind, for: indexPath)
                }
            }
            
            fatalError()
        }
        
        func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
        {
            let item = self.presentationState.item(at: indexPath)
            
            return item.anyModel.reordering != nil
        }
        
        func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
        {
            let item = self.presentationState.item(at: destinationIndexPath)
            
            print("Moved item from \(sourceIndexPath) to \(destinationIndexPath)")
            
            item.moved(with: Reordering.Result(
                fromSection: self.presentationState.sections[sourceIndexPath.section].model,
                fromIndexPath: sourceIndexPath,
                toSection: self.presentationState.sections[destinationIndexPath.section].model,
                toIndexPath: destinationIndexPath
            ))
        }
    }
}
