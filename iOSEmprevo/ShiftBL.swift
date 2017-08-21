//
//  ShiftBL.swift
//  iOSEmprevo
//
//  Created by Chaithat Sukra on 14/08/2017.
//  Copyright © 2017 Chaithat Sukra. All rights reserved.
//

import Foundation

class ShiftBL: BaseBL {
    public func requestListOfShift(_ aLat: String, _ aLon: String, _ aRadius: String, aCompletion: @escaping (ObjectEvent) -> Void) {
        manager.requestPOST("api/values",
                            ["FromLat": aLat,
                             "FromLon": aLon,
                             "Radius": aRadius]) { (aObjectEvent: ObjectEvent) in
                                guard let results = aObjectEvent.result as? [Any] else {
                                    aObjectEvent.isSuccessful = false
                                    aObjectEvent.resultMessage = "Server internal error"
                                    
                                    aCompletion(aObjectEvent)
                                    return
                                }
                                
                                var shifts: [Shift] = [Shift]()
                                for shift in results {
                                    if let s = shift as? [String: Any] {
                                        shifts.append(Shift(s))
                                    }
                                }
                                aObjectEvent.result = shifts
                                aCompletion(aObjectEvent)
        }
    }
}
