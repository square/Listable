//
//  ListReorderGesture.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 11/14/19.
//

import BlueprintUI
import ListableUI


///
/// An element that wraps your provided element, to enable support
/// for user-driven re-ordering in a list view.
///
/// If you do not support reordering items, you do not need
/// to add this element anywhere in your hierarchy.
///
/// This element on its own has no visual appearance. Thus, you should
/// still render your own reorder dragger / handle / etc in the passed in element.
///
/// In the below example, we see how to set up the content of a simple item, which contains
/// a text label and a reorder grabber.
///
/// ```
/// func element(with info : ApplyItemContentInfo) -> Element
/// {
///     Row { row in
///         row.add(child: Label(text: "..."))
///
///         row.add(child: ListReorderGesture(actions: info.actions, wrapping: MyReorderGrabber()))
///
///         // Could also be written as:
///         row.add(child: MyReorderGrabber().listReorderGesture(with: info.reorderingActions))
///     }
/// }
/// ```
public struct ListReorderGesture : Element
{
    /// The element which is being wrapped by the reorder gesture.
    public var element : Element
    
    /// If the gesture is enabled or not.
    public var isEnabled : Bool
    
    let actions : ReorderingActions
    
    /// Creates a new re-order gesture which wraps the provided element.
    /// 
    /// This element on its own has no visual appearance. Thus, you should
    /// still render your own reorder dragger / handle / etc in the passed in element.
    public init(
        isEnabled : Bool = true,
        actions : ReorderingActions,
        wrapping element : Element
    ) {
        self.isEnabled =  isEnabled
        
        self.actions = actions
        
        self.element = element
    }

    //
    // MARK: Element
    //
    
    public var content: ElementContent {
        ElementContent(child: self.element)
    }
    
    public func backingViewDescription(bounds: CGRect, subtreeExtent: CGRect?) -> ViewDescription?
    {
        return ViewDescription(View.self) { config in
            config.builder = {
                View(frame: bounds, wrapping: self)
            }
            
            config.apply { view in
                view.recognizer.isEnabled = self.isEnabled
                
                view.recognizer.apply(actions: self.actions)
            }
        }
    }
}


public extension Element
{
    /// Wraps the element in a re-order gesture.
    func listReorderGesture(with actions : ReorderingActions, isEnabled : Bool = true) -> Element
    {
        ListReorderGesture(isEnabled: isEnabled, actions: actions, wrapping: self)
    }
}


fileprivate extension ListReorderGesture
{
    private final class View : UIView
    {
        let recognizer : ItemReordering.GestureRecognizer
        
        init(frame: CGRect, wrapping : ListReorderGesture)
        {
            self.recognizer = .init()
            
            super.init(frame: frame)
            
            self.isOpaque = false
            self.clipsToBounds = false
            self.backgroundColor = .clear
            
            self.addGestureRecognizer(self.recognizer)
        }
        
        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) {
            listableFatal()
        }
    }
}
