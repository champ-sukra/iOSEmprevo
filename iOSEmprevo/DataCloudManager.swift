//
//  DataCloudManager.swift
//  COSC2471
//
//  Created by Chaithat Sukra on 3/08/2017.
//  Copyright © 2017 Chaithat Sukra. All rights reserved.
//

import Foundation

class DataCloudManager {
    
    var dStore: Dictionary = [String: String]()
    
    class var sharedInstance: DataCloudManager {
        struct Singleton {
            static let instance = DataCloudManager()
        }
        return Singleton.instance
    }
    
    public func setValueForKey(_ aValue: String, _ aKey: String) {
        self.dStore[aKey] = aValue
    }
    
    public func getValueForKey(_ aKey: String) -> String {
        if let value = self.dStore[aKey] {
            return value
        }
        return ""
    }
}
