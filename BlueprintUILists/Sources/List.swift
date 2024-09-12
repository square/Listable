//
//  List.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import BlueprintUI
import ListableUI
import UIKit


///
/// A Blueprint element which can be used to display a Listable `ListView` within
/// an element tree.
///
/// You should use the `List` element as follows, just like you'd use the `configure(with:)` method
/// on `ListView` itself.
/// ```
/// List { list in
///     list.header = PodcastsHeader()
///
///     let podcasts = Podcast.podcasts.sorted { $0.episode < $1.episode }
///
///     list += Section("podcasts") { section in
///
///         section.header = PodcastsSectionHeader()
///
///         section += podcasts.map { podcast in
///             PodcastRow(podcast: podcast)
///         }
///     }
/// }
/// ```
/// The parameter passed to the initialization closure is an instance of `ListProperties`,
/// which holds the various configuration options and content for the list. See `ListProperties` for
/// a full overview of all the configuration options available such as animation, layout configuration, etc.
///
/// When being laid out, a `List` will take up as much space as it is allowed. If you'd like to constrain
/// the size of a list, wrap it in a `ConstrainedSize`, or other size constraining element.
///
public struct List : Element
{
    /// The properties which back the on-screen list.
    ///
    /// When it comes time to render the `List` on screen,
    /// `ListView.configure(with: properties)` is called
    /// to update the on-screen list with the provided properties.
    public var properties : ListProperties
    
    /// How the `List` is measured when the element is laid out
    /// by Blueprint.  Defaults to `.fillParent`, which means
    /// it will take up all the height it is given. You can change this to
    /// `.measureContent` to instead measure the optimal height.
    ///
    /// See the `List.Measurement` documentation for more.
    public var measurement : List.Measurement
    
    //
    // MARK: Initialization
    //
        
    /// Create a new list, configured with the provided properties,
    /// configured with the provided `ListProperties` builder.
    public init(
        measurement : List.Measurement = .fillParent,
        configure : ListProperties.Configure
    ) {
        self.measurement = measurement
        
        self.properties = .default(with: configure)
    }
    
    /// Create a new list, configured with the provided properties,
    /// configured with the provided `ListProperties` builder, and the provided `sections`.
    public init(
        measurement : List.Measurement = .fillParent,
        configure : ListProperties.Configure = { _ in },
        @ListableBuilder<Section> sections : () -> [Section]
    ) {
        self.measurement = measurement
        
        self.properties = .default(with: configure)
        
        self.properties.sections += sections()
    }
    
    //
    // MARK: Element
    //
        
    public var content : ElementContent {
        ElementContent { size, env in
            ListContent(
                properties: self.properties,
                measurement: self.measurement,
                environment: env
            )
        }
    }
    
    public func backingViewDescription(with context: ViewDescriptionContext) -> ViewDescription? {
        nil
    }
}


extension List {
    
    struct ListContent : Element {
        
        var properties : ListProperties
        var measurement : List.Measurement
        
        init(
            properties : ListProperties,
            measurement : List.Measurement,
            environment : Environment
        ) {
            var properties = properties
            
            properties.environment.blueprintEnvironment = environment
            
            self.properties = properties
            
            if measurement.needsMeasurement {
                self.measurement = measurement
            } else {
                self.measurement = .fillParent
            }
        }
        
        // MARK: Element
            
        public var content : ElementContent {
            
            switch self.measurement {
            case .fillParent:
                return ElementContent { constraint -> CGSize in
                    constraint.maximum
                }
                
            case .measureContent(let horizontalFill, let verticalFill, let safeArea, let limit):
                return ElementContent { constraint, environment -> CGSize in
                    let measurements = ListView.contentSize(
                        in: constraint.maximum,
                        for: self.properties,
                        safeAreaInsets: safeArea.safeArea(with: environment),
                        itemLimit: limit
                    )
                    
                    return Self.size(
                        with: measurements,
                        in: constraint,
                        layoutMode: environment.layoutMode,
                        horizontalFill: horizontalFill,
                        verticalFill: verticalFill
                    )
                }
            }
        }
        
        public func backingViewDescription(with context: ViewDescriptionContext) -> ViewDescription?
        {
            var properties = self.properties
            
            properties.context = properties.context ?? context.environment.listContentContext
            
            return ListView.describe { config in
                config.builder = {
                    ListView(frame: context.bounds, appearance: properties.appearance)
                }
                
                config.apply { listView in
                    listView.configure(with: properties)
                }
            }
        }
        
        static func size(
            with size : MeasuredListSize,
            in constraint : SizeConstraint,
            layoutMode: LayoutMode,
            horizontalFill : Measurement.FillRule,
            verticalFill : Measurement.FillRule
        ) -> CGSize
        {
            precondition(
                layoutMode == .caffeinated,
                "Listable only supports the `.caffeinated` layout mode in Blueprint."
            )
            
            let width : CGFloat = {
                switch horizontalFill {
                case .fillParent:
                    return constraint.width.constrainedValue ?? .infinity
                    
                case .natural:
                    switch size.layoutDirection {
                    case .vertical:
                        return min(
                            size.naturalWidth ?? size.contentSize.width,
                            constraint.width.maximum
                        )
                    case .horizontal:
                        return min(
                            size.contentSize.width,
                            constraint.width.maximum
                        )
                    }
                }
            }()
            
            let height : CGFloat = {
                switch verticalFill {
                case .fillParent:
                    return constraint.height.constrainedValue ?? .infinity
                    
                case .natural:
                    switch size.layoutDirection {
                    case .vertical:
                        return min(
                            size.contentSize.height,
                            constraint.height.maximum
                        )
                    case .horizontal:
                        return min(
                            size.naturalWidth ?? size.contentSize.height,
                            constraint.height.maximum
                        )
                    }
                }
            }()
            
            return CGSize(
                width: width,
                height: height
            )
        }
    }
}
