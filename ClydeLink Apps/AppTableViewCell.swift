//
//  AppTableViewCell.swift
//  ClydeLink Apps
//
//  Created by J J Feddock on 5/14/16.
//  Copyright © 2016 XLR8 Development LLC. All rights reserved.
//

import UIKit

class AppTableViewCell: UITableViewCell {

    
    @IBOutlet weak var Title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
