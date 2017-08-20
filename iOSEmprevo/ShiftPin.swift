//
//  ShiftPin.swift
//  iOSEmprevo
//
//  Created by Yuwei Yang on 19/8/17.
//  Copyright © 2017 Chaithat Sukra. All rights reserved.
//

import Foundation
import MapKit
import Contacts
import AddressBook

class ShiftPin: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, address: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        self.address = address
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
    func mapItem() -> MKMapItem {
        
        let addressDictionary = [String(CNPostalAddressStreetKey): address]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = address
        
        return mapItem
    }

}
