//
//  SnapshotTest.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/2/19.
//

import UIKit
import Foundation
import XCTest


struct SnapshotTest
{
    var config : Config
    
    func stress(_ times : Int, _ block : (Int) throws -> ()) rethrows
    {
        for iteration in 1...times {
            try block(iteration)
        }
    }
    
    func run<Output:SnapshotTestOutput>(
        testPath : String = #file,
        functionName : String = #function,
        line : Int = #line,
        testCase : String? = nil,
        test : (Config.Screen) throws -> Output
    ) throws
    {
        do {
            for screen in self.config.screens {
                let output = try test(screen)
                let newData = try output.toData()
                
                let outputUrl = SnapshotTest.outputUrl(with: Output.self, screen: screen, testCase: testCase, testPath: testPath, functionName: functionName, line: line)
                
                let exists = FileManager.default.fileExists(atPath: outputUrl.path)
                
                if exists {
                    let saved = try Output.instance(with: try Data(contentsOf: outputUrl))
                                
                    try Output.verify(saved: saved, new: output)
                }
                
                try newData.write(to: outputUrl)
            }
        } catch {
            XCTFail("Snapshot Test Failed: \(error)")
        }
    }
    
    static func outputUrl<Output:SnapshotTestOutput>(
        with output : Output.Type,
        screen : Config.Screen,
        testCase : String? = nil,
        testPath : String = #file,
        functionName : String = #function,
        line : Int = #line
    ) -> URL
    {
        let testURL = URL(fileURLWithPath: testPath)
        let testFileName = testURL.lastPathComponent
        let testDirectory = testURL.deletingLastPathComponent()
        
        // For:        ~/Desktop/Development/Project/Tests/Tests.swift
        // We Provide: ~/Desktop/Development/Project/Tests/Snapshot Results/{Tests.swift}/{PNGs}/{test_Name()}/{Test Case}/{screen.name}.png
        
        var snapshotsDirectory = testDirectory
            .appendingPathComponent("Snapshot Results", isDirectory: true)
            .appendingPathComponent(testFileName, isDirectory: true)
            .appendingPathComponent(Output.outputConfig.directoryName, isDirectory: true)
            .appendingPathComponent(functionName, isDirectory: true)
        
        if let testCase = testCase {
            snapshotsDirectory = snapshotsDirectory.appendingPathComponent(testCase)
        }
        
        try! FileManager.default.createDirectory(at: snapshotsDirectory, withIntermediateDirectories: true, attributes: [:])
        
        let assetURL = snapshotsDirectory.appendingPathComponent(screen.name).appendingPathExtension(Output.outputConfig.fileExtension)
        
        return assetURL
    }
    
    struct Config : Equatable
    {
        var screens : [Screen]
        
        struct Screen : Equatable
        {
            var name : String
            var size : CGSize
            var safeArea : UIEdgeInsets
            
            static var defaultScreens : [Screen] {
                return [
                    self.iPhone5,
                    self.iPhone8,
                    self.iPhone8Plus,
                    self.iPhoneX,
                    self.iPhoneXsMax
                ]
            }
            
            static var iPhone5 : Screen {
                return Screen(
                    name : "iPhone 5",
                    size: .init(width: 0.0, height: 0.0),
                    safeArea: .init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
                )
            }
            
            static var iPhone8 : Screen {
                return Screen(
                    name : "iPhone 8",
                    size: .init(width: 0.0, height: 0.0),
                    safeArea: .init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
                )
            }
            
            static var iPhone8Plus : Screen {
                return Screen(
                    name : "iPhone 8 Plus",
                    size: .init(width: 0.0, height: 0.0),
                    safeArea: .init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
                )
            }
            
            static var iPhoneX : Screen {
                return Screen(
                    name : "iPhone X",
                    size: .init(width: 0.0, height: 0.0),
                    safeArea: .init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
                )
            }
            
            static var iPhoneXsMax : Screen {
                return Screen(
                    name : "iPhone Xs Max",
                    size: .init(width: 0.0, height: 0.0),
                    safeArea: .init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
                )
            }
        }
    }
}

struct SnapshotFormat<Config:SnapshotTestConfig, Input:SnapshotTestInput, Output:SnapshotTestOutput>
{
    var config : Config
    
    var createContainer : () throws -> Input.Container
    
    var testBody : (Input.Container) throws -> ()
    
    var convert : (Input.Container) throws -> Output
}

protocol SnapshotTestConfig
{
    
}

protocol SnapshotTestInput
{
    associatedtype Container
}


struct SnapshotTestOutputConfig : Equatable
{
    var directoryName : String
    var fileExtension : String
}

protocol SnapshotTestOutput
{
    static var outputConfig : SnapshotTestOutputConfig { get }
    
    static func verify(saved : Self, new : Self) throws
    
    static func instance(with data : Data) throws -> Self
    func toData() throws -> Data
}

struct HierarchyDescription : SnapshotTestOutput
{
    let view : UIView
    
    //
    // MARK: SnapshotTestOutput
    //
    
    static var outputConfig: SnapshotTestOutputConfig {
        return .init(
            directoryName: "Hierarchy Description",
            fileExtension: "txt"
        )
    }
    
    static func verify(saved: HierarchyDescription, new: HierarchyDescription) throws
    {
        fatalError()
    }
    
    static func instance(with data: Data) throws -> HierarchyDescription
    {
        fatalError()
    }
    
    func toData() throws -> Data
    {
        fatalError()
    }
}

extension UIView
{
    var toImage : UIImage {
        if #available(iOS 10.0, *) {
            let format = UIGraphicsImageRendererFormat()
            format.opaque = true
            format.scale = 2.0
            
            let renderer = UIGraphicsImageRenderer(size: self.bounds.size, format: format)

            return renderer.image { context in
                self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
            }
        } else {
            fatalError()
        }
    }
}

extension UIImage : SnapshotTestOutput
{
    //
    // MARK: SnapshotTestOutput
    //
    
    static var outputConfig: SnapshotTestOutputConfig {
        return .init(
            directoryName: "PNGs",
            fileExtension: "snapshot.png"
        )
    }
    
    static func verify(saved: UIImage, new: UIImage) throws
    {
        if saved != new {
            // TODO
        }
    }
    
    static func instance(with data : Data) throws -> Self
    {
        return UIImage(data: data)! as! Self
    }
    
    func toData() throws -> Data
    {
        return self.pngData()!
    }
}

