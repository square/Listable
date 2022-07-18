//
//  List.Measurement.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 3/25/21.
//

import ListableUI


///
/// Provides the possible options for how to size and measure a list when its measured size is queried
/// by the layout system.
///
/// You have two options: `.fillParent` and `.measureContent`.
///
/// When using  `.fillParent`, the full available fitting size will be taken up, regardless
/// of the size of the content itself.
///
/// When using `.measureContent`, the content will be measured within the provided fitting size
/// and the smallest of the two sizes will be returned.
/// ```
/// .fillParent:
/// ┌───────────┐
/// │┌─────────┐│
/// ││         ││
/// ││         ││
/// ││         ││
/// ││         ││
/// ││         ││
/// │└─────────┘│
/// └───────────┘
///
/// .measureContent
/// ┌───────────┐
/// │           │
/// │           │
/// │┌─────────┐│
/// ││         ││
/// ││         ││
/// ││         ││
/// │└─────────┘│
/// └───────────┘
/// ```
extension List {
    
    public enum Measurement : Equatable
    {
        /// When using  `.fillParent`, the full available space will be taken up, regardless
        /// of the content size of the list itself.
        ///
        /// Eg, if the fitting size passed to the list is (200w, 1000h), and the list's content
        /// is only (200w, 500h), (200w, 1000h) will still be returned.
        ///
        /// This is the setting you want to use when your list is being used to fill the content
        /// of a screen, such as if it is being presented in a navigation controller or tab bar controller.
        ///
        /// This option is the most performant, because no content measurement has to occur.
        case fillParent
        
        /// When using `.measureContent`, the content of the list will be measured within the provided fitting size
        /// and the smallest of the two sizes will be returned.
        ///
        /// If you are putting a list into a sheet or popover (or even another list!), this is generally the `Sizing` type
        /// you will want to use, to ensure the sheet or popover takes up the minimum amount of space possible.
        ///
        /// - parameters:
        ///    - cacheKey: If provided, the underlying `Element`'s `measurementCacheKey` will be set to this value.
        ///     Note that this value must be unique within the entire blueprint view – so please provide a sufficiently unique value,
        ///     or measurement collisions will occur (one element's measurement being used for another) for duplicate keys.
        ///
        ///    - horizontalFill: Defaults to `.fillParent`. How the width of the element should be calculated. If the
        ///     provided value is `.natural`, the width returned will be as wide as needed to display the widest element,
        ///     within the `itemLimit`.
        ///
        ///    - verticalFill: Defaults to `.natural`. How the height of element should be calculated. For `.natural` heights, if the list requires less vertical space than it is given to lay out, that smaller value will be returned from measurements.
        ///
        ///    - safeArea: Defaults to `.none`. The safe area, if any, to include in the content sizing calculation.
        ///
        ///    - itemLimit: When measuring the list, how many items should be measured to determine the height. Defaults
        ///     to 50, which is usually enough to fill the `fittingSize`. If you truly want to determine the entire height of all of
        ///     the content in the list, set this to `nil` (but you should rarely need to do this). The lower this value, the less
        ///     overall measurement that has to occur (if the value is less than the number of items in the list), which improvements
        ///     measurement and layout performance.
        ///
        case measureContent(
            horizontalFill : FillRule = .fillParent,
            verticalFill : FillRule = .natural,
            safeArea: SafeArea = .none,
            itemLimit : Int? = ListView.defaultContentSizeItemLimit
        )
        
        var needsMeasurement : Bool {
            switch self {
            case .fillParent:
                return false
            case .measureContent(let horizontalFill, let verticalFill, _, _):
                return horizontalFill.needsMeasurement || verticalFill.needsMeasurement
            }
        }
    }
}


extension List.Measurement {
    
    /// Controls how the safe area is used when calculating content size.
    /// The safe area included in the calculation affected by the list layout's `contentInsetAdjustmentBehavior`.
    public enum SafeArea : Equatable {
        
        /// No safe area will be included in the size calculation.
        case none
        
        /// The safe area from the blueprint environment will be included in the calculation.
        case environment
        
        /// The provided safe area will be included in the calculation.
        case custom(UIEdgeInsets)
        
        func safeArea(with environment : BlueprintUI.Environment) -> UIEdgeInsets {
            switch self {
            case .none: return .zero
            case .environment: return environment.safeAreaInsets
            case .custom(let value): return value
            }
        }
    }
    
    /// How to fill a given axis when performing a `List.Measurement.measureContent` measurement.
    public enum FillRule : Equatable {
        
        /// The full amount of space afforded to the list by its parent element will
        /// be used. The measurement from the list is not used.
        case fillParent
        
        /// The amount of space needed, as determined by the list's measurement will be used.
        ///
        /// Eg, if you provide 1000pt of vertical space, but the list only needs 300pt to display,
        /// 300pt will be returned from the measurement.
        case natural
        
        var needsMeasurement : Bool {
            switch self {
            case .fillParent:
                return false
            case .natural:
                return true
            }
        }
    }
}
