//
//  SignpostLogger.swift
//  Listable
//
//  Created by Kyle Van Essen on 5/8/20.
//

import os.signpost


/// Log types available within Listable.
extension OSLog {
    static let updateContent = OSLog(
        subsystem: "com.kve.Listable",
        category: "ListView Update"
    )
    
    static let scrollView = OSLog(
        subsystem: "com.kve.Listable",
        category: "ListView ScrollView"
    )
    
    static let listInteraction = OSLog(
        subsystem: "com.kve.Listable",
        category: "ListView Interaction"
    )
}


/// An object which can be logged to `SignpostLogger`.
protocol SignpostLoggable {
    var signpostInfo : SignpostLoggingInfo { get }
}


/// The info logged to `SignpostLogger` from a `SignpostLoggable`.
struct SignpostLoggingInfo {
    var identifier : String?
    var instanceIdentifier : String?
}


///
/// Signpost logging is logging visible in Instruments.app
///
/// Listable utilizes signpost logging to instrument various parts of the
/// list update cycle: Content diffing, Collection View updating, item and header/footer
/// sizing, etc. 
///
/// Resources
/// ---------
///  WWDC: https://developer.apple.com/videos/play/wwdc2018/405/
///  Swift By Sundell: https://www.swiftbysundell.com/wwdc2018/getting-started-with-signposts/
///
struct SignpostLogger {
         
    static func log<Output>(log : OSLog, name: StaticString, for loggable : SignpostLoggable? = nil, _ output : () -> Output) -> Output
    {
        self.log(.begin, log: log, name: name, for: loggable)
        
        let output = output()
        
        self.log(.end, log: log, name: name, for: loggable)
        
        return output
    }
    
    static func log(_ type : EventType, log : OSLog, name: StaticString, for loggable : SignpostLoggable? = nil)
    {
        if #available(iOS 12.0, *) {
            if let loggable = loggable {
                os_signpost(
                    type.toSignpostType,
                    log: log,
                    name: name,
                    "%{public}s",
                    Self.debuggingIdentifier(for: loggable)
                )
            } else {
                os_signpost(
                    type.toSignpostType,
                    log: log,
                    name: name
                )
            }
        }
    }
    
    enum EventType {
        case begin
        case event
        case end
        
        @available(iOS 12.0, *)
        var toSignpostType : OSSignpostType {
            switch self {
            case .begin: return .begin
            case .event: return .event
            case .end: return .end
            }
        }
    }
    
    private static func debuggingIdentifier(for loggable : SignpostLoggable) -> String {
        
        let info = loggable.signpostInfo
        
        var components = [String]()
        
        components.append(
            String(describing: type(of: loggable))
        )
        
        if let id = info.identifier {
            components.append(id)
        }
        
        if let instanceID = info.instanceIdentifier {
            components.append("(\(instanceID))")
        }
        
        return components.joined(separator: " ")
    }
}

