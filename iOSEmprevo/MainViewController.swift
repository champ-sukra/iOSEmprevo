//
//  MainViewController.swift
//  iOSEmprevo
//
//  Created by Yuwei Yang on 19/8/17.
//

import UIKit
import MapKit

class MainViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var smcSwitch: UISegmentedControl!
    @IBOutlet weak var tbShifts: UITableView!
    @IBOutlet weak var locMapWidth: NSLayoutConstraint!
    @IBOutlet weak var locTableWidth: NSLayoutConstraint!
    @IBOutlet weak var scContent: UIScrollView!

    var arShitfts: [Shift]!
    var isSearching: Bool = false
    var regionRadius: CLLocationDistance = 10000
    let locationManager = CLLocationManager()
    let bl: ShiftBL = ShiftBL()
    
    private var isUsingLocationService: Bool = false
    fileprivate var locationCoordinate: CLLocation!
    private var notification: NSObjectProtocol?
    
    deinit {
        if let notification = notification {
            NotificationCenter.default.removeObserver(notification)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Emprevo"
        
        self.locMapWidth.constant =  UIScreen.main.bounds.size.width
        self.locTableWidth.constant =  UIScreen.main.bounds.size.width
        
        self.tbShifts.dataSource = self
        
        self.scContent.isPagingEnabled = true
        
        self.mapView.delegate = self
        
        notification = NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) {
            [unowned self] notification in
            self.presentPopupLocationService()
        }
        
        self.presentPopupLocationService()
    }
    
    private func presentPopupLocationService() {
        let alertController = UIAlertController(title: "", message: "Do you want to use your current location?", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction!) in
            self.isUsingLocationService = true
            self.startUsingLocationService()
            self.reloadInitialData()
        }
        alertController.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action:UIAlertAction!) in
            self.isUsingLocationService = false
            self.reloadInitialData()
            self.reloadLocationCoordinate(aCompletion: { (Void) in
                self.searchByLocation()
            })
        }
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion:nil)
    }
    
    private func reloadLocationCoordinate(aCompletion: @escaping (Void) -> Void) {
        let postcode = UserDefaults.standard.string(forKey: "postcode") ?? "3000"
        let address = postcode + ", Victoria, Australia"//self.postcodeTF.text ?? "3000" + ", Victoria, Australia"
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
//        self.tfRadius.text = UserDefaults.standard.string(forKey: "startRadius")
//        self.sliRadius.minimumValue = Float(UserDefaults.standard.string(forKey: "minRadius")!)!
//        self.sliRadius.maximumValue = Float(UserDefaults.standard.string(forKey: "maxRadius")!)!
//        self.sliRadius.value = Float(UserDefaults.standard.string(forKey: "startRadius")!)!
//        self.postcodeTF.text = UserDefaults.standard.string(forKey: "postcode")
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
        self.arShitfts?.removeAll()
        self.tbShifts.reloadData()
        
        let distance = UserDefaults.standard.string(forKey: "startRadius")
        
        //prepare region radius
        if let temp = distance, let distance_ = Double(temp) {
            self.regionRadius = CLLocationDistance(distance_ * 1000)
            self.centerMapOnLocation(location: self.locationCoordinate)
        }
        
        self.bl.requestListOfShift("\(self.locationCoordinate.coordinate.latitude)", "\(self.locationCoordinate.coordinate.longitude)", distance!) { (aObjectEvent: ObjectEvent) in
            self.isSearching = false
            
            if let result = aObjectEvent.result as? [Shift] {
                self.arShitfts = result
                self.tbShifts.reloadData()
                
                for shift in self.arShitfts {
                    let shiftPin = ShiftPin(title: shift.company,
                                            info: shift.location + "\n" + shift.address,
                                            coordinate: CLLocationCoordinate2D(latitude: shift.latitude, longitude: shift.longitude))
                    
                    self.mapView.addAnnotation(shiftPin)
                }
                
                let mePin = ShiftPin(title: "Me",
                                     info: "",
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let capital = view.annotation as! ShiftPin
        let placeName = capital.title
        let placeInfo = capital.info
        
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 1
        let identifier = "pin"
        
        // 2
        if annotation is ShiftPin {
            // 3
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                //4
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                
                // 5
                let btn = UIButton(type: .detailDisclosure)
                annotationView!.rightCalloutAccessoryView = btn
            } else {
                // 6
                annotationView!.annotation = annotation
            }
            
            return annotationView
        }
        
        // 7
        return nil
        
        /*
        
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
                let btn: UIButton = UIButton(type: .detailDisclosure)
                btn.addTarget(self, action: #selector(detailPressed(_:)), for: .touchUpOutside)
                view.rightCalloutAccessoryView = btn
            }
            return view
        }
        return nil*/
    }
    
    @IBAction func switchView(_ sender: Any) {
        let x = CGFloat(self.smcSwitch.selectedSegmentIndex) * self.scContent.frame.size.width
        self.scContent.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
    
    @IBAction func filterChange(_ sender: Any) {
        self.performSegue(withIdentifier: "main_filter", sender: self)
    }
    
    func detailPressed(_ aSender: UIButton) -> Void {
        //
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "main_filter" {
            if let vc: FilterViewController = segue.destination as? FilterViewController {
                vc.isUsingLocationService = self.isUsingLocationService
                vc.completion = { (aCompletion: Void) in
                    if self.isUsingLocationService == true {
                        self.reloadLocationCoordinate(aCompletion: { (Void) in
                            self.searchByLocation()
                        })
                    }
                    else {
                        self.searchByLocation()
                    }
                }
            }
        }
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location2D = manager.location!.coordinate
        self.locationCoordinate = CLLocation(latitude: location2D.latitude, longitude: location2D.longitude)

        if self.arShitfts == nil {
            self.searchByLocation()
        }

        //in case of we want to convert from coordinate to postcode -- leave it for now
//        let geocoder = CLGeocoder()
//        geocoder.reverseGeocodeLocation(self.locationCoordinate, completionHandler: {(placemarks, error) -> Void in
//            if((error) != nil) {
//                print(error?.localizedDescription ?? "Error -- geocodeAddressString")
//            }
//            if let placemark = placemarks?.first {
//                self.postcodeTF.text = placemark.postalCode
//            }
//        })
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            textField.resignFirstResponder()
            
//            let double = Float(textField.text!)
//            let less = Float("0")
//            let over = Float("100")
//            
//            if doubl.c. {
//                if let floatValue = Float(textField.text!) {
//                    self.sliRadius.setValue(floatValue, animated: true)
//                }
//            }
//            else {
//                if textField.text?.caseInsensitiveCompare("0") == ComparisonResult.orderedAscending {
//                    textField.text = "0"
//                }
//                if textField.text?.caseInsensitiveCompare("100") == ComparisonResult.orderedDescending {
//                    textField.text = "100"
//                }
//            }
            
            
            if let floatValue = Float(textField.text!) {
//                self.sliRadius.setValue(floatValue, animated: true)
            }
            
        }
        return true
    }
}

extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if (self.arShitfts != nil && self.arShitfts.count > 0) {
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

