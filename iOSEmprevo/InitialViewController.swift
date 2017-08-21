//
//  InitialViewController.swift
//  iOSEmprevo
//
//  Created by Chaithat Sukra on 21/08/2017.
//  Copyright © 2017 Chaithat Sukra. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var lbLoading: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lbLoading.text = "Getting default value"
        
        let bl: InitBL = InitBL()
        bl.requestInitialValue { (aObjectEvent: ObjectEvent) in
            if aObjectEvent.isSuccessful {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                print(aObjectEvent.resultMessage)
            }
        }
    }
}
