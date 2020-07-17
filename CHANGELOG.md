# Main

### Fixed

### Added

- Add support for [Behavior.KeyboardAdjustmentMode](https://github.com/kyleve/Listable/pull/166), which allows for disabling automatic keyboard adjustment behavior. This is useful if your container view is managing the size of or insets on a `ListView` itself.

- [Introduced `callAsFunction` support](https://github.com/kyleve/Listable/pull/181) when building with Xcode 11.4 or later. This allows you to replace code like this:

  ```
  List { list in
      list += Section("first") { section in ... }
  }
  ```
  
  - [`.paged()` is now a supported layout type.](https://github.com/kyleve/Listable/pull/178) This allows implementing your list to render similarly to a `UIPageViewController`, in either horizontal or vertical alignment.
  
  With this:
  
  ```
  List { list in
      list("first") { section in ... }
  }
  ```
  
  Improving terseness when building sections in a list.
  

### Removed

- [Removed support for .`horiztonal` layouts](https://github.com/kyleve/Listable/pull/178) on `.list()` layouts. Now only `.vertical` is supported (this could return at a later date if needed).

### Changed

- [Changed `Section` initialization APIs](https://github.com/kyleve/Listable/pull/181) from `Section(identifier: "my-id") { ... }` to `Section("my-id") { ... }` – it's clear from the API what the first param is for, so the param name just made callsites longer.

- [Renamed `setContent` and `setProperties`](https://github.com/kyleve/Listable/pull/178) methods on `ListView` to `configure`.

- [Significant refactors to how the custom layout APIs work.](https://github.com/kyleve/Listable/pull/178) While this is mostly an internal concern, it continues to refine these APIs to set them up for public exposure and usage at a later date to customize layouts.

### Misc

# Past Releases

## 0.7.0

### Fixed

- [Significant performance improvements](https://github.com/kyleve/Listable/pull/179) for list updates which contain either no changes, or only in-place updates to existing items and sections. In many cases, these updates will now be 80% faster. This change also improves performance for other types of changes such as insertions, removals, or moves, but not to the same degree.

### Added

- [Added additional layout configuration options](https://github.com/kyleve/Listable/pull/173/): `headerToFirstSectionSpacing` and `lastSectionToFooterSpacing` now let you control the spacing between the list header and content, and the content and the list footer.

- [Add support for snapshot testing `Item`s](https://github.com/kyleve/Listable/pull/171) via the `ItemPreviewView` class. This is a view type which takes in some configuration options, and an `Item`, which you can then use in snapshot tests to verify the appearance of your `Item` and `ItemContent` .

  ```
  let view = ItemPreviewView()
          
  view.update(
      with: 300.0,
      state: .init(isSelected: false, isHighlighted: false),
      item: Item(MyItemContent(...))
  )

  self.takeSnapshot(of: view)
  ```

- [Add support for Xcode previews](https://github.com/kyleve/Listable/pull/171) via the `ItemPreview` type. This allows easy previewing your `ItemContent` during development like so:

  ```
  struct ElementPreview : PreviewProvider {
      static var previews: some View {
          ItemPreview.withAllItemStates(
              for: Item(XcodePreviewDemoContent(
                  text: "Lorem ipsum dolor sit amet (...)"
              ))
          )
      }
  }
  ```
  
  There are included options like `withAllItemStates` which allow seeing previews across the various possible selection and highlight states.

- Add `customInterSectionSpacing` property to `Section.Layout` which allows the user to specify [custom spacing after a section](https://github.com/kyleve/Listable/pull/172), overriding the calculated spacing.

- [Add `insertAndRemoveAnimations` to `Item`](https://github.com/kyleve/Listable/pull/176) to allow customizing the animations used when an `Item` is inserted or removed from a list. Note that customizing this option when responding to `SwipeActions` will come at a later date.

- [Add `ListViewController`](https://github.com/kyleve/Listable/pull/176) make it easy to create view controllers backed by a Listable `ListView`.

### Removed

### Changed

- Update `Item` callbacks to [allow for providing more info to the callback parameters](https://github.com/kyleve/Listable/pull/160).

- [`ListAppearance.Layout.padding` is now applied around all content in the list](https://github.com/kyleve/Listable/pull/173/), not only around sections. To regain the previous behavior, use `headerToFirstSectionSpacing` and `lastSectionToFooterSpacing`.

- Significantly change how [layout configuration is done](https://github.com/kyleve/Listable/pull/174) to make it clearer which type of layout is currently in use, and which options are available on which layouts.

  Previously, to configure a layout, you would write code like this:

  ```
  list.appearance.layoutType = .list
  list.appearance.list.layout.padding = UIEdgeInsets(...)
  ```

  Now, you configure the layout like this:

  ```
  list.layout = .list {
    $0.layout.padding = UIEdgeInsets(...)
  }
  ```

  Or, for your custom layouts, like this:

  ```
  list.layout = MyCustomLayout.describe {
    $0.myLayoutsProperty = .foo
  }
  ```

### Misc

## 0.6.1

### Changed

- Change `Item`'s `onSelect` and `onDeselect` [to be performed asynchronously](https://github.com/kyleve/Listable/pull/155) after a single runloop spin, to give `UICollectionView` time to schedule animations if these callbacks are slow.
- Add improved signpost logging for selection and deselection, to more easily identify slow callbacks.

## 0.6.0

### Fixed

- Fixed [multiple selection and highlight issues](https://github.com/kyleve/Listable/pull/153): Highlighting cells now only occurs if the `selectionStyle` is `tappable` or `selectable`. Ensure that when `tappable` is provided, the content of a cell is updated when the cell is deselected.

### Added

- Added type aliases for `HeaderFooter` and `HeaderFooterContent` to reduce verbosity of use. Now instead of typing `HeaderFooter(MyHeader())`, you can use `Header(MyHeader())`.
- Replace unused / experimental `Binding` type [with `Coordinator`](https://github.com/kyleve/Listable/pull/143), which allows you to independently manage item state in a similar manner to SwiftUI's `UIViewRepresentable`'s `Coordinator`.

### Removed

### Changed

- **Major Change:** `ItemElement` and `HeaderFooterElement` [were renamed to `ItemContent` and `HeaderFooterContent`](https://github.com/kyleve/Listable/pull/150), respectively. This is intended to be a clearer indicaton as to what they are for (the content of an item or header/footer), and fixes a name collision with Blueprint, where we overloaded the meaning of `Element` when using Blueprint integration via `BlueprintLists`.
- Changed `BlueprintHeaderFooter{Content/Element}`'s main method to be `elementRepresentation` instead of `element`. This allows easier conformance of `BlueprintUI.ProxyElement` types to `BlueprintHeaderFooter{Content/Element}`.
- `SelectionMode` [was moved from `Content` to `Behavior`](https://github.com/kyleve/Listable/pull/152), which is in line with other collection view behaviours like scrolling and underflow.
- Rename `ItemSelectionStyle.none` to `ItemSelectionStyle.notSelectable`. This is to avoid conflicts with `Optional.none` when working with `ItemSelectionStyle` as an `Optional`.

## 0.5.0

### Added

- Added support for [conditionally scrolling to items](https://github.com/kyleve/Listable/pull/129) on insert, based on the `shouldPerform` block passed to the `AutoScrollAction`.

## Earlier

Earlier releases were ad-hoc and not tracked. To see all changes, please reference [closed PRs on Github](https://github.com/kyleve/Listable/pulls?q=is%3Apr+is%3Aclosed).
