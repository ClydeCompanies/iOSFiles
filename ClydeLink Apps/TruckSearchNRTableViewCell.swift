//
//  TruckSearchTableViewCell.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 5/19/16.
//

import UIKit

class TruckSearchNRTableViewCell: UITableViewCell {  // Controls the content of each cell that is added to the Results Table from the Truck Search

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var errorLabel: UILabel!
    

}
