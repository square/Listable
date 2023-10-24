import BlueprintUILists
import BlueprintUICommonControls

final class CenterSnappingTableViewController : UIViewController
{
    let blueprintView = BlueprintView()
        
    override func loadView()
    {
        self.view = self.blueprintView
        
        self.update()
    }
    
    func update()
    {
        self.blueprintView.element = List { list in
            list.appearance.showsScrollIndicators = false
            list.behavior.decelerationRate = .fast
            list.layout = .table { table in
                table.direction = .horizontal
                table.bounds = .init(
                    padding: .init(top: 0, left: 20, bottom: 0, right: 20),
                    width: .noConstraint
                )
                table.pagingBehavior = .firstVisibleItemCentered
                table.layout.itemSpacing = 20
            }
            list.add(sections: {
                Section("section", items: {
                    DemoElement(color: .red)
                    DemoElement(color: .orange)
                    DemoElement(color: .yellow)
                    DemoElement(color: .green)
                    DemoElement(color: .blue)
                })
            })
        }
        .constrainedTo(width: .unconstrained, height: .absolute(162))
        .aligned(vertically: .center)
    }
}

fileprivate struct DemoElement : BlueprintItemContent, Equatable
{
    var identifierValue: UIColor {
        self.color
    }
    
    var color : UIColor
    
    func element(with info: ApplyItemContentInfo) -> Element {
        Box(backgroundColor: self.color)
            .constrainedTo(width: 216, height: 162)
    }
}
