//
//  SnapshotTest.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/2/19.
//

import UIKit
import Foundation
import XCTest


struct SnapshotTest<OutputFormat:SnapshotTestOutput>
{
    var config : Config
    
    func run(
        testPath : String = #file,
        functionName : String = #function,
        line : Int = #line,
        testCase : String? = nil,
        test : (Config.Screen) throws -> OutputFormat
        ) throws
    {
        do {
            for screen in self.config.screens {
                let output = try test(screen)
                let newData = try output.toData()
                
                let outputUrl = SnapshotTest.outputUrl(
                    with: OutputFormat.self,
                    screen: screen,
                    testCase: testCase,
                    testPath: testPath,
                    functionName: functionName,
                    line: line
                )
                
                let exists = FileManager.default.fileExists(atPath: outputUrl.path)
                
                if exists {
                    let saved = try Data(contentsOf: outputUrl)
                    
                    do {
                        try OutputFormat.verify(saved: saved, new: output)
                    } catch {
                        XCTFail("Snapshots Did Not Match: \(error)")
                    }
                }
                
                try newData.write(to: outputUrl)
            }
        } catch {
            XCTFail("Snapshot Test Failed: \(error)")
        }
    }
    
    static func outputUrl(
        with output : OutputFormat.Type,
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
            .appendingPathComponent(OutputFormat.outputConfig.directoryName, isDirectory: true)
            .appendingPathComponent(functionName, isDirectory: true)
        
        if let testCase = testCase {
            snapshotsDirectory = snapshotsDirectory.appendingPathComponent(testCase)
        }
        
        try! FileManager.default.createDirectory(at: snapshotsDirectory, withIntermediateDirectories: true, attributes: [:])
        
        return snapshotsDirectory
            .appendingPathComponent(screen.name)
            .appendingPathExtension(OutputFormat.outputConfig.fileExtension)
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

struct SnapshotTestOutputConfig : Equatable
{
    var directoryName : String
    var fileExtension : String
}

protocol SnapshotTestOutput
{
    static var outputConfig : SnapshotTestOutputConfig { get }
    
    static func verify(saved : Data, new : Self) throws
    
    static func instance(with data : Data) throws -> Self
    func toData() throws -> Data
}


//
// MARK: View Hierarchy Testing
//


struct ViewHierarchyDescription : SnapshotTestOutput
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
    
    static func verify(saved: Data, new: ViewHierarchyDescription) throws
    {
        fatalError()
    }
    
    static func instance(with data: Data) throws -> ViewHierarchyDescription
    {
        fatalError()
    }
    
    func toData() throws -> Data
    {
        fatalError()
    }
}


//
// MARK: Snapshot Image Testing
//


extension UIView
{
    // TODO: Once we're inside a provided layout container view, switch back to UIGraphicsImageRenderer.
    
    var toImage : UIImage {
        UIGraphicsBeginImageContext(self.bounds.size)
        
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension UIImage : SnapshotTestOutput
{
    enum Error : Swift.Error {
        case nonMatchingImages
    }
    
    //
    // MARK: SnapshotTestOutput
    //
    
    static var outputConfig: SnapshotTestOutputConfig {
        return .init(
            directoryName: "PNGs",
            fileExtension: "snapshot.png"
        )
    }
    
    static func verify(saved: Data, new: UIImage) throws
    {
        let newData = try new.toData()
        
        if saved != newData {
            throw Error.nonMatchingImages
        }
    }
    
    static func instance(with data : Data) throws -> Self
    {
        return self.init(data: data)!
    }
    
    func toData() throws -> Data
    {
        return self.pngData()!
    }
}
