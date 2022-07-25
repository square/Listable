//
//  iOSDevice.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/26/19.
//

import UIKit

public struct iOSDeviceIteration: SnapshotIteration {
    public let device: iOSDevice

    public init(device: iOSDevice) {
        self.device = device
    }

    // MARK: SnapshotIteration

    public typealias RenderingFormat = UIView

    public var name: String {
        device.name
    }

    public func prepare(render view: UIView) -> UIView {
        let wrapper = iOSDevice.DeviceView(device: device)
        wrapper.content = view

        return wrapper
    }
}

public struct iOSDevice {
    public let name: String

    public var size: CGSize
    public var safeAreaInsets: UIEdgeInsets

    public let scale: CGFloat

    public let portraitSize: CGSize
    public let portraitSafeAreaInsets: UIEdgeInsets

    public var orientation: UIInterfaceOrientation {
        didSet {
            switch orientation {
            case .portrait:
                size = portraitSize
                safeAreaInsets = portraitSafeAreaInsets

            case .portraitUpsideDown:
                size = portraitSize
                safeAreaInsets = UIEdgeInsets(
                    top: portraitSafeAreaInsets.bottom,
                    left: portraitSafeAreaInsets.right,
                    bottom: portraitSafeAreaInsets.top,
                    right: portraitSafeAreaInsets.left
                )

            case .landscapeLeft:
                size = CGSize(
                    width: portraitSize.height,
                    height: portraitSize.width
                )

                safeAreaInsets = UIEdgeInsets(
                    top: portraitSafeAreaInsets.left,
                    left: portraitSafeAreaInsets.bottom,
                    bottom: portraitSafeAreaInsets.right,
                    right: portraitSafeAreaInsets.top
                )

            case .landscapeRight:
                size = CGSize(
                    width: portraitSize.height,
                    height: portraitSize.width
                )

                safeAreaInsets = UIEdgeInsets(
                    top: portraitSafeAreaInsets.right,
                    left: portraitSafeAreaInsets.top,
                    bottom: portraitSafeAreaInsets.left,
                    right: portraitSafeAreaInsets.bottom
                )

            case .unknown: fatalError()

            @unknown default: fatalError()
            }
        }
    }

    public func with(orientation: UIInterfaceOrientation) -> iOSDevice {
        var copy = self
        copy.orientation = orientation
        return copy
    }

    public init(name: String, scale: CGFloat, portraitSize: CGSize, portraitSafeAreaInsets: UIEdgeInsets)
    {
        orientation = .portrait

        self.name = name
        self.scale = scale

        self.portraitSize = portraitSize
        self.portraitSafeAreaInsets = portraitSafeAreaInsets

        size = self.portraitSize
        safeAreaInsets = self.portraitSafeAreaInsets
    }

    public static func devices(_ devices: [iOSDevice], with orientations: [UIInterfaceOrientation]) -> [iOSDevice]
    {
        precondition(orientations.isEmpty == false, "Must provide at least one orientation.")

        let byOrientation: [[iOSDevice]] = orientations.map { orientation in
            devices.map { device in
                device.with(orientation: orientation)
            }
        }

        return byOrientation.flatMap { $0 }
    }

    public static var allAvailable: [iOSDevice] {
        [
            iOSDevice.iPhone5,
            iOSDevice.iPhone8,
            iOSDevice.iPhone8Plus,
            iOSDevice.iPhoneX,
            iOSDevice.iPhoneXsMax,

            iOSDevice.iPad,
            iOSDevice.iPadPro_10_5,
            iOSDevice.iPadPro_12_9,
        ]
    }

    public static var important: [iOSDevice] {
        [
            iOSDevice.iPhone5,
            iOSDevice.iPhone8,
            iOSDevice.iPhoneX,

            iOSDevice.iPad,
            iOSDevice.iPadPro_12_9,
        ]
    }

    public static var iPhone5: iOSDevice {
        iOSDevice(
            name: "iPhone 5",
            scale: 2.0,
            portraitSize: CGSize(width: 320.0, height: 568.0),
            portraitSafeAreaInsets: .zero
        )
    }

    public static var iPhone8: iOSDevice {
        iOSDevice(
            name: "iPhone 8",
            scale: 2.0,
            portraitSize: CGSize(width: 375.0, height: 667.0),
            portraitSafeAreaInsets: .zero
        )
    }

    public static var iPhone8Plus: iOSDevice {
        iOSDevice(
            name: "iPhone 8 Plus",
            scale: 3.0,
            portraitSize: CGSize(width: 414.0, height: 736.0),
            portraitSafeAreaInsets: .zero
        )
    }

    public static var iPhoneX: iOSDevice {
        iOSDevice(
            name: "iPhone X",
            scale: 3.0,
            portraitSize: CGSize(width: 375.0, height: 812.0),
            portraitSafeAreaInsets: .zero // TODO: Propert safe area insets.
        )
    }

    public static var iPhoneXsMax: iOSDevice {
        iOSDevice(
            name: "iPhone Xs Max",
            scale: 3.0,
            portraitSize: CGSize(width: 414.0, height: 896.0),
            portraitSafeAreaInsets: .zero // TODO: Propert safe area insets.
        )
    }

    public static var iPad: iOSDevice {
        iOSDevice(
            name: "iPad",
            scale: 2.0,
            portraitSize: CGSize(width: 768.0, height: 1024),
            portraitSafeAreaInsets: .zero
        )
    }

    public static var iPadPro_10_5: iOSDevice {
        iOSDevice(
            name: "iPad Pro (10.5 inch)",
            scale: 2.0,
            portraitSize: CGSize(width: 834.0, height: 1112.0),
            portraitSafeAreaInsets: .zero
        )
    }

    public static var iPadPro_12_9: iOSDevice {
        iOSDevice(
            name: "iPad Pro (12.9 inch)",
            scale: 2.0,
            portraitSize: CGSize(width: 1024.0, height: 1366.0),
            portraitSafeAreaInsets: .zero // TODO: Propert safe area insets.
        )
    }
}

public extension Array where Element == iOSDevice {
    func toSnapshotIterations() -> [iOSDeviceIteration] {
        map {
            iOSDeviceIteration(device: $0)
        }
    }
}

public extension iOSDevice {
    final class DeviceView: UIView {
        public let device: iOSDevice

        public var content: UIView? {
            didSet {
                oldValue?.removeFromSuperview()

                if let content = content {
                    viewController.view.addSubview(content)
                }

                setSubviewFrames()
            }
        }

        private let viewController: ViewController

        public init(device: iOSDevice) {
            viewController = ViewController()

            self.device = device

            super.init(frame: CGRect(origin: .zero, size: device.size))

            layer.contentsScale = self.device.scale

            if #available(iOS 11, *) {
                self.viewController.additionalSafeAreaInsets = self.device.safeAreaInsets
            }

            addSubview(viewController.view)

            setSubviewFrames()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError()
        }

        override public func layoutSubviews() {
            super.layoutSubviews()

            setSubviewFrames()
        }

        override var startingViewForTextHierarchy: UIView {
            content ?? self
        }

        private func setSubviewFrames() {
            viewController.view.frame = bounds
            content?.frame = viewController.view.bounds
        }

        private final class ViewController: UIViewController {
            private final class RootViewController: UIView {}

            override func loadView() {
                view = RootViewController()
            }
        }
    }
}
