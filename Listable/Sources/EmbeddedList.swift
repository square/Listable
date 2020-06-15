//
//  EmbeddedList.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/10/19.
//


public extension Item where Content == EmbeddedList
{
    static func list<Identifier:Hashable>(
        identifier : Identifier,
        sizing : EmbeddedList.Sizing,
        build : ListProperties.Build
    ) -> Item<EmbeddedList>
    {
        return Item(
            EmbeddedList(identifier: identifier, build: build),
            sizing: sizing.toStandardSizing,
            layout: ItemLayout(width: .fill)
        )
    }
}


public struct EmbeddedList : ItemContent
{
    //
    // MARK: Public Properties
    //
    
    public var properties : ListProperties
    public var contentIdentifier : AnyHashable
    
    //
    // MARK: Initialization
    //
    
    public init<Identifier:Hashable>(identifier : Identifier, build : ListProperties.Build)
    {
        self.contentIdentifier = AnyHashable(identifier)
        
        self.properties = ListProperties(
            animatesChanges: true,
            layout: .list(),
            appearance: .init {
                $0.showsScrollIndicators = false
            },
            behavior: .init(),
            autoScrollAction: .none,
            scrollInsets: .init(),
            accessibilityIdentifier: nil,
            debuggingIdentifier: nil,
            build: build
        )
    }
    
    //
    // MARK: ItemContent
    //
        
    public typealias ContentView = ListView
    
    public var identifier: Identifier<EmbeddedList> {
        return .init(self.contentIdentifier)
    }
    
    public func apply(to views : ItemContentViews<Self>, for reason: ApplyReason, with info : ApplyItemContentInfo)
    {
        views.content.setProperties(with: self.properties)
    }
    
    public func isEquivalent(to other: EmbeddedList) -> Bool
    {
        return false
    }
    
    public static func createReusableContentView(frame : CGRect) -> ListView
    {
        ListView(frame: frame)
    }
}

public extension EmbeddedList
{
    enum Sizing : Equatable
    {
        case `default`
        case fixed(width: CGFloat = 0.0, height : CGFloat = 0.0)
        
        var toStandardSizing : Listable.Sizing {
            switch self {
            case .default: return .default
            case .fixed(let w, let h): return .fixed(width: w, height: h)
            }
        }
    }
}
