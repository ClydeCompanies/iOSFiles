//
//  TruckSearchTableViewCell.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 5/19/16.
//

import UIKit

class TruckSearchTableViewCell: UITableViewCell {  // Controls the content of each cell that is added to the Results Table from the Truck Search

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mobileLabel.textAlignment = NSTextAlignment.Left
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet weak var companyTitle: UILabel!
    @IBOutlet weak var nameTitle: UILabel!
    @IBOutlet weak var mobileTitle: UILabel!
    @IBOutlet weak var titleTitle: UILabel!
    @IBOutlet weak var truckTitle: UILabel!
    @IBOutlet weak var supervisorTitle: UILabel!
    
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mobileLabel: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var truckLabel: UILabel!
    @IBOutlet weak var supervisorLabel: UILabel!
    
    @IBOutlet weak var employeePhoto: UIImageView!

}
