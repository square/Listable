//
//  SectionReordering.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/12/21.
//


///
/// Provides additional validation when an ``Item`` is being reordered into, or out of a section.
///
/// By setting the ``Section/reordering`` property on your ``Section``, you can control
/// the minimum number of items, the maximum number of items, or provide
/// more specific validation by providing either of the `canReorderIn` or `canReorderOut` predicates.
///
public struct SectionReordering {

    /// The minimum number of items within the section. Defaults to 1.
    public var minItemCount : Int
    
    /// The maximum number of items in the section. Has no default setting.
    public var maxItemCount : Int?
    
    public typealias CanReorder = (ItemReordering.Result) throws -> Bool
        
    /// A predicate that you can provide which allows more intricate validation when
    /// when determining if an item can be added to the section.
    public var canReorderIn : CanReorder?
    
    /// A predicate that you can provide which allows more intricate validation when
    /// when determining if an item can be removed from the section.
    public var canReorderOut : CanReorder?
    
    /// Creates a new reordering validation instance.
    public init(
        minItemCount: Int = 1,
        maxItemCount: Int? = nil,
        canReorderIn: CanReorder? = nil,
        canReorderOut: CanReorder? = nil
    ) {
        self.minItemCount = minItemCount
        self.maxItemCount = maxItemCount
        self.canReorderIn = canReorderIn
        self.canReorderOut = canReorderOut
    }
    
    func canReorderIn(with result : ItemReordering.Result) -> Bool {
        
        if let max = self.maxItemCount, max < (result.toSection.count + 1) {
            return false
        }
        
        return result.allowed(with: self.canReorderIn)
    }
    
    func canReorderOut(with result : ItemReordering.Result) -> Bool {
     
        if self.minItemCount > (result.fromSection.count - 1) {
            return false
        }
        
        return result.allowed(with: self.canReorderOut)
    }
}
