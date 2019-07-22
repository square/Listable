
import Foundation

private class ListableResourcesBundleFinderClass: NSObject {}

extension Bundle {
    static var ListableResourcesBundle: Bundle {
        let mainBundle = Bundle(for: ListableResourcesBundleFinderClass.self)

        guard let bundleURL = mainBundle.url(forResource: "ListableResources", withExtension: "bundle"),
              let bundle = Bundle(url: bundleURL) else {
            fatalError("Could not find resource bundle for Listable within main application bundle.")
        }

        return bundle
    }
}
