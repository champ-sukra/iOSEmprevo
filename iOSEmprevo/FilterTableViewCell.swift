//
//  FilterTableViewCell.swift
//  iOSEmprevo
//
//  Created by Chaithat Sukra on 31/8/17.
//  Copyright © 2017 Chaithat Sukra. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {

    @IBOutlet weak var tfPostcode: UITextField!
    @IBOutlet weak var lbTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
