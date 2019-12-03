//
//  ViewImageSnapshot.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/26/19.
//

import UIKit


public struct ViewImageSnapshot : SnapshotOutputFormat
{
    // MARK: SnapshotOutputFormat
    
    public typealias RenderingFormat = UIView
    
    public static func snapshotData(with renderingFormat : UIView) throws -> Data
    {
        return renderingFormat.toImage.pngData()!
    }
    
    public static var outputInfo : SnapshotOutputInfo {
        return SnapshotOutputInfo(
            directoryName: "Images",
            fileExtension: "snapshot.png"
        )
    }
    
    public static func validate(render newView : UIView, existingData: Data) throws
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


extension UIImage
{
    static func compareImages(lhs : UIImage, rhs : UIImage) -> Bool
    {
        return lhs.pngData() == rhs.pngData()
    }
}
