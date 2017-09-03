//
//  DistanceViewController.swift
//  iOSEmprevo
//
//  Created by Chaithat Sukra on 31/8/17.
//  Copyright © 2017 Chaithat Sukra. All rights reserved.
//

import UIKit

class DistanceViewController: UIViewController {

    var arDistaces: [String] = []
    var completion: ((_ aCompletion: Void) -> Void)?
    
    @IBOutlet weak var tbDistance: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Distance"
        
        let maxDistance = UserDefaults.standard.string(forKey: "maxRadius")
        let iMax = Int(maxDistance!)
        
        var iStart = 0
        while (iStart <= iMax!) {
            iStart += 1
            
            if iStart % 5 == 0 {
                self.arDistaces.append("\(iStart)")
            }
        }
        
        self.tbDistance.dataSource = self
        self.tbDistance.delegate = self
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
        UserDefaults.standard.set(self.arDistaces[indexPath.row], forKey: "startRadius")
        self.navigationController?.popViewController(animated: true)
        completion!()
    }
}

