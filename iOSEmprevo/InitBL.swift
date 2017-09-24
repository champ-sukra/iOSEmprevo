//
//  InitBL.swift
//  iOSEmprevo
//
//  Created by Chaithat Sukra on 21/08/2017.
//  Copyright © 2017 Chaithat Sukra. All rights reserved.
//

import Foundation

class InitBL: BaseBL {
    public func requestInitialValue(aCompletion: @escaping (ObjectEvent) -> Void) {
        manager.requestGET("api/values") { (aObjectEvent: ObjectEvent) in
            guard let results = aObjectEvent.result as? [Any] else {
                aObjectEvent.isSuccessful = false
                aObjectEvent.resultMessage = "Server internal error"
                
                aCompletion(aObjectEvent)
                return
            }
            
            let result = results[0] as! [String: String];
            for key in result.keys {
                UserDefaults.standard.set(result[key], forKey: key)
            }
            aObjectEvent.isSuccessful = true
            aCompletion(aObjectEvent)
        }
    }
}
