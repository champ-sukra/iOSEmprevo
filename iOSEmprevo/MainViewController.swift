//
//  MainViewController.swift
//  iOSEmprevo
//
//  Created by Yuwei Yang on 19/8/17.
//

import UIKit
import MapKit

class MainViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var postcodeLabel: UILabel!
    @IBOutlet weak var postcodeTF: UITextField!
    
    var _useLocation = false
    var useLocation:Bool {
        set(newValue) {
            if (newValue) {
                postcodeTF.isHidden = true
                postcodeLabel.isHidden = true
                self.searchByLocation()
            } else {
                postcodeTF.isHidden = false
                postcodeLabel.isHidden = false
            }
            
            _useLocation = newValue
        }
        
        get {
            return _useLocation
        }
    }
    var regionRadius: CLLocationDistance = 10000
    let locationManager = CLLocationManager()
    let bl: ShiftBL = ShiftBL()
    
    var initialLocation = CLLocation(latitude: -37.8010, longitude: 144.897470)
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        mapView.delegate = self
        useLocation = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let alertController = UIAlertController(title: "", message: "Do you want to use your current location?", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction!) in
            self.useLocation = true
            
        }
        alertController.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action:UIAlertAction!) in
            self.useLocation = false
        }
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion:nil)
        
    }
    
    func searchByLocation() {
        centerMapOnLocation(location: initialLocation)
        
        bl.requestListOfShift("\(initialLocation.coordinate.latitude)",
            "\(initialLocation.coordinate.longitude)",
        String(format:"%.3f", regionRadius / 1000)) { (aObjectEvent: ObjectEvent) in
            print(aObjectEvent.result)
            
            let shifts: [Shift] = aObjectEvent.result as! [Shift]
            
            for shift in shifts {
                
                let shiftPin = ShiftPin(title: shift.company,
                                        locationName: shift.location,
                                        address: shift.address,
                                        coordinate: CLLocationCoordinate2D(latitude: shift.latitude, longitude: shift.longitude))
                
                self.mapView.addAnnotation(shiftPin)
            }
            
            let mePin = ShiftPin(title: "Me",
                                locationName: "",
                                address: "",
                                coordinate: self.initialLocation.coordinate)
            self.mapView.addAnnotation(mePin)
        }
    }
    
    func searchByPostCode() {
        
        
        bl.requestListOfShiftByPostcode(
            String(format:"%.3f", regionRadius / 1000), postcodeTF.text ?? "")
        { (aObjectEvent: ObjectEvent) in
            print(aObjectEvent.result)
            
            let shifts: [Shift] = aObjectEvent.result as! [Shift]
            
            for shift in shifts {
                
                let shiftPin = ShiftPin(title: shift.company,
                                        locationName: shift.location,
                                        address: shift.address,
                                        coordinate: CLLocationCoordinate2D(latitude: shift.latitude, longitude: shift.longitude))
                
                self.mapView.addAnnotation(shiftPin)
            }
            
            if shifts.count == 0 {
                DispatchQueue.main.async() {
                    let alertController = UIAlertController(title: "Error", message:
                        "No shifts data found", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                let shift1 = shifts[0]
                self.centerMapOnLocation(location: CLLocation(latitude: shift1.latitude, longitude: shift1.longitude))
            }
        }
        
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ShiftPin {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
    @IBAction func radiusSliderChanged(_ sender: UISlider) {
        self.regionRadius = CLLocationDistance(sender.value * 1000)
        centerMapOnLocation(location: initialLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location2D = manager.location!.coordinate
        initialLocation = CLLocation(latitude: location2D.latitude, longitude: location2D.longitude)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! ShiftPin
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsMapCenterKey]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
    @IBAction func search(_ sender: Any) {
        let allAnnotations = self.mapView.annotations
        mapView.removeAnnotations(allAnnotations)
        
        if (useLocation) {
            searchByLocation()
        } else {
            searchByPostCode()
        }
    }
}
