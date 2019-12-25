//
//  iOSDevice.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/26/19.
//

import UIKit


public struct iOSDeviceIteration : SnapshotIteration
{
    public let hostingView : UIView
    public let device : iOSDevice
    
    public init(with hostingView : UIView, device : iOSDevice)
    {
        self.hostingView = hostingView
        self.device = device
    }
    
    // MARK: SnapshotIteration
    
    public typealias RenderingFormat = UIView
    
    public var name : String {
        return self.device.name
    }
    
    public func prepare(render view : UIView) -> UIView
    {
        let wrapper = iOSDevice.DeviceView(device: self.device)
        wrapper.content = view
        
        self.hostingView.addSubview(wrapper)
        
        return wrapper
    }
    
    public func tearDown(render : UIView)
    {
        // TODO: Temporary... Remove.
        self.hostingView.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
}

public struct iOSDevice
{
    public let name : String
    
    public var size : CGSize
    public var safeAreaInsets : UIEdgeInsets
    
    public let scale : CGFloat
    
    public let portraitSize : CGSize
    public let portraitSafeAreaInsets : UIEdgeInsets
    
    public var availableOnCurrentSystemVersion : Bool {
        if self.safeAreaInsets == .zero {
            return true
        } else {
            if #available(iOS 11.0, *) {
                return true
            } else {
                return false
            }
        }
    }
    
    public var orientation : UIInterfaceOrientation {
        didSet {
            switch self.orientation {
            case .portrait:
                self.size = self.portraitSize
                self.safeAreaInsets = self.self.portraitSafeAreaInsets
                
            case .portraitUpsideDown:
                self.size = self.portraitSize
                self.safeAreaInsets = UIEdgeInsets(
                    top: self.portraitSafeAreaInsets.bottom,
                    left: self.portraitSafeAreaInsets.right,
                    bottom: self.portraitSafeAreaInsets.top,
                    right: self.portraitSafeAreaInsets.left
                )
                
            case .landscapeLeft:
                self.size = CGSize(
                    width: self.portraitSize.height,
                    height: self.portraitSize.width
                )
                
                self.safeAreaInsets = UIEdgeInsets(
                    top: self.portraitSafeAreaInsets.left,
                    left: self.portraitSafeAreaInsets.bottom,
                    bottom: self.portraitSafeAreaInsets.right,
                    right: self.portraitSafeAreaInsets.top
                )
                
            case .landscapeRight:
                self.size = CGSize(
                    width: self.portraitSize.height,
                    height: self.portraitSize.width
                )
                
                self.safeAreaInsets = UIEdgeInsets(
                    top: self.portraitSafeAreaInsets.right,
                    left: self.portraitSafeAreaInsets.top,
                    bottom: self.portraitSafeAreaInsets.left,
                    right: self.portraitSafeAreaInsets.bottom
                )
                
            case .unknown: fatalError()
                
            @unknown default: fatalError()
            }
        }
    }
    
    public func with(orientation : UIInterfaceOrientation) -> iOSDevice
    {
        var copy = self
        copy.orientation = orientation
        return copy
    }
    
    public init(name : String, scale: CGFloat, portraitSize : CGSize, portraitSafeAreaInsets : UIEdgeInsets)
    {
        self.orientation = .portrait
        
        self.name = name
        self.scale = scale
        
        self.portraitSize = portraitSize
        self.portraitSafeAreaInsets = portraitSafeAreaInsets
        
        self.size = self.portraitSize
        self.safeAreaInsets = self.portraitSafeAreaInsets
    }
    
    public static func devices(_ devices : [iOSDevice], with orientations : [UIInterfaceOrientation]) -> [iOSDevice]
    {
        precondition(orientations.isEmpty == false, "Must provide at least one orientation.")
        
        let byOrientation : [[iOSDevice]] = orientations.map { orientation in
            return devices.map { device in
                device.with(orientation: orientation)
            }
        }
        
        return byOrientation.flatMap { $0 }
    }
    
    public static var allAvailable : [iOSDevice]
    {
        return [
            iOSDevice.iPhone5,
            iOSDevice.iPhone8,
            iOSDevice.iPhone8Plus,
            iOSDevice.iPhoneX,
            iOSDevice.iPhoneXsMax,
            
            iOSDevice.iPad,
            iOSDevice.iPadPro_10_5,
            iOSDevice.iPadPro_12_9,
            ].availableOnCurrentSystemVersion()
    }
    
    public static var important : [iOSDevice]
    {
        return [
            iOSDevice.iPhone5,
            iOSDevice.iPhone8,
            iOSDevice.iPhoneX,
            
            iOSDevice.iPad,
            iOSDevice.iPadPro_12_9,
            ].availableOnCurrentSystemVersion()
    }
    
    public static var iPhone5 : iOSDevice {
        return iOSDevice(
            name: "iPhone 5",
            scale: 2.0,
            portraitSize: CGSize(width: 320.0, height: 568.0),
            portraitSafeAreaInsets: .zero
        )
    }
    
    public static var iPhone8 : iOSDevice {
        return iOSDevice(
            name: "iPhone 8",
            scale: 2.0,
            portraitSize: CGSize(width: 375.0, height: 667.0),
            portraitSafeAreaInsets: .zero
        )
    }
    
    public static var iPhone8Plus : iOSDevice {
        return iOSDevice(
            name: "iPhone 8 Plus",
            scale: 3.0,
            portraitSize: CGSize(width: 414.0, height: 736.0),
            portraitSafeAreaInsets: .zero
        )
    }
    
    public static var iPhoneX : iOSDevice {
        return iOSDevice(
            name: "iPhone X",
            scale: 3.0,
            portraitSize: CGSize(width: 375.0, height: 812.0),
            portraitSafeAreaInsets: .zero // TODO: Proper safe area insets.
        )
    }
    
    public static var iPhoneXsMax : iOSDevice {
        return iOSDevice(
            name: "iPhone Xs Max",
            scale: 3.0,
            portraitSize: CGSize(width: 414.0, height: 896.0),
            portraitSafeAreaInsets: .zero //UIEdgeInsets(top: 44.0, left: 0.0, bottom: 34.0, right: 0.0)
        )
    }
    
    public static var iPad : iOSDevice {
        return iOSDevice(
            name: "iPad",
            scale: 2.0,
            portraitSize: CGSize(width: 768.0, height: 1024),
            portraitSafeAreaInsets: .zero
        )
    }
    
    public static var iPadPro_10_5 : iOSDevice {
        return iOSDevice(
            name: "iPad Pro (10.5 inch)",
            scale: 2.0,
            portraitSize: CGSize(width: 834.0, height: 1112.0),
            portraitSafeAreaInsets: .zero
        )
    }
    
    public static var iPadPro_12_9 : iOSDevice {
        return iOSDevice(
            name: "iPad Pro (12.9 inch)",
            scale: 2.0,
            portraitSize: CGSize(width: 1024.0, height: 1366.0),
            portraitSafeAreaInsets: .zero // TODO: Proper safe area insets.
        )
    }
}

public extension Array where Element == iOSDevice
{
    func toSnapshotIterations(with hostingView : UIView) -> [iOSDeviceIteration]
    {
        return self.map {
            iOSDeviceIteration(with: hostingView, device: $0)
        }
    }
    
    func availableOnCurrentSystemVersion() -> [iOSDevice]
    {
        return self.filter { $0.availableOnCurrentSystemVersion }
    }
}

public extension iOSDevice
{
    final class DeviceView : UIView
    {
        public let device : iOSDevice
        
        public var content : UIView? {
            didSet {
                guard oldValue !== self.content else {
                    return
                }
                
                oldValue?.removeFromSuperview()
                
                if let content = self.content {
                    content.removeFromSuperview()
                    self.addSubview(content)
                }
                
                self.setSubviewFrames()
            }
        }
                
        public init(device : iOSDevice)
        {
            self.device = device
            
            super.init(frame: CGRect(origin: .zero, size: device.size))
            
            self.layer.contentsScale = self.device.scale
            
            self.setSubviewFrames()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError()
        }
        
        public override func layoutSubviews()
        {
            super.layoutSubviews()
            
            self.setSubviewFrames()
        }
        
        override var startingViewForTextHierarchy : UIView {
            return self.content ?? self
        }
        
        private func setSubviewFrames()
        {
            self.content?.frame = self.bounds
        }
        
        private final class ViewController : UIViewController
        {
            private final class RootViewController : UIView {}
            
            override func loadView()
            {
                self.view = RootViewController()
            }
        }
    }
}
