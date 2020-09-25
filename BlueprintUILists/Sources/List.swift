//
//  List.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import BlueprintUI

import ListableUI


///
/// A Blueprint element which can be used to display a Listable `ListView` within
/// an element tree.
///
/// You should use the `List` element as follows, just like you'd use the `configure(with:)` method
/// on `ListView` itself.
/// ```
/// List { list in
///     list.content.header = HeaderFooter(PodcastsHeader())
///
///     let podcasts = Podcast.podcasts.sorted { $0.episode < $1.episode }
///
///     list += Section("podcasts") { section in
///
///         section.header = HeaderFooter(PodcastsSectionHeader())
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
    /// The values which back the on-screen list.
    public var properties : ListProperties
    
    //
    // MARK: Initialization
    //
        
    /// Create a new list, configured with the properties you set on the provided `ListProperties` object.
    public init(build : ListProperties.Build)
    {
        self.properties = .default(with: build)
    }
    
    //
    // MARK: Element
    //
    
    public var content : ElementContent {
        ElementContent { constraint in
            constraint.maximum
        }
    }
    
    public func backingViewDescription(bounds: CGRect, subtreeExtent: CGRect?) -> ViewDescription?
    {
        ListView.describe { config in
            config.builder = {
                ListView(frame: bounds, appearance: self.properties.appearance)
            }
            
            config.apply { listView in
                listView.configure(with: self.properties)
            }
        }
    }
}

