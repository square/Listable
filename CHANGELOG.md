# Master

### Fixed

### Added

### Removed

### Changed

- Update `Item` callbacks to [allow for providing more info to the callback parameters](https://github.com/kyleve/Listable/pull/160).

### Misc

# Past Releases

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
