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
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}
