**Note** – Listable is still experimental :see_no_evil:. While it is shipping in [Square Point of Sale](https://squareup.com/us/en/point-of-sale) in several places, we're still actively iterating on the API, and backfilling comprehensive tests. As such, expect things to break and change in the coming months.

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

The core power and benefit of Listable comes from its declarative-style API, which allows you to implement SwiftUI or React style one-way data flow within your app's list views, eliminating many common state management bugs you encounter with standard UITableView or UICollectionView delegate-based solutions. You only need to tell the list what should be in it right now – it does the hard parts of diffing the changes to perform rich animated updates when new content is provided.

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

Further, height and sizing measurements are cached more efficiently than in a regular collection view implementation, which for large lists, can boost scrolling performance and prevent dropped frames.


### Highly Customizable

Listable makes very few assumptions of the appearance of your content. The currency you deal with is plain `UIViews` (not `UICollectionViewCells`), so you can draw content however you wish.

Further, the layout and appearance controls vended by `ListView` allow for customization of the layout to draw lists in nearly any way desired.

This is primarily controlled through the `Appearance` object:

```swift
public struct Appearance : Equatable
{
    public var backgroundColor : UIColor
    
    public var direction : LayoutDirection
    
    public var stickySectionHeaders : Bool
    
    public var list : ListAppearance
}
``` 

You use the `ListAppearance.Sizing` struct to control the default measurements within the list: How tall are standard rows, headers, footers, etc.

```swift
public struct ListAppearance.Sizing : Equatable
{
    public var itemHeight : CGFloat
    
    public var sectionHeaderHeight : CGFloat
    public var sectionFooterHeight : CGFloat
    
    public var listHeaderHeight : CGFloat
    public var listFooterHeight : CGFloat
    
    public var itemPositionGroupingHeight : CGFloat
}
```

You can use `ListAppearance.Layout` to customize the padding of the entire list, how wide the list should be (eg, up to 700px, more than 400px, etc) plus control spacing between items, headers, and footers. 

```swift
public struct ListAppearance.Layout : Equatable
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

Finally, the `Behavior` and  `Behavior.Underflow` allows customizing what happens when a list's content is shorter than its container view: Should the scroll view bounce, should the content be centered, etc.

```swift
public struct Behavior : Equatable
{
    public var keyboardDismissMode : UIScrollView.KeyboardDismissMode
    
    public var underflow : Underflow
```

```swift

struct Underflow : Equatable
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

Another common pain-point for standard `UITableViews` or `UICollectionViews` is handling dynamic and self sizing cells. Listable handles this transparently for you, and provides many ways to size content. Each `Item` has a `sizing` property, which can be set to any of the following values. `.default` pulls the default sizing of the item from the `ListSizing` mentioned above, where as the `thatFits` and `autolayout` values size the item based on `sizeThatFits` and `systemLayoutSizeFitting`, respectively.

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

## Instruments.app Integration

Listable provides integration with the `os_signpost` API for measuring the duration of events in your application. If you are experiencing issues with list performance in your app, you can profile it in Instruments, and add the `os_signpost` instrument to inspect the timing for various layout and update passes.

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

    public var layoutType : ListLayoutType
    public var appearance : Appearance
    
    public var behavior : Behavior
    public var autoScrollAction : AutoScrollAction
    public var scrollInsets : ScrollInsets
    
    public var accessibilityIdentifier: String?
    
    public var content : Content
}
```

This allows you to configure the list view however needed within the `setContent` update.


### Item
You can think of `Item` as the wrapper for the content _you_ provide to the list – similar to how a `UITableViewCell` wraps a content view and provides other configuration options. 

An `Item` is what you add to a section to represent a row in a list. It contains your provided content (`ItemElement`), alongside things like sizing, layout customization, selection behavior, reordering behavior, and callbacks which are performed when an item is selected, displayed, etc.

```swift
public struct Item<Element:ItemElement> : AnyItem
{
    public var identifier : AnyIdentifier
    
    public var element : Element
    
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
    AnElement(title: "Hello, World!"),
    
    sizing: .default,
    selection: .notSelectable
)
```

However, if you want to use all default values from the `Item` initializer, you can skip a step and simply add your `ItemElement` to the section directly.

```swift
section += AnElement(title: "Hello, World!")
```


### ItemElement
The core value type which represents an item's content.

This view model describes the content of a given row / item, via the `identifier`, plua the `wasMoved` and `isEquivalent` methods.

To convert an `ItemElement` into views for display, the  `createReusableContentView(:)` method is called to create a reusable view to use when displaying the element (the same happens for background views as well).

To prepare the views for display, the `apply(to:for:with:)` method is called, which is where you push the content from your `ItemElement` onto the provided views.

```swift
public protocol ItemElement
{
    var identifier : Identifier<Self> { get }

    func apply(
        to views : ItemElementViews<Self>,
        for reason: ApplyReason,
        with info : ApplyItemElementInfo
    )

    func wasMoved(comparedTo other : Self) -> Bool
    func isEquivalent(to other : Self) -> Bool

    associatedtype ContentView:UIView
    static func createReusableContentView(frame : CGRect) -> ContentView

    associatedtype BackgroundView:UIView = UIView
    static func createReusableBackgroundView(frame : CGRect) -> BackgroundView

    associatedtype SelectedBackgroundView:UIView = BackgroundView
    static func createReusableSelectedBackgroundView(frame : CGRect) -> SelectedBackgroundView
}
```

Note however, you usually do not need to implement all these methods! For example, if your `ItemElement` is `Equatable`, you get `isEquivalent` for free – and by default, `wasMoved` is the same was `isEquivalent(other:) == false`.

```swift
public extension ItemElement
{
    func wasMoved(comparedTo other : Self) -> Bool
    {
        return self.isEquivalent(to: other) == false
    }
}


public extension ItemElement where Self:Equatable
{
    func isEquivalent(to other : Self) -> Bool
    {
        return self == other
    }
}
```

The `BackgroundView` and `SelectedBackgroundView` views also default to a plain `UIView` which do not display any content of their own. You only need to provide these background views if you wish to support customization of the appearance of the item during highlighting and selection.

```swift
public extension ItemElement where BackgroundView == UIView
{
    static func createReusableBackgroundView(frame : CGRect) -> BackgroundView
    {
        BackgroundView(frame: frame)
    }
}
```

The `SelectedBackgroundView` also defaults to the type of `BackgroundView` unless you explicitly want two different view types.

```swift
public extension ItemElement where BackgroundView == SelectedBackgroundView
{
    static func createReusableSelectedBackgroundView(frame : CGRect) -> BackgroundView
    {
        self.createReusableBackgroundView(frame: frame)
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

    func apply(to views : ItemElementViews<Self>, for reason: ApplyReason, with info : ApplyItemElementInfo)
    {
        views.content.titleLabel.text = self.title
        views.content.detailLabel.text = self.detail        
    }
    
    typealias ContentView = View
    
    static func createReusableContentView(frame : CGRect) -> ContentView
    {
        View(frame: frame)
    }
    
    private final class View : UIView
    {
        let titleLabel : UILabel
        let detailLabel : UILabel
        
        ...
    }
}
```

### HeaderFooter
How to describe a header or footer within a list. Very similar API to `ItemElement`, but with less stuff, as headers and footers are display-only.

```swift
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

    func isEquivalent(to other : Self) -> Bool
}
```

As usual, if your `HeaderFooterElement` is `Equatable`, you get `isEquivalent` for free.

```swift
public extension HeaderFooterElement where Self:Equatable
{    
    func isEquivalent(to other : Self) -> Bool
    {
        return self == other
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
    
    func isEquivalent(to other : Self) -> Bool
}
```

Per usual, you get `isEquivalent` for free if you're `Equatable`:

```swift
public extension HeaderFooterElementAppearance where Self:Equatable
{
    func isEquivalent(to other : Self) -> Bool
    {
        return self == other
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

## Integration With Blueprint

If you're using Blueprint integration via the  `BlueprintLists` module, you will also interact with the following types.

### List
When using `ListView` directly, you'd use `list.setContent { list in ... }` to set the content of a list. However, Blueprint element trees are just descriptions of UI – as such, `List` is just a Blueprint `Element` which describes a list. The parameter passed to `List { list in ... }` is the same type (`ListDescription`) that is passed to  `list.setContent { list in ... }`.

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
`BlueprintItemElement` simplifies the `ItemElement` creation process, asking you for an `Element` description, instead of view types and view instances. 

Unless you are supporting highlighting and selection of your `ItemElement`, you do not need to provide implementations of `backgroundElement(:)` and `selectedBackgroundElement(:)` – they default to returning nil. Similar to `ItemElement`, `wasMoved(:)` and `isEquivalent(:)` are also provided based on `Equatable` conformance.

```swift
public protocol BlueprintItemElement : ItemElement where Appearance == BlueprintItemElementAppearance
{
    var identifier : Identifier<Self> { get }

    func wasMoved(comparedTo other : Self) -> Bool
    func isEquivalent(to other : Self) -> Bool

    func element(with info : ApplyItemElementInfo) -> BlueprintUI.Element
    
    func backgroundElement(with info : ApplyItemElementInfo) -> BlueprintUI.Element?

    func selectedBackgroundElement(with info : ApplyItemElementInfo) -> BlueprintUI.Element?
}
```

### BlueprintHeaderFooterElement
Similarly, `BlueprintHeaderFooterElement` makes creating a header or footer easy – just implement `element`.

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


## Legal Stuff

Copyright 2019 Square, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License
