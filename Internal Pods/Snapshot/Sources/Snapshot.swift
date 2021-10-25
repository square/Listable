//
//  Snapshot.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/19/19.
//

import XCTest

public struct Snapshot<Iteration:SnapshotIteration>
{
    public typealias Test = (Iteration) throws -> Iteration.RenderingFormat

    public let settings : SnapshotSettings
    public let iterations : [Iteration]
    public let test : Test

    internal typealias OnFail = (_ message : String, _ file : StaticString, _ line : UInt) -> ()
    internal var onFail : OnFail = { message, file, line in XCTFail(message, file: file, line: line) }

    public init(
        for iteration: Iteration ,
        settings : SnapshotSettings = .init(),
        input : Iteration.RenderingFormat
    ) {
        self.init(for: [iteration], settings : settings) { _ in input }
    }

    public init(
        for iterations: [Iteration] ,
        settings : SnapshotSettings = .init(),
        input : Iteration.RenderingFormat
    ) {
        self.init(for: iterations, settings : settings) { _ in input }
    }

    public init(
        for iterations : [Iteration],
        settings : SnapshotSettings = .init(),
        test : @escaping Test
    ) {
        let hasIterations = iterations.isEmpty == false
        precondition(hasIterations, "Must provide at least one iteration.")

        let allNames = iterations.map { $0.name }

        let allNamesUnique = Set(allNames).count == iterations.count
        precondition(allNamesUnique, "Must provide iterations with unique names.")

        let allNamesNonEmpty = allNames.allSatisfy { $0.isEmpty == false }
        precondition(allNamesNonEmpty, "Cannot provide an empty iteration name.")

        self.iterations = iterations.sorted { $0.name < $1.name }
        self.settings = settings
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
                with: self.settings,
                output: OutputFormat.self,
                testCase: testCase,
                testFilePath: testFilePath.description,
                functionName: functionName.description,
                iteration: iteration.name
            )

            var onFailData : Data? = nil

            do {
                let rendering = iteration.prepare(render: try self.test(iteration))
                let data = try OutputFormat.snapshotData(with: rendering)
                onFailData = data

                let existingData = try self.existingData(at: url)

                if let existingData = existingData {
                    do {
                        try OutputFormat.validate(render: rendering, existingData: existingData)
                    } catch {
                        try data.write(to: url)
                        throw error
                    }
                } else {
                    try data.write(to: url)
                }
            } catch {
                let data : String = {
                    if let onFailData = onFailData {
                        return onFailData.base64EncodedString()
                    } else {
                        return "Error generating snapshotData."
                    }
                }()

                self.onFail(
                    """
                    Snapshot test '\(iteration.name)' with format '\(OutputFormat.self)' failed.

                    Error: \(error).

                    File extension: '.\(output.outputInfo.fileExtension)'.

                    Base64 Data (pass this to `Data.saveBase64(toPath: "~/Development/etc ...", content: "...")` to inspect locally):

                    '\(data)'.

                    """,
                    testFilePath, line
                )
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
        with settings : SnapshotSettings,
        output: OutputFormat.Type,
        testCase : String?,
        testFilePath : String,
        functionName : String,
        iteration : String
        ) -> URL
    {
        let testFileURL = URL(fileURLWithPath: testFilePath)
        let testFileName = testFileURL.lastPathComponent
        let testDirectory = testFileURL.deletingLastPathComponent()

        // For:        ~/Development/Project/Tests/Tests.swift
        // We Provide: ~/Development/Project/Tests/Snapshot Results/Tests.swift/OSVersion/testFunctionName()/outputFormat/testCase/modifierName.extension

        var snapshotsDirectory = testDirectory
            .appendingPathComponent("Snapshot Results", isDirectory: true)
            .appendingPathComponent(testFileName, isDirectory: true)
            .appendingPathComponent(settings.savesBySystemVersion.systemVersionDirectory(), isDirectory: true)
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


public extension Data
{
    static func saveBase64(toPath path : String, content : String) -> Bool
    {
        let url = URL(fileURLWithPath: (path as NSString).expandingTildeInPath)

        guard let data = Data(base64Encoded: content) else {
            print("Could not create data from base64 string.")
            return false
        }

        do {
            try data.write(to: url)
        } catch {
            print("Could not write data to disk. Error: \(error)")
            return false
        }

        return true
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
    public var directoryName : String
    public var fileExtension : String

    public init(
        directoryName : String,
        fileExtension : String
    ) {
        self.directoryName = directoryName
        self.fileExtension = fileExtension
    }
}


public protocol SnapshotIteration
{
    associatedtype RenderingFormat

    var name : String { get }

    func prepare(render : RenderingFormat) -> RenderingFormat
}
