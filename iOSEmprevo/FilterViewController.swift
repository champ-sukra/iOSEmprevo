//
//  FilterViewController.swift
//  iOSEmprevo
//
//  Created by Chaithat Sukra on 31/8/17.
//  Copyright © 2017 Chaithat Sukra. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {

    var completion: ((_ aCompletion: Void) -> Void)?
    public var isUsingLocationService: Bool = false
    
    fileprivate var arFilters: [String]!
    
    @IBOutlet weak var tbFilter: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Filter"
        
        self.tbFilter.dataSource = self
        self.tbFilter.delegate = self
        
        self.arFilters = (self.isUsingLocationService == true) ? ["Distance"] : ["Postcode", "Distance"]
        
        let doneButton : UIBarButtonItem = UIBarButtonItem(title: "Done",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(doneTapped(_:)))
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    func doneTapped(_ aSender: UIBarButtonItem) {
        let c_0 = self.tbFilter.cellForRow(at: IndexPath(row: 0, section: 0)) as! FilterTableViewCell

        if self.isUsingLocationService == true {
            UserDefaults.standard.set(c_0.tfPostcode.text, forKey: "startRadius")
        }
        else {
            let c_1 = self.tbFilter.cellForRow(at: IndexPath(row: 1, section: 0)) as! FilterTableViewCell
            UserDefaults.standard.set(c_0.tfPostcode.text, forKey: "postcode")
            UserDefaults.standard.set(c_1.tfPostcode.text, forKey: "startRadius")
        }
        self.navigationController?.popViewController(animated: true)        
        completion!()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filter_distance" {
            if let vc: DistanceViewController = segue.destination as? DistanceViewController {
                vc.completion = { (aCompletion: Void) in
                    self.tbFilter.reloadData()
                }
            }
        }
    }
}

extension FilterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arFilters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "filter"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FilterTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ShiftTableViewCell.")
        }
        
        cell.lbTitle.text = self.arFilters[indexPath.row]
        
        if self.isUsingLocationService {
            if indexPath.row == 0 {
                cell.accessoryType = .disclosureIndicator
                cell.tfPostcode.text = UserDefaults.standard.string(forKey: "startRadius") ?? "5"
            }
        }
        else {
            if indexPath.row == 0 {
                cell.tfPostcode.text = UserDefaults.standard.string(forKey: "postcode") ?? "3000"
            }
            if indexPath.row == 1 {
                cell.accessoryType = .disclosureIndicator
                cell.tfPostcode.text = UserDefaults.standard.string(forKey: "startRadius") ?? "5"
            }
        }
        
        return cell
    }
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "filter_distance", sender: self)
    }
}

