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
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var smcSwitch: UISegmentedControl!
    @IBOutlet weak var tbShifts: UITableView!
    @IBOutlet weak var locMapWidth: NSLayoutConstraint!
    @IBOutlet weak var locTableWidth: NSLayoutConstraint!
    @IBOutlet weak var scContent: UIScrollView!

    var arShitfts: [Shift] = [Shift]()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locMapWidth.constant =  UIScreen.main.bounds.size.width
        self.locTableWidth.constant =  UIScreen.main.bounds.size.width
        
        self.tbShifts.dataSource = self;
        
        self.scContent.isPagingEnabled = true
        
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
                                
                                self.arShitfts.removeAll()
                                self.arShitfts.append(contentsOf: aObjectEvent.result as! [Shift])
                                self.tbShifts.reloadData()
                                
                                
                                for shift in self.arShitfts {
                                    let shiftPin = ShiftPin(title: shift.company,
                                                            locationName: shift.location,
                                                            coordinate: CLLocationCoordinate2D(latitude: shift.latitude, longitude: shift.longitude))
                                    
                                    self.mapView.addAnnotation(shiftPin)
                                }
        }
    }
    
    func searchByPostCode() {
        let alertController = UIAlertController(title: "Error", message:
            "searcy by post code not implemented", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
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
    
    @IBAction func search(_ sender: Any) {
        if (useLocation) {
            searchByLocation()
        } else {
            searchByPostCode()
        }
    }
    
    @IBAction func switchView(_ sender: Any) {
        let x = CGFloat(self.smcSwitch.selectedSegmentIndex) * self.scContent.frame.size.width
        self.scContent.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
}

extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arShitfts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ShiftTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ShiftTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ShiftTableViewCell.")
        }
        
        let shift: Shift = self.arShitfts[indexPath.row];
        
        cell.lbCompanyName.text = shift.location
        cell.lbDistance.text = shift.distance
        cell.lbAddress.text = shift.address
        cell.lbSchedule.text = shift.schedule()
        
        return cell
    }

}


