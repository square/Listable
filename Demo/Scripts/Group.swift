//
//  Group.swift
//  Scripts
//
//  Created by Kyle Van Essen on 12/28/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import Foundation


final class Group
{
    typealias Work = () throws -> ()
    
    private var state : State = .new
    
    private let group = DispatchGroup()
    
    private var work : [Work] = []
    private var results : [Result<Void,Error>] = []
    
    func add(_ work : @escaping Work)
    {
        self.work.append(work)
    }
    
    func run()
    {
        precondition(self.state == .new)
        precondition(self.work.isEmpty == false)
        
        self.state = .running
            
        let queue = DispatchQueue.global(qos: .default)
        
        self.work.forEach { block in
            self.group.enter()
            
            queue.async {
                do {
                    try block()
                    self.results.append(.success(()))
                } catch {
                    self.results.append(.failure(error))
                }
                
                self.group.leave()
            }
        }
        
        self.group.notify(queue: .main) {
            self.state = .complete
        }
    }
    
    func waitUntilFinished() throws
    {
        if self.state == .new {
            return
        }
        
        while self.state != .complete {
            RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.00001))
        }
    }
    
    enum State
    {
        case new
        case running
        case complete
    }
}
