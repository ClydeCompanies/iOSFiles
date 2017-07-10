//
//  AddTableViewCell.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 6/9/16.
//

import UIKit

class AddTableViewCell: UITableViewCell {
    
    let prefs = UserDefaults.standard  // Current user preferences
    let synced = SyncNow()
    
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var Icon: UIImageView!
    
    @IBAction func addButton(_ sender: AnyObject) {
        for element in AppStore
        {
            if (Title.text! == element.title)
            {
                element.selected = true
                currentapps.append(element)
                break
            }
            
        }
        let appData = NSKeyedArchiver.archivedData(withRootObject: currentapps)
        prefs.set(appData, forKey: "userapps")
        prefs.synchronize()
        addButton.isHidden = true
        //display "Added!" text instead
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
