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
            guard let results = aObjectEvent.result as? [String: String] else {
                aObjectEvent.isSuccessful = false
                aObjectEvent.resultMessage = "Server internal error"
                
                aCompletion(aObjectEvent)
                return
            }
            
            for key in results.keys {
                UserDefaults.standard.set(results[key], forKey: key)
            }
            aObjectEvent.isSuccessful = true
            aCompletion(aObjectEvent)
        }
    }
}
