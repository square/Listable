//
//  ViewHierarchySnapshot.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/26/19.
//

import UIKit

public struct ViewHierarchySnapshot: SnapshotOutputFormat {
  // MARK: SnapshotOutputFormat

  public typealias RenderingFormat = UIView

  public static func snapshotData(with renderingFormat: UIView) throws -> Data {
    let hierarchy = renderingFormat.textHierarchy
    let string = hierarchy.stringValue

    return string.data(using: .utf8)!
  }

  public static var outputInfo: SnapshotOutputInfo {
    return SnapshotOutputInfo(
      directoryName: "Hierarchies",
      fileExtension: "hierarchy.txt"
    )
  }

  public static func validate(render view: UIView, existingData: Data) throws {
    let textHierarchy = try ViewHierarchySnapshot.snapshotData(with: view)

    if textHierarchy != existingData {
      throw SnapshotValidationError.notMatching
    }
  }
}

extension UIView {
  var textHierarchy: TextHierarchy {
    let hierarchy = TextHierarchy()

    self.startingViewForTextHierarchy.appendTo(textHierarchy: hierarchy, depth: 0)

    return hierarchy
  }

  @objc var textHierarchyDescription: String {
    return
      "[\(type(of: self)): \(self.frame.origin.x), \(self.frame.origin.y), \(self.frame.width), \(self.frame.height)]"
  }

  @objc var startingViewForTextHierarchy: UIView {
    return self
  }

  private func appendTo(textHierarchy: TextHierarchy, depth: Int) {
    textHierarchy.append(.init(view: self, depth: depth))

    for subview in self.subviews {
      subview.appendTo(textHierarchy: textHierarchy, depth: depth + 1)
    }
  }

  final class TextHierarchy {
    private(set) var views: [View] = []

    func append(_ view: View) {
      self.views.append(view)
    }

    var stringValue: String {
      let rows: [String] = self.views.map {
        let space = Array(repeating: "   ", count: $0.depth).joined()
        let description = $0.view.textHierarchyDescription

        return space + description
      }

      return rows.joined(separator: "\n") + "\n"
    }

    struct View {
      let view: UIView
      let depth: Int
    }
  }
}
