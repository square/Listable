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
                
            case .measureContent(let horizontalFill, let verticalFill, let limit):
                return ElementContent() { constraint -> CGSize in
                    let measurements = ListView.contentSize(
                        in: constraint.maximum,
                        for: self.properties,
                        safeAreaInsets: .zero,
                        itemLimit: limit
                    )
                    
                    return Self.size(
                        with: measurements,
                        in: constraint,
                        horizontalFill: horizontalFill,
                        verticalFill: verticalFill
                    )
                }
            }
        }
        
        public func backingViewDescription(with context: ViewDescriptionContext) -> ViewDescription?
        {
            ListView.describe { config in
                config.builder = {
                    ListView(frame: context.bounds, appearance: self.properties.appearance)
                }
                
                config.apply { listView in
                    listView.configure(with: self.properties)
                }
            }
        }
        
        static func size(
            with size : MeasuredListSize,
            in constraint : SizeConstraint,
            horizontalFill : Measurement.FillRule,
            verticalFill : Measurement.FillRule
        ) -> CGSize
        {
            let width : CGFloat = {
                switch horizontalFill {
                case .fillParent:
                    if let max = constraint.width.constrainedValue {
                        return max
                    } else {
                        fatalError(
                            """
                            `List` is being used with the `.fillParent` measurement option, which takes \
                            up the full width it is afforded by its parent element. However, \
                            the parent element provided the `List` an unconstrained width, which is meaningless.
                            
                            How do you fix this?
                            --------------------
                            1) This usually means that your `List` itself has been \
                            placed in a `ScrollView` or other element which intentionally provides an \
                            unconstrained measurement to its content. If your `List` is in a `ScrollView`, \
                            remove the outer scroll view – `List` manages its own scrolling. Two `ScrollViews` \
                            that are nested within each other is generally meaningless unless they scroll \
                            in different directions (eg, horizontal vs vertical).
                            
                            2) If your `List` is not in a `ScrollView`, ensure that the element
                            measuring it is providing a constrained `SizeConstraint`.
                            """
                        )
                    }
                case .natural:
                    return size.naturalWidth ?? size.contentSize.width
                }
            }()
            
            let height : CGFloat = {
                switch verticalFill {
                case .fillParent:
                    if let max = constraint.height.constrainedValue {
                        return max
                    } else {
                        fatalError(
                            """
                            `List` is being used with the `.fillParent` measurement option, which takes \
                            up the full height it is afforded by its parent element. However, \
                            the parent element provided the `List` an unconstrained height, which is meaningless.
                            
                            How do you fix this?
                            --------------------
                            1) This usually means that your `List` itself has been \
                            placed in a `ScrollView` or other element which intentionally provides an \
                            unconstrained measurement to its content. If your `List` is in a `ScrollView`, \
                            remove the outer scroll view – `List` manages its own scrolling. Two `ScrollViews` \
                            that are nested within each other is generally meaningless unless they scroll \
                            in different directions (eg, horizontal vs vertical).
                            
                            2) If your `List` is not in a `ScrollView`, ensure that the element
                            measuring it is providing a constrained `SizeConstraint`.
                            """
                        )
                    }
                case .natural:
                    return size.contentSize.height
                }
            }()
            
            return CGSize(
                width: width,
                height: height
            )
        }
    }
}
