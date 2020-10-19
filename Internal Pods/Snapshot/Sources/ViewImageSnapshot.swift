//
//  ViewImageSnapshot.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/26/19.
//

import UIKit


public struct ViewImageSnapshot<ViewType:UIView> : SnapshotOutputFormat
{
    // MARK: SnapshotOutputFormat
    
    public typealias RenderingFormat = ViewType
    
    public static func snapshotData(with renderingFormat : ViewType) throws -> Data
    {
        return renderingFormat.toImage.pngData()!
    }
    
    public static var outputInfo : SnapshotOutputInfo {
        return SnapshotOutputInfo(
            directoryName: "Images",
            fileExtension: "snapshot.png"
        )
    }
    
    public static func validate(render newView : ViewType, existingData: Data) throws
    {
        let existing = try ViewImageSnapshot.image(with: existingData)
        let new = newView.toImage
        
        guard existing.size == new.size else {
            throw Error.differentSizes
        }
        
        guard UIImage.compareImages(lhs: existing, rhs: new) else {
            throw Error.notMatching
        }
    }
    
    private static func image(with data : Data) throws -> UIImage
    {
        guard data.isEmpty == false else {
            throw Error.zeroSizeData
        }
        
        guard let image = UIImage(data: data) else {
            throw Error.couldNotLoadReferenceImage
        }
        
        return image
    }
    
    public enum Error : Swift.Error
    {
        case differentSizes
        case notMatching
        case zeroSizeData
        case couldNotLoadReferenceImage
    }
}


extension UIView
{    
    var toImage : UIImage {
        UIGraphicsBeginImageContext(self.bounds.size)

        self.layer.render(in: UIGraphicsGetCurrentContext()!)

        let image = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()

        return image
    }
}


/// Image diffing copied from Point Free (https://github.com/pointfreeco/swift-snapshot-testing/blob/master/Sources/SnapshotTesting/Snapshotting/UIImage.swift)
/// with some changes. Notably, we base the
extension UIImage
{
    static func compareImages(lhs : UIImage, rhs : UIImage) -> Bool
    {
        return lhs.pngData() == rhs.pngData()
    }
    
    private func compare(_ old: UIImage, _ new: UIImage, precision: Float) -> Bool {
      guard let oldCgImage = old.cgImage else { return false }
      guard let newCgImage = new.cgImage else { return false }
      guard oldCgImage.width != 0 else { return false }
      guard newCgImage.width != 0 else { return false }
      guard oldCgImage.width == newCgImage.width else { return false }
      guard oldCgImage.height != 0 else { return false }
      guard newCgImage.height != 0 else { return false }
      guard oldCgImage.height == newCgImage.height else { return false }
        
      // Values between images may differ due to padding to multiple of 64 bytes per row,
      // because of that a freshly taken view snapshot may differ from one stored as PNG.
      // At this point we're sure that size of both images is the same, so we can go with minimal `bytesPerRow` value
      // and use it to create contexts.
      let minBytesPerRow = min(oldCgImage.bytesPerRow, newCgImage.bytesPerRow)
      let byteCount = minBytesPerRow * oldCgImage.height

      var oldBytes = [UInt8](repeating: 0, count: byteCount)
      guard let oldContext = context(for: oldCgImage, bytesPerRow: minBytesPerRow, data: &oldBytes) else { return false }
      guard let oldData = oldContext.data else { return false }
      if let newContext = context(for: newCgImage, bytesPerRow: minBytesPerRow), let newData = newContext.data {
        if memcmp(oldData, newData, byteCount) == 0 { return true }
      }
      let newer = UIImage(data: new.pngData()!)!
      guard let newerCgImage = newer.cgImage else { return false }
      var newerBytes = [UInt8](repeating: 0, count: byteCount)
      guard let newerContext = context(for: newerCgImage, bytesPerRow: minBytesPerRow, data: &newerBytes) else { return false }
      guard let newerData = newerContext.data else { return false }
      if memcmp(oldData, newerData, byteCount) == 0 { return true }
      if precision >= 1 { return false }
      var differentPixelCount = 0
      let threshold = 1 - precision
      for byte in 0..<byteCount {
        if oldBytes[byte] != newerBytes[byte] { differentPixelCount += 1 }
        if Float(differentPixelCount) / Float(byteCount) > threshold { return false}
      }
      return true
    }
    
    private func context(for cgImage: CGImage, bytesPerRow: Int, data: UnsafeMutableRawPointer? = nil) -> CGContext? {
      guard
        let space = cgImage.colorSpace,
        let context = CGContext(
          data: data,
          width: cgImage.width,
          height: cgImage.height,
          bitsPerComponent: cgImage.bitsPerComponent,
          bytesPerRow: bytesPerRow,
          space: space,
          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        else { return nil }

      context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
      return context
    }
}
