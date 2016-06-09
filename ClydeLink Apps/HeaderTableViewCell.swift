//
//  HeaderTableViewCell.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 5/14/16.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {  // Controls the content that is added to the Home and Edit tables, these are the buttons that are Headers (containing the other buttons)
    
    
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var Header: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
