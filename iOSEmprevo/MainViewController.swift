//
//  MainViewController.swift
//  iOSEmprevo
//
//  Created by Yuwei Yang on 19/8/17.
//

import UIKit
import MapKit

class MainViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var swLS: UISwitch!
    @IBOutlet weak var tfRadius: UITextField!
    @IBOutlet weak var sliRadius: UISlider!
    @IBOutlet weak var postcodeTF: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var smcSwitch: UISegmentedControl!
    @IBOutlet weak var tbShifts: UITableView!
    @IBOutlet weak var locMapWidth: NSLayoutConstraint!
    @IBOutlet weak var locTableWidth: NSLayoutConstraint!
    @IBOutlet weak var scContent: UIScrollView!

    var arShitfts: [Shift] = [Shift]()
    var isSearching: Bool = false
    var regionRadius: CLLocationDistance = 10000
    let locationManager = CLLocationManager()
    let bl: ShiftBL = ShiftBL()
    
    var locationCoordinate: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locMapWidth.constant =  UIScreen.main.bounds.size.width
        self.locTableWidth.constant =  UIScreen.main.bounds.size.width
        
        self.tbShifts.dataSource = self;
        self.scContent.isPagingEnabled = true
        
        self.mapView.delegate = self
        
        self.postcodeTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let alertController = UIAlertController(title: "", message: "Do you want to use your current location?", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction!) in
            self.swLS.setOn(true, animated: true)
            self.startUsingLocationService()
            self.reloadInitialData()
        }
        alertController.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action:UIAlertAction!) in
            self.swLS.setOn(false, animated: true)
            self.reloadInitialData()
            self.reloadLocationCoordinate(aCompletion: { (Void) in
                self.searchByLocation()
            })
        }
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion:nil)
    }
    
    private func reloadLocationCoordinate(aCompletion: @escaping (Void) -> Void) {
        let address = self.postcodeTF.text ?? "3000" + ", Victoria, Australia"
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print(error?.localizedDescription ?? "Error -- geocodeAddressString")
            }
            if let placemark = placemarks?.first {
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                
                self.locationCoordinate = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                aCompletion()
            }
        })
    }
    
    private func reloadInitialData() {
        self.tfRadius.text = UserDefaults.standard.string(forKey: "startRadius")
        self.sliRadius.minimumValue = Float(UserDefaults.standard.string(forKey: "minRadius")!)!
        self.sliRadius.maximumValue = Float(UserDefaults.standard.string(forKey: "maxRadius")!)!
        self.sliRadius.value = Float(UserDefaults.standard.string(forKey: "startRadius")!)!
        self.postcodeTF.text = UserDefaults.standard.string(forKey: "postcode")
    }
    
    private func startUsingLocationService() {
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            locationManager.startUpdatingLocation()
        }
    }
    
    func searchByLocation() {
        self.isSearching = true
        self.tfRadius.resignFirstResponder()
        self.postcodeTF.resignFirstResponder()
        self.arShitfts.removeAll()
        self.tbShifts.reloadData()
        
        self.reloadLocationCoordinate { (Void) in
            self.centerMapOnLocation(location: self.locationCoordinate)
            
            self.bl.requestListOfShift("\(self.locationCoordinate.coordinate.latitude)",
            "\(self.locationCoordinate.coordinate.longitude)", self.tfRadius.text ?? "3000") { (aObjectEvent: ObjectEvent) in
                self.isSearching = false
                
                self.arShitfts.append(contentsOf: aObjectEvent.result as! [Shift])
                self.tbShifts.reloadData()
                
                
                for shift in self.arShitfts {
                    let shiftPin = ShiftPin(title: shift.company,
                                            locationName: shift.location,
                                            coordinate: CLLocationCoordinate2D(latitude: shift.latitude, longitude: shift.longitude))
                    
                    self.mapView.addAnnotation(shiftPin)
                }
                
                let mePin = ShiftPin(title: "Me",
                                     locationName: "",
                                     coordinate: self.locationCoordinate.coordinate)
                self.mapView.addAnnotation(mePin)
            }
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func textFieldDidChange(textField: UITextField) {
        self.swLS.setOn(false, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ShiftPin {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            }
            else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
    @IBAction func switchLocationService(_ sender: Any) {
        if (self.swLS.isOn) {
            self.startUsingLocationService()
        }
        else {
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    @IBAction func radiusSliderChanged(_ sender: UISlider) {
        self.tfRadius.text = String(format:"%.2f", sender.value)
        self.regionRadius = CLLocationDistance(sender.value * 1000)
    }
    
    @IBAction func search(_ sender: Any) {
        self.searchByLocation()
    }
    
    @IBAction func switchView(_ sender: Any) {
        let x = CGFloat(self.smcSwitch.selectedSegmentIndex) * self.scContent.frame.size.width
        self.scContent.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location2D = manager.location!.coordinate
        self.locationCoordinate = CLLocation(latitude: location2D.latitude, longitude: location2D.longitude)

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(self.locationCoordinate, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print(error?.localizedDescription ?? "Error -- geocodeAddressString")
            }
            if let placemark = placemarks?.first {
                self.postcodeTF.text = placemark.postalCode
            }
        })
    }
}

extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if (self.arShitfts.count > 0) {
            self.tbShifts.separatorStyle = .singleLine
            return 1
        }
        else {
            let rect = CGRect(x: 0, y: 0, width: self.tbShifts.bounds.size.width, height: self.tbShifts.bounds.size.height)
            let msgLabel = UILabel(frame: rect)
            msgLabel.text = (self.isSearching == true) ? "Loading" : "No shift available. Please change your filters"
            msgLabel.textColor = UIColor.black
            msgLabel.numberOfLines = 0;
            msgLabel.textAlignment = .center
            msgLabel.font = UIFont(name: "TrebuchetMS", size: 15)
            msgLabel.sizeToFit()
            
            self.tbShifts.backgroundView = msgLabel;
            self.tbShifts.separatorStyle = .none;
        }
        return 0;
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
