//
//  ShiftTableViewCell.swift
//  iOSEmprevo
//
//  Created by Chaithat Sukra on 20/08/2017.
//  Copyright © 2017 Chaithat Sukra. All rights reserved.
//

import UIKit

class ShiftTableViewCell: UITableViewCell {

    @IBOutlet weak var lbCompanyName: UILabel!
    @IBOutlet weak var lbDistance: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbSchedule: UILabel!    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
