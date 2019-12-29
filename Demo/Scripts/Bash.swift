//
//  Bash.swift
//  Scripts
//
//  Created by Kyle Van Essen on 12/28/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import Foundation


struct BashCommand
{
    let command : [String]
    
    init(with command : [String])
    {
        precondition(command.isEmpty == false)
        
        self.command = command
    }
    
    func run() throws -> String
    {
        let process = Process()
        let output = Pipe()
        let error = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", self.command.joined(separator: " ")]
        process.standardOutput = output
        process.standardError = error
        
        try process.run()
        
        var allData = Data()
        var allError = Data()
        
        while process.isRunning {
            // TODO: Maybe this instead? https://groups.google.com/forum/#!topic/des-moines-cocoaheads/IygQulT48VA
            allData.append(output.fileHandleForReading.readDataToEndOfFile())
            allError.append(error.fileHandleForReading.readDataToEndOfFile())
            
            usleep(10000)
        }
            
        let success = (process.terminationStatus == 0)
        
        if success {
            return String(data: allData, encoding: .utf8) ?? ""
        } else {
            throw ExitError.nonZero(process.terminationStatus)
        }
    }
    
    func async(completion : @escaping (Result<String, Error>) -> ())
    {
        DispatchQueue.global(qos: .default).async {
            completion(Result {
                try self.run()
            })
        }
    }
    
    enum ExitError : Error
    {
        case nonZero(Int32)
    }
}
