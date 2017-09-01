//
//  DistanceViewController.swift
//  iOSEmprevo
//
//  Created by Chaithat Sukra on 31/8/17.
//  Copyright © 2017 Chaithat Sukra. All rights reserved.
//

import UIKit

class DistanceViewController: UIViewController {

    var arDistaces: [String] = ["5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55", "60", "65", "70"]
    
    @IBOutlet weak var tbDistance: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Distance"
        self.tbDistance.dataSource = self
        self.tbDistance.delegate = self
        
        let doneButton : UIBarButtonItem = UIBarButtonItem(title: "Done",
                                                           style: .plain,
                                                           target: self,
                                                           action: "")
        self.navigationItem.rightBarButtonItem = doneButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension DistanceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arDistaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = self.arDistaces[indexPath.row] + " km"
        
        return cell
    }
}

extension DistanceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
}

