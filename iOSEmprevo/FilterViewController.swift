//
//  FilterViewController.swift
//  iOSEmprevo
//
//  Created by Chaithat Sukra on 31/8/17.
//  Copyright © 2017 Chaithat Sukra. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {

    @IBOutlet weak var tbFilter: UITableView!
    var arFilters: [String] = ["Postcode", "Distance"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Filter"
        
        self.tbFilter.dataSource = self
        self.tbFilter.delegate = self
        
        let doneButton : UIBarButtonItem = UIBarButtonItem(title: "Done",
                                                           style: .plain,
                                                           target: self,
                                                           action: "")
        self.navigationItem.rightBarButtonItem = doneButton
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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
        
//        let shift: Shift = self.arShitfts[indexPath.row];
        
        cell.lbTitle.text = self.arFilters[indexPath.row]
        if indexPath.row == 1 {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "filter_distance", sender: self)
    }
}

