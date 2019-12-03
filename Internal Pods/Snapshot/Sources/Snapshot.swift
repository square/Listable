//
//  Snapshot.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/19/19.
//

import XCTest

public struct Snapshot<Iteration:SnapshotIteration>
{    
    public typealias Test = (Iteration) throws -> Iteration.RenderingFormat
    
    public let iterations : [Iteration]
    public let test : Test
    
    internal typealias OnFail = (_ message : String, _ file : StaticString, _ line : UInt) -> ()
    internal var onFail : OnFail = XCTFail
    
    public init(iterations : [Iteration], test : @escaping Test)
    {
        let hasIterations = iterations.isEmpty == false
        precondition(hasIterations, "Must provide at least one iteration.")
        
        let allNames = iterations.map { $0.name }
        
        let allNamesUnique = Set(allNames).count == iterations.count
        precondition(allNamesUnique, "Must provide iterations with unique names.")
        
        let allNamesNonEmpty = allNames.allSatisfy { $0.isEmpty == false }
        precondition(allNamesNonEmpty, "Cannot provide an empty iteration name.")
        
        self.iterations = iterations.sorted { $0.name < $1.name }
        self.test = test
    }
    
    public func test<OutputFormat:SnapshotOutputFormat>(
        output: OutputFormat.Type,
        testCase : String? = nil,
        testFilePath : StaticString = #file,
        functionName : StaticString = #function,
        line : UInt = #line
    ) where OutputFormat.RenderingFormat == Iteration.RenderingFormat
    {
        for iteration in self.iterations {
            let url = Snapshot.outputUrl(
                output: OutputFormat.self,
                testCase: testCase,
                testFilePath: testFilePath.description,
                functionName: functionName.description,
                iteration: iteration.name
            )
                        
            do {
                let rendering = iteration.prepare(render: try self.test(iteration))
                let data = try OutputFormat.snapshotData(with: rendering)
                
                let existingData = try self.existingData(at: url)
               
                try data.write(to: url)
                
                if let existingData = existingData {
                    try OutputFormat.validate(render: rendering, existingData: existingData)
                }
            } catch {
                self.onFail("Snapshot test '\(iteration.name)' with format '\(OutputFormat.self)' failed with error: \(error).", testFilePath, line)
            }            
        }
    }
    
    func existingData(at url : URL) throws -> Data?
    {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        
        return try Data(contentsOf: url)
    }
    
    static func outputUrl<OutputFormat:SnapshotOutputFormat>(
        output: OutputFormat.Type,
        testCase : String?,
        systemVersion: String = UIDevice.current.systemVersion,
        testFilePath : String,
        functionName : String,
        iteration : String
        ) -> URL
    {
        let testFileURL = URL(fileURLWithPath: testFilePath)
        let testFileName = testFileURL.lastPathComponent
        let testDirectory = testFileURL.deletingLastPathComponent()
        
        // For:        ~/Development/Project/Tests/Tests.swift
        // We Provide: ~/Development/Project/Tests/Snapshot Results/Tests.swift/testFunctionName()/outputFormat/testCase/modifierName.extension
        
        var snapshotsDirectory = testDirectory
            .appendingPathComponent("Snapshot Results", isDirectory: true)
            .appendingPathComponent(testFileName, isDirectory: true)
            .appendingPathComponent(systemVersion, isDirectory: true)
            .appendingPathComponent(functionName, isDirectory: true)
            .appendingPathComponent(OutputFormat.outputInfo.directoryName, isDirectory: true)
        
        if let testCase = testCase {
            snapshotsDirectory = snapshotsDirectory.appendingPathComponent(testCase, isDirectory: true)
        }
        
        try! FileManager.default.createDirectory(at: snapshotsDirectory, withIntermediateDirectories: true, attributes: [:])
        
        return snapshotsDirectory
            .appendingPathComponent(iteration)
            .appendingPathExtension(OutputFormat.outputInfo.fileExtension)
    }
}


public enum SnapshotValidationError : Error
{
    case notMatching
}


public protocol SnapshotOutputFormat
{
    associatedtype RenderingFormat
    
    static func snapshotData(with renderingFormat : RenderingFormat) throws -> Data
    
    static var outputInfo : SnapshotOutputInfo { get }
    
    static func validate(render: RenderingFormat, existingData : Data) throws
}


public struct SnapshotOutputInfo : Equatable
{
    var directoryName : String
    var fileExtension : String
}


public protocol SnapshotIteration
{
    associatedtype RenderingFormat
    
    var name : String { get }
    
    func prepare(render : RenderingFormat) -> RenderingFormat
}
