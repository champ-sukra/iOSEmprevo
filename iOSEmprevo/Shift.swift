//
//  Shift.swift
//  iOSEmprevo
//
//  Created by Chaithat Sukra on 14/08/2017.
//  Copyright © 2017 Chaithat Sukra. All rights reserved.
//

import Foundation

struct Shift {
    var company: String!
    var location: String!
    var distance: String!
    var address: String!
    var latitude: Double!
    var longitude: Double!
    var startTime: String!
    var endTime: String!
    
    /*CompanyName":"BlueCross",
     "Shift Location Name":"Riverlea",
     "Shift Address":"57 Intervale Drive Avondale Heights VIC",
     "Shift Lattitude":-37.7525,
     "Shift Longitude":144.8546,
     "Shift StartDateTime(UTC)":0.0,
     "Shift EndDateTime(UTC)":0.0}     
     */
    init(_ aData: [String : Any]) {
        if let company = aData["CompanyName"] as? String {
            self.company = company
        }
        if let location = aData["Shift Location Name"] as? String {
            self.location = location
        }
        if let address = aData["Shift Address"] as? String {
            self.address = address
        }
        if let lat = aData["Shift Lattitude"] as? Double {
            self.latitude = lat
        }
        if let lon = aData["Shift Longitude"] as? Double {
            self.longitude = lon
        }
        if let startTime = aData["Shift StartDateTime (UTC)"] as? String {
            self.startTime = startTime
        }
        if let endTime = aData["Shift EndDateTime (UTC)"] as? String {
            self.endTime = endTime
        }
        if let distance = aData["distance"] as? String {
            self.distance = distance;
        }
    }
    
    public func schedule() -> String {
        if self.startTime != nil && self.endTime != nil {
            return self.startTime + "\n" + self.endTime
        }
        return "N/A"
    }
}
