//
//  TruckSearchTableViewCell.swift
//  ClydeLink Apps
//
//  Created by J J Feddock on 5/19/16.
//  Copyright © 2016 XLR8 Development LLC. All rights reserved.
//

import UIKit

class TruckSearchTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var truckLabel: UILabel!
    @IBOutlet weak var supervisorLabel: UILabel!
    

}
