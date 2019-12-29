//
//  SimCtl.swift
//  Scripts
//
//  Created by Kyle Van Essen on 12/28/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import Foundation


struct SimCtl
{
    struct List : Decodable, FromJSONStringDecodable
    {
        let devices : [String:[Device]]
        
        struct Device : Decodable
        {
            let state : String
            let isAvailable : Bool
            let name : String
            let udid : String
            let availabilityError : String?
        }
    
        func exists(name : String) throws -> SimCtl.List.Device?
        {
            for device in self.devices.values {
                for sim in device {
                    if sim.name == name {
                        return sim
                    }
                }
            }
            
            return nil
        }
        
        func exists(udid : String) throws -> SimCtl.List.Device?
        {
            for device in self.devices.values {
                for sim in device {
                    if sim.udid == udid {
                        return sim
                    }
                }
            }
            
            return nil
        }
        
        static func createIfNeeded(name : String, deviceType : String, runtime: String) throws -> SimCtl.List.Device
        {
            // TODO
        }
        
    }
    
    struct DeviceTypeIdentifier : Decodable
    {
        let stringValue : String
        
        
    }
}
