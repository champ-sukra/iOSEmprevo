//
//  ShiftPin.swift
//  iOSEmprevo
//
//  Created by Yuwei Yang on 19/8/17.
//  Copyright © 2017 Chaithat Sukra. All rights reserved.
//

import Foundation
import MapKit

class ShiftPin: NSObject, MKAnnotation {
    let title: String?
    let info: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, info: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.info = info
        self.coordinate = coordinate
        
        super.init()
    }
}
