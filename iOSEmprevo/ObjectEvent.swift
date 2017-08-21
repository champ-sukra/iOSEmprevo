//
//  ObjectEvent.swift
//  COSC2471
//
//  Created by Chaithat Sukra on 31/07/2017.
//  Copyright © 2017 Chaithat Sukra. All rights reserved.
//

import Foundation

class ObjectEvent: NSObject {
    var isSuccessful: Bool = false
    var status: Int!
    var resultMessage: String!
    var result: Any!
    
    public func message() -> Any? {
        guard let results = self.result as? [Any] else {
            return nil
        }
        
        return results
    }
}
