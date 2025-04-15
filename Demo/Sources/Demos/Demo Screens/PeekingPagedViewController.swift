import BlueprintUILists
import BlueprintUICommonControls


/// This demo showcases a `PagedListLayout` with peeking leading/top and trailing/bottom items.
final class PeekingPagedViewController : UIViewController {
    
    let blueprintView = BlueprintView()
    
    let listActions = ListActions()
    
    var isVertical : Bool = false
    
    /// When `true`, the first item's leading peek is 0. When `false` the peek is uniform.
    var zeroLeadingPeek : Bool = false
    
    override func loadView() {
        view = self.blueprintView
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Toggle Direction", style: .plain, target: self, action: #selector(toggleDirection)),
            UIBarButtonItem(title: "Toggle First Peek", style: .plain, target: self, action: #selector(toggleFirstPeek))
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.layoutIfNeeded()
        // Ensure the correct peek is used before the view appears.
        update()
    }
    
    // When the size changes, update the demo peek.
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        coordinator.animate { _ in
            // For demo purposes, reset the scroll position when the size changes.
            self.listActions.scrolling.scrollToTop()
        } completion: { _ in
            // Once the view is resized, update the peek/item size.
            self.update()
        }
    }
    
    func update() {
        blueprintView.element = List { list in
            list.actions = listActions
            list.behavior.decelerationRate = .fast
            list.layout = .paged {
                $0.direction = isVertical ? .vertical : .horizontal
                $0.pagingBehavior = .firstVisibleItemCentered
                $0.peek = PagedAppearance.Peek(
                    value: (isVertical ? view.bounds.height : view.bounds.width) / 6,
                    firstItemConfiguration: zeroLeadingPeek ? .customLeading(0) : .uniform
                )
            }
        } sections: {
            Section("first") {
                DemoElement(color: .red)
                DemoElement(color: .orange)
                DemoElement(color: .yellow)
                DemoElement(color: .green)
                DemoElement(color: .blue)
            }
        }
    }
    
    @objc func toggleFirstPeek() {
        zeroLeadingPeek.toggle()
        update()
    }
    
    @objc func toggleDirection() {
        isVertical.toggle()
        update()
    }
}

fileprivate struct DemoElement : BlueprintItemContent, Equatable {
    var identifierValue: UIColor {
        color
    }
    
    var color : UIColor
    
    func element(with info: ApplyItemContentInfo) -> Element {
        Box(backgroundColor: color)
    }
}
