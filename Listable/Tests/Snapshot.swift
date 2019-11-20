//
//  Snapshot.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/19/19.
//

import Foundation


struct Snapshot<Type:SnapshotType>
{
    var type : Type
    
    init(type : Type)
    {
        self.type = type
    }
    
    func test(
        testCase : String? = nil,
        testFilePath : String = #file,
        functionName : String = #function,
        line : Int = #line,
        test : () throws -> Type.OutputType
        ) throws
    {
        
    }
}



protocol SnapshotType
{
    associatedtype OutputType : SnapshotOutputType
    static var outputInfo : SnapshotOutputInfo { get }
    
    associatedtype Config : SnapshotOutputConfig
    var config : Config { get }
}


struct SnapshotOutputInfo : Equatable
{
    var directoryName : String
    var fileExtension : String
}


protocol SnapshotOutputType
{
    static func snapshotInstance(from : Data) throws -> Self
    static func snapshotData() throws -> Data
}

protocol SnapshotOutputConfig
{
    var iterations : [SnapshotIteration] { get }
}

struct SnapshotIteration
{
    var name : String
    
    var perform : () throws -> ()
}

private extension Snapshot
{
    static func outputUrl(
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
            .appendingPathComponent(Type.outputInfo.directoryName, isDirectory: true)
            .appendingPathComponent(functionName, isDirectory: true)
        
        if let testCase = testCase {
            snapshotsDirectory = snapshotsDirectory.appendingPathComponent(testCase)
        }
        
        try! FileManager.default.createDirectory(at: snapshotsDirectory, withIntermediateDirectories: true, attributes: [:])
        
        return snapshotsDirectory
            .appendingPathComponent(screen.name)
            .appendingPathExtension(OutputFormat.outputConfig.fileExtension)
    }
}
