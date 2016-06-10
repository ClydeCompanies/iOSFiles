//
//  AppTableViewCell.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 5/14/16.
//

import UIKit

class AppTableViewCell: UITableViewCell {  // Controls the content that is added to the Home and Edit tables, these are the inferior buttons, those which actually have functions and direct to other screens/functionalities

    
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
