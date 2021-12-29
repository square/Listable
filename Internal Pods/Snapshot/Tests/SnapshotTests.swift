//
//  SnapshotTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/26/19.
//

import XCTest

@testable import Snapshot


class SnapshotTests : XCTestCase
{
    fileprivate func newSnapshot(with test : @escaping Snapshot<TestIteration>.Test) -> Snapshot<TestIteration>
    {
        return Snapshot(for: [TestIteration(name: "Test")], test: test)
    }
    
    func test_use_this_to_write_out_data()
    {
        let path = ""
        
        let string = ""
        
        if path.isEmpty || string.isEmpty {
            return
        }
        
        _ = Data.saveBase64(toPath: path, content: string)
    }
    
    func test_no_asset_writes_and_passes()
    {
        var snapshot = self.newSnapshot(with: { _ in
            return "Result"
        })
        
        snapshot.onFail = { _, _, _ in
            XCTFail("Should not fail when there is no reference snapshot.")
        }
        
        let url = Snapshot<TestIteration>.outputUrl(
            with: .init(),
            output: TestOutputFormat.self,
            testCase: nil,
            testFilePath: #file,
            functionName: #function,
            iteration: snapshot.iterations[0].name
        )
        
        try? FileManager.default.removeItem(at: url)
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
        
        snapshot.test(output: TestOutputFormat.self)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        
        XCTAssertEqual(try! String(contentsOf: url), "Result")
    }
    
    func test_identical_asset_passes()
    {
        var snapshot = self.newSnapshot(with: { _ in
            return "Result"
        })
        
        snapshot.onFail = { _, _, _ in
            XCTFail("Should not fail when there is an identical reference snapshot.")
        }
        
        let url = Snapshot<TestIteration>.outputUrl(
            with: .init(),
            output: TestOutputFormat.self,
            testCase: nil,
            testFilePath: #file,
            functionName: #function,
            iteration: snapshot.iterations[0].name
        )
        
        try! "Result".write(to: url, atomically: true, encoding: .utf8)
                
        snapshot.test(output: TestOutputFormat.self)
    }
    
    func test_different_asset_fails()
    {
        var snapshot = self.newSnapshot(with: { _ in
            return "New"
        })
        
        var calledOnFail = false
        
        snapshot.onFail = { _, _, _ in
            calledOnFail = true
        }
        
        let url = Snapshot<TestIteration>.outputUrl(
            with: .init(),
            output: TestOutputFormat.self,
            testCase: nil,
            testFilePath: #file,
            functionName: #function,
            iteration: snapshot.iterations[0].name
        )
        
        try! "Old".write(to: url, atomically: true, encoding: .utf8)
                
        snapshot.test(output: TestOutputFormat.self)
        
        XCTAssertEqual(calledOnFail, true)
    }
    
    func test_image_and_text_output()
    {
        let iterations = [
            SizedViewIteration(name: "200x200", size: CGSize(width: 200.0, height: 200.0)),
            SizedViewIteration(name: "300x300", size: CGSize(width: 300.0, height: 300.0)),
        ]
        
        let snapshot = Snapshot(for: iterations) { iteration in
            let root = ViewType1(frame: .init(origin: .zero, size: .init(width: 150.0, height: 150.0)))
            root.backgroundColor = .init(white: 0.8, alpha: 1.0)

            for _ in 1...3 {
                let view = ViewType2(frame: .init(origin: .init(x: 10.0, y: 10.0), size: .init(width: 50.0, height: 50.0)))
                view.backgroundColor = .init(white: 1.0, alpha: 1.0)

                let view2 = ViewType3(frame: .init(origin: .init(x: 15.0, y: 15.0), size: .init(width: 30.0, height: 30.0)))
                view2.backgroundColor = .init(white: 0.7, alpha: 1.0)

                view.addSubview(view2)
                root.addSubview(view)
            }

            return root
        }

        snapshot.test(output: ViewHierarchySnapshot.self)
        snapshot.test(output: ViewImageSnapshot.self)
    }
}


fileprivate struct TestOutputFormat : SnapshotOutputFormat
{
    // MARK: SnapshotOutputFormat
    
    typealias RenderingFormat = String
    
    static func snapshotData(with renderingFormat: String) throws -> Data
    {
        return renderingFormat.data(using: .utf8)!
    }
    
    static var outputInfo: SnapshotOutputInfo {
        return SnapshotOutputInfo(directoryName: "TestOutput", fileExtension: "test.txt")
    }
    
    static func validate(render: String, existingData : Data) throws
    {
        let data = try TestOutputFormat.snapshotData(with: render)
        
        if data != existingData {
            throw SnapshotValidationError.notMatching
        }
    }
}


fileprivate struct TestIteration : SnapshotIteration
{
    // MARK: SnapshotIteration
    
    typealias RenderingFormat = String

    var name : String
    
    func prepare(render: String) -> String
    {
        return render
    }
}


fileprivate final class ViewType1 : UIView {}
fileprivate final class ViewType2 : UIView {}
fileprivate final class ViewType3 : UIView {}

