# Listable

Listable is a declarative list framework for iOS, which allows you to concisely create rich, live updating list based layouts which are highly customizable across many axes: padding, spacing, number of columns, alignment, etc. It's designed to be performant: Handling lists of 10k+ items without issue on most devices.

```swift
self.listView.setContent { list in
    list += Section(identifier: "section-1") { section in
        
        section.header = HeaderFooter(with: DemoHeader(title: "This Is A Header"))
        
        section += DemoItem(text: "And here is a row")
        section += DemoItem(text: "And here is another row.")
        
        let rows = [
            "You can also map rows",
            "Like this"
        ]
        
        section += rows.map {
            DemoItem(text: $0)
        }
    }

    list += Section(identifier: "section-2") { section in
        
        section.header = HeaderFooter(with: DemoHeader(title: "Another Header"))
        
        section += DemoItem(text: "The last row.")
    }    
}
```

## Features

### Declarative Interface & Intelligent Updates

The core power and benefit of Listable comes from its declarative-style API, which allows you to implement SwiftUI or React style one-way data flow within your app's list views, eliminating many common state management bugs you encouner with standard UITableView or UICollectionView delegate-based solutions. You only need to tell the list what should be in it right now – it does the hard parts of diffing the changes to perform rich animated updates when new content is provided.

Let's say you start with an empty table, like so:

```swift
self.listView.setContent { list in
    // No content right now.
}
```

And then push in new content, so there  is one row with one section:

```swift
self.listView.setContent { list in
    list += Section(identifier: "section-1") { section in
        section.header = HeaderFooter(with: DemoHeader(title: "This Is A Header"))
        
        section += DemoItem(text: "And here is a row")
    } 
}
```

This new section will be animated into place. If you then insert another row:

```swift
self.listView.setContent { list in
    list += Section(identifier: "section-1") { section in
        section.header = HeaderFooter(with: DemoHeader(title: "This Is A Header"))
        
        section += DemoItem(text: "And here is a row")
        section += DemoItem(text: "Another row!")
    } 
}
```

It will also be animated into place by the list.  The same goes for any change you make to the table – a diff will be performed, and the changes will be animated into place. Content that did not change between updates will be unaffected.


### Performant

A core design principle of Listable is performance! Lists are _usually_ small, but not always! For example, within Square Point of Sale, a seller may have an item catalog of 1,000, 10,000, or even more items. When designing Listable, it was important to ensure that it could support lists of these scales with minimum performance cost, to make it easy to build them without paying for performance, or without having to drop back down to standard `UITableView` or `UICollectionView` APIs, which are easy to misuse.

This performance is achieved through an internal batching system, which only queries and diffs the items needed to display the current scroll point, plus some scrollover. Views are only created for what is currently on screen. This allows culling of most content pushed into the list for long lists.

Further, height and sizing measurements are cached more efficiently than in a regular collection view implementation, which for large lists, can boost scrolling performance and prevent droppd frames.


### Highly Customizable

Listable makes very few assumptions of the appearance of your content. The currency you deal with is plain `UIViews` (not `UICollectionViewCells`), so you can draw content however you wish.

Further, the layout and appearance controls vended by `ListView` allow for customization of the layout to draw lists in nearly any way desired.

This is primarily controlled through the `Appearance` object, which is broken down further into ways to control layout direction (horizontal vs. vertical), default sizing, layout controls, and underflow behaviour.

```swift
public struct Appearance : Equatable
{
    public var backgroundColor : UIColor
    
    public var direction : LayoutDirection
    
    public var sizing : ListSizing
    public var layout : ListLayout
    public var underflow : UnderflowBehavior
}
``` 

You use the `ListSizing` struct to control the default measurements within the list: How tall are standard rows, headers, footers, etc.

```swift
public struct ListSizing : Equatable
{
    public var itemHeight : CGFloat
    
    public var sectionHeaderHeight : CGFloat
    public var sectionFooterHeight : CGFloat
    
    public var listHeaderHeight : CGFloat
    public var listFooterHeight : CGFloat
    
    public var itemPositionGroupingHeight : CGFloat
}
```

You can use `ListLayout` to customize the padding of the entire list, how wide the list should be (eg, up to 700px, more than 400px, etc) plus control spacing between items, headers, and footers. 

```swift
public struct ListLayout : Equatable
{
    public var padding : UIEdgeInsets
    public var width : WidthConstraint

    public var interSectionSpacingWithNoFooter : CGFloat
    public var interSectionSpacingWithFooter : CGFloat
    
    public var sectionHeaderBottomSpacing : CGFloat
    public var itemSpacing : CGFloat
    public var itemToSectionFooterSpacing : CGFloat
    
    public var stickySectionHeaders : Bool
}
```

Finally, `UnderflowBehaviour` allows customizing what happens when a list's content is shorter than its container view: Should the scroll view bounce, should the content be centered, etc.

```swift
public struct UnderflowBehavior : Equatable
{
    public var alwaysBounce : Bool
    public var alignment : Alignment
    
    public enum Alignment : Equatable
    {
        case top
        case center
        case bottom
    }
}
```

### Self-Sizing Cells

Another common painpoint for standard `UITableViews` or `UICollectionViews` is handling dynamic and self sizing cells. Listable handles this transparently for you, and provides many ways to size content. Each `Item` has a `sizing` property, which can be set to any of the following values. `.default` pulls the default sizing of the item from the `ListSizing` mentioned above, where as the `thatFits` and `autolayout` values size the item based on `sizeThatFits` and `systemLayoutSizeFitting`, respectively.

```swift
public enum Sizing : Equatable
{
    case `default`
    
    case fixed(CGFloat)
    
    case thatFits
    case thatFitsWith(Constraint)
    
    case autolayout
    case autolayoutWith(Constraint)
}
```

### Integrates With Blueprint

Listable integrates closely with [Blueprint](https://github.com/square/blueprint/), Square's framework for declarative UI construction and management (if you've used SwiftUI, Blueprint is similar). Listable provides wrapper types and default types to make using Listable lists within Blueprint elements simple, and to make it easy to build Listable items out of Blueprint elements.

All you need to do is take a dependency on the `BlueprintLists` pod, and then `import BlueprintLists` to begin using Blueprint integration.

In this example, we see how to declare a `List` within a Blueprint element hierarchy.

```swift
var elementRepresentation : Element {
    List { list in
        list += Section(identifier: "section") { section in
            
            section += self.podcasts.map {
                PodcastRow(podcast: $0)
            }
        }
    }
}
```

And in this example, we see how to create a simple `BlueprintItemElement` that uses Blueprint to render its content.

```swift
struct DemoItem : BlueprintItemElement, Equatable
{
    var text : String
    
    // ItemElement
    
    var identifier: Identifier<DemoItem> {
        return .init(self.text)
    }
    
    // BlueprintItemElement    
    
    func element(with info : ApplyItemElementInfo) -> Element
    {
        var box = Box(
            backgroundColor: .white,
            cornerStyle: .rounded(radius: 6.0),
            wrapping: Inset(
                uniformInset: 10.0,
                wrapping: Label(text: self.text)
            )
        )
        
        box.borderStyle = .solid(color: .white(0.9), width: 2.0)
        
        return box
    }
}
```


## Primary API & Surface Area

Most of your interaction will be three primary families of types: `ListView`, `Item`,  `HeaderFooter`, and `Section`. 

### ListView
The list that you put content into! Beyond allocating a list and putting it on screen, the bulk of your interaction with `ListView` will be through the `setContent` API shown above.

```swift
self.listView.setContent { list in
    // Set list appearance, specify content, etc...
}
```

What is that `list` parameter, you ask...?

### ListDescription
`ListDescription` is a struct which contains all the information required to render a list update.

```swift
public struct ListDescription
{
    public var animatesChanges : Bool
    
    public var appearance : Appearance
    public var behavior : Behavior
    public var scrollInsets : ScrollInsets
    
    public var content : Content
}
```

This allows you to confgure the list view however needed within the `setContent` update.


### Item
You can think of `Item` as the wrapper for the content _you_ provide to the list – similar to how a `UITableViewCell` wraps a content view and provides other configuration options. 

An `Item` is what you add to a section to represent a row in a list. It contains your provided content (`ItemElement`), plus the appearance of the item (`ItemElementAppearance`), alongside things like sizing, layout customization, selection behaviour, reordering behaviour, and callbacks which are performed when an item is selected, displayed, etc.

```swift
public struct Item<Element:ItemElement> : AnyItem
{
    public var identifier : AnyIdentifier
    
    public var element : Element
    public var appearance : Element.Appearance
    
    public var sizing : Sizing
    public var layout : ItemLayout
    
    public var selection : ItemSelection
    
    public var swipeActions : SwipeActions?
    
    public var reordering : Reordering?
        
    public typealias OnSelect = (Element) -> ()
    public var onSelect : OnSelect?
    
    public typealias OnDeselect = (Element) -> ()
    public var onDeselect : OnDeselect?
    
    public typealias OnDisplay = (Element) -> ()
    public var onDisplay : OnDisplay?
    
    public typealias OnEndDisplay = (Element) -> ()
    public var onEndDisplay : OnEndDisplay?
}
```
You can add an item to a section via either the `add` function, or via the `+=` override. 

```swift
section += Item(
    with: AnElement(title: "Hello, World!"),
    appearance: StandardRowAppearance(),
    sizing: .default,
    selection: .notSelectable
)
```

However, if you want to use all default values from the `Item` initializer, and your `ItemElement` conforms to `ItemElementAppearance`, you can skip a step and simply add your `ItemElement` to the section directly.

```swift
section += AnElement(title: "Hello, World!")
```


#### ItemElement
The core value type which represents row content. This view model which describes the content of a given row / item, via the `identifier`, and the `wasMoved` and `wasUpdated` methods. You describe how it's drawn via the `Appearance` `associatedtype`. When it's time to display the item on screen, or size an item, `apply(to:for:with:)` is called, which is where you push the content from your `ItemElement` onto a view.

```swift
public protocol ItemElement
{
    var identifier : Identifier<Self> { get }

    associatedtype Appearance:ItemElementAppearance

    func apply(to view : Appearance.ContentView, for reason: ApplyReason, with info : ApplyItemElementInfo)

    func wasMoved(comparedTo other : Self) -> Bool
    func wasUpdated(comparedTo other : Self) -> Bool
}
```

You usually do not need to implement all these! If your `ItemElement` is `Equatable`, you get `wasUpdated` for free – and by default, `wasMoved` is the same was `wasUpdated`.

```swift
public extension ItemElement
{
    func wasMoved(comparedTo other : Self) -> Bool
    {
        return self.wasUpdated(comparedTo: other)
    }
}


public extension ItemElement where Self:Equatable
{
    func wasUpdated(comparedTo other : Self) -> Bool
    {
        return self != other
    }
}
```

This is all a bit abstract, so consider the following example: An `ItemElement` which provides a title and detail label.

```swift
struct SubtitleItem : ItemElement, Equatable
{
    var title : String
    var detail : String
    
    // ItemElement

    typealias Appearance = SubtitleItemAppearance

    func apply(to view : Appearance.ContentView, for reason: ApplyReason, with info : ApplyItemElementInfo)
    {
        view.titleLabel.text = self.title
        view.detailLabel.text = self.detail        
    }
}
```

What is `SubtitleItemAppearance`...?

#### ItemElementAppearance
The visual appearance of an item! Why is this separate from `ItemElement`? To allow multiple underlying model types to share the same appearance, and to split overall concerns: `ItemElement` is concerned with binding content to a view, and `ItemElementAppearance` is concerned with how to draw and set up that view. It has a similar API to `ItemElement`.

```swift
public protocol ItemElementAppearance
{
    associatedtype ContentView:UIView
    
    static func createReusableItemView(frame : CGRect) -> ContentView
    
    func apply(to view : ContentView, with info : ApplyItemElementInfo)
    
    func wasUpdated(comparedTo other : Self) -> Bool
}
```

If your `ItemElementAppearance` is `Equatable`, you get `wasUpdated` for free.

```swift
public extension ItemElementAppearance where Self:Equatable
{
    func wasUpdated(comparedTo other : Self) -> Bool
    {
        return self != other
    }
}
```

Continuing the example from above, an implementation of `SubtitleItemAppearance` might look like this. We'll assume a theme is passed to ensure the appearance matches the look of the app.

```swift
struct SubtitleItemAppearance : ItemElementAppearance
{
    var theme : AppTheme // Assume `AppTheme` is Equatable.
    
    // ItemElementAppearance

    typealias ContentView = View

    static func createReusableItemView(frame : CGRect) -> ContentView
    {
        return View(frame: frame)
    }

    func apply(to view : ContentView, with info : ApplyItemElementInfo)
    {
        // Apply the values from the theme.
    
        view.titleLabel.font = theme.headerFont
        view.titleLabel.textColor = theme.headerColor
        
        view.detailLabel.font = theme.detailFont
        view.detailLabel.textColor = theme.detailColor
    }
    
    final class View : UIView
    {
        let titleLabel : UILabel
        let detailLabel : UILabel
        
        ... The rest of the view implementation. 
    }
}
```

### HeaderFooter
How to describe a header or footer within a list. Very similar API to `ItemElement`, but with less stuff, as headers and footers are display-only.

```
public struct HeaderFooter<Element:HeaderFooterElement> : AnyHeaderFooter
{
    public var element : Element
    public var appearance : Element.Appearance
    
    public var sizing : Sizing
    public var layout : HeaderFooterLayout
}
```

You set headers and footers on sections via the `header` and `footer` parameter.

```swift
self.listView.setContent { list in
    list += Section(identifier: "section-1") { section in
        section.header = HeaderFooter(with: DemoHeader(title: "This Is A Header"))
        section.footer = HeaderFooter(with: DemoFooter(text: "And this is a footer. Please check the EULA for details."))
    } 
}
```

#### HeaderFooterElement
Again, a similar API to  `ItemElement`, but with a reduced surface area, given the reduced concerns of header and footers.

```swift
public protocol HeaderFooterElement
{\
    associatedtype Appearance:HeaderFooterElementAppearance

    func apply(to view : Appearance.ContentView, reason : ApplyReason)

    func wasUpdated(comparedTo other : Self) -> Bool
}
```

As usual, if your `HeaderFooterElement` is `Equatable`, you get `wasUpdated` for free.

```swift
public extension HeaderFooterElement where Self:Equatable
{    
    func wasUpdated(comparedTo other : Self) -> Bool
    {
        return self != other
    }
}
```

A standard implementation may look like this:

```swift
struct Header : HeaderFooterElement, Equatable
{
    var title : String
    
    // HeaderFooterElement

    typealias Appearance = HeaderAppearance

    func apply(to view : Appearance.ContentView, for reason: ApplyReason)
    {
        view.titleLabel.text = self.title       
    }
}
```

#### HeaderFooterElementAppearance
As with `ItemElementAppearance`,  `HeaderFooterElementAppearance` describes how your header or footer appears on screen. 

```swift
public protocol HeaderFooterElementAppearance
{
    associatedtype ContentView:UIView
    
    static func createReusableHeaderFooterView(frame : CGRect) -> ContentView
    
    func apply(to view : ContentView)
    
    func wasUpdated(comparedTo other : Self) -> Bool
}
```

Per usual, you get `wasUpdated` for free if you're `Equatable`:

```swift
public extension HeaderFooterElementAppearance where Self:Equatable
{
    func wasUpdated(comparedTo other : Self) -> Bool
    {
        return self != other
    }
}

```

Completing the above example, we end up with this:

```swift
struct HeaderAppearance : HeaderFooterElementAppearance, Equatable
{
    var theme : AppTheme // Assume `AppTheme` is Equatable.

    // HeaderFooterElementAppearance

    typealias ContentView = View
    
    static func createReusableHeaderFooterView(frame : CGRect) -> ContentView
    {
        return View(frame: frame)
    }
    
    func apply(to view : ContentView)
    {
        // Apply the values from the theme.
    
        view.titleLabel.font = theme.headerFont
        view.titleLabel.textColor = theme.headerColor
    }
        
    final class View : UIView
    {
        let titleLabel : UILabel
        
        ... The rest of the view implementation.         
    }
}
```

### Section
`Section` – surprise – represents a given section in a list. Most of your interaction with `Section` will be through the init & builder API, as shown above.

```swift
Section(identifier: "section") { section in
    section += self.podcasts.map {
        PodcastRow(podcast: $0)
    }
}
```

However, section has many properties to allow for configuration. You can customize the layout, the number of and layout of columns, set the header and footer, and obviously provide items, via the `items` property, and via the many provided overrides of the `+=` operator.

```swift
public struct Section
{    
    public var layout : Layout
    public var columns : Columns
    
    public var header : AnyHeaderFooter?
    public var footer : AnyHeaderFooter?
    
    public var items : [AnyItem]
}
```

Additionally, if you're using Blueprint integration with  `BlueprintLists`, you will also interact with the following types.

### List
Without Blueprint, you'd usually use `list.setContent { ... }`. However Blueprint trees are just descriptions of UI – as such, `List` is just a struct which describes a list.

```swift
var elementRepresentation : Element {
    List { list in
        list += Section(identifier: "section") { section in
            
            section += self.podcasts.map {
                PodcastRow(podcast: $0)
            }
        }
    }
}
````

### BlueprintItemElement
`BlueprintItemElement` simplifies the `ItemElement` creation process, asking you for only an `Element` description.

```swift
public protocol BlueprintItemElement : ItemElement where Appearance == BlueprintItemElementAppearance
{
    func element(with info : ApplyItemElementInfo) -> BlueprintUI.Element
}
```

### BlueprintHeaderFooterElement
Similarly, `` makes creating a header or footer easy – just implement `element`.

```swift
public protocol BlueprintHeaderFooterElement : HeaderFooterElement where Appearance == BlueprintHeaderFooterElementAppearance
{
    var element : BlueprintUI.Element { get }
}
```


## Getting Started

Listable can be consumed via CocoaPods. Add one or both of these lines to your `Podfile` in order to consume Listable and BlueprintLists (the Blueprint wrapper for Listable).

```
  pod 'BlueprintLists', git: 'ssh://git@github.com:kyleve/Listable.git'
  pod 'Listable', git: 'ssh://git@github.com:kyleve/Listable.git'
```

You can then add the following to each `podspec` which should depend on Listable.

```
s.dependency 'Listable'
s.dependency 'BlueprintLists'
```

## Demo Project
If you'd like to see examples of Listable in use, clone the repo, and then run `bundle exec pod install` in the root of the repo. This will create the `Demo/Demo.xcworkspace` workspace, which you can open and run. It contains examples of various types of screens and use cases.


# Other Neat Stuff

### You can nest Lists in other lists.
You can nest horizontal scrolling Lists within vertical scrolling lists to create advanced, custom layouts. Listable provides a `ListItemElement` to make this easy.

### You can override many layout parameters on a per-item and per-header/footer basis.
By setting the `layout` parameter on `Item` or `HeaderFooter`, you can specify the alignment of each item within a layout, how much padding it should have, how much spacing it can have, etc.


# Appendix

## Implementation Details

### Rendering & Display
Listable is built on top of `UICollectionView`, with a custom `UICollectionViewLayout` though this is not exposed to consumers.

### Performance
Internally, performance is achieved through transparent batching of content that is loaded into the collection view itself. This allows pushing large amounts
of content into the list, but `ListView` is intelligent enough to only load, measure, diff, etc, enough of that content to display the current scroll position,
plus some scroll overflow. In practice, this means that even if you put 50,000 items into a list, if the user is scrolled at the top of the table, only a few hundred
items will be measured, diffed, and take up computation time during initial rendering and updates. This allows performance to remain nearly constant, regardless
of what content is pushed into the list. The farther down a user scrolls, the more computation must be completed.

### View State Management
Internally, every item drawn on screen and visible in the list is represented by a long-lived `PresentationState` instance, which tracks visible cells, sizing measurements, etc.
This long lived object allows an extra layer which means it's easy to cache height calculations across multiple content updates in the list view, allowing for further performance
improvements and optimizations. This is transparent to the developer.


## Why?

Building rich and interactive list views and lists on iOS remains a challenge. Maintaining state and performing animations on changes is tricky and error prone. More often than not, there are lurking state bugs that result in inconsistent data or crashes that are hard to diagnose and debug.

Historically, we have managed list view state one of a few ways...

1) Via Core Data and NSFetchedResultsController, which handles diffing and updates. However, this binds your UI tightly to the underlying core data model, which makes changes difficult and error prone. You end up needing to model UI concerns deep in your Core Data model to sort and section your data as you want. No good.

2) Use other options such as common block-based table view or collection view builders – which abstracts some of the complexity away from developers, but it still deals in the currency of cells and views – and makes it difficult to properly handle animations and updates.

3) Sometimes, you end up just giving up and calling reloadData() any time anything in your table’s data source changes – this sucks because users don’t see animations which indicate to them what changed.

4) Or, even worse, you end up managing insertions, deletions, and updates yourself, which usually goes something like this…


> Call beginUpdates
> 
> Call insertRow:atIndexPath:
> Call insertRow:atIndexPath:
> Call moveRowAtIndexPath:toIndexPath:
> Etc..
> 
> Call endUpdates
> 
> Assertion failure in UITableView/UICollectionView.m:20000000: The number of rows before the update is not equal to > the number of rows after the update, plus or minus the added and removed rows. You suck, nerd!
> 
> [Crash]

Needless to say, none of these options are great, and all of these are state-of-the-art circa about 2011 – which was a long time ago.

