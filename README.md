# Listable

Listable is a declarative list framework for iOS, which allows you to concisely create rich, live updating list based layouts which are highly customizable across many axes: padding, spacing, number of columns, alignment, etc. It's designed to be performant: Handling lists of 10k+ items without issue on most devices.

```
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

```
self.listView.setContent { list in
    // No content right now.
}
```

And then push in new content, so there  is one row with one section:

```
self.listView.setContent { list in
    list += Section(identifier: "section-1") { section in
        section.header = HeaderFooter(with: DemoHeader(title: "This Is A Header"))
        
        section += DemoItem(text: "And here is a row")
    } 
}
```

This new section will be animated into place. If you then insert another row:

```
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

A core design principle of Listable is performance! Lists are _usually_ small, but not always! For example, within Square Point of Sale, a seller may have an item catalog of 1,000, 10,000, or even more items. When designing Listable, it was important to ensure that it could support lists of these scales with minimum performance cost, to make it easy to build them without paying for performance, or without having to drop back down to standard UITableView or UICollectionView APIs, which are easy to misuse.

This performance is achieved through an internal batching system, which only queries and diffs the items needed to display the current scroll point, plus some scrollover. Views are only created for what is currently on screen. This allows culling of most content pushed into the list for long lists.

Further, height and sizing measurements are cached more efficiently than in a regular collection view implementation, which for large lists, can boost scrolling performance and prevent droppd frames.


### Highly Customizable

Listable makes very few assumptions of the appearance of your content. The currency you deal with is plain UIViews (not UICollectionViewCells), so you can draw content however you wish.

Further, the layout and appearance controls vended by `ListView` allow for customization of the layout to draw lists in nearly any way desired. This is primarily controlled through the `Appearance` object, which is broken down further into ways to control layout direction (horizontal vs. vertical), default sizing, layout controls, and underflow behaviour.

```
public struct Appearance : Equatable
{
    public var backgroundColor : UIColor
    
    public var direction : LayoutDirection
    
    public var sizing : ListSizing
    public var layout : ListLayout
    public var underflow : UnderflowBehavior
}
``` 

```
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

```
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

```
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



### Integrates With Blueprint


## Primary API & Surface Area

Most of your interaction will be three primary families of types.

### ListView


### Item
#### ItemElement
#### ItemElementAppearance

### HeaderFooter
#### HeaderFooterElement
#### HeaderFooterElementAppearance

Additionally, if you're using  `BlueprintLists`, you will also interact with the following types.

### List

### BlueprintItemElement
### BlueprintHeaderFooterElement


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

