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

Listable can be consumed via CocoaPods. Add one or both of these lines to your Podfile in order to consume Listable and BlueprintLists (the Blueprint wrapper for Listable).

```
  pod 'BlueprintLists', git: 'ssh://git@github.com:kyleve/Listable.git'
  pod 'Listable', git: 'ssh://git@github.com:kyleve/Listable.git'
```

## Demo Project
If you'd like to see examples of Listable in use, clone the repo, and then run `bundle exec pod install` in the root of the repo. This will create the `Demo/Demo.xcworkspace` workspace, which you can open and run. It contains examples of various types of screens and use cases.

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

