//
//  AddTableViewCell.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 6/9/16.
//

import UIKit

class AddTableViewCell: UITableViewCell {
    
    let prefs = NSUserDefaults.standardUserDefaults()  // Current user preferences
    var currentapps: Array = [App]()
    var appStore: Array = [App]()

    //outlet for title  called "Title"
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var addButton: UIButton!
    //outlet for button called "AddFeature"
    
    @IBAction func addButton(sender: AnyObject) {
        if let data = prefs.objectForKey("userapps") as? NSData {
            currentapps = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [App]
        }
        for element in currentapps
        {
            if (Title.text == element.title)
            {
                currentapps.removeAtIndex(currentapps.indexOf(element)!)
                element.selected = true
                currentapps.append(element)
                break
            }
            
        }
        for i in currentapps
        {
            print(i.title + ", " + String(i.selected))
        }
        let appData = NSKeyedArchiver.archivedDataWithRootObject(currentapps)
        prefs.setObject(appData, forKey: "userapps")
        prefs.synchronize()
        addButton.hidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func buildAppStore() {
        appStore = []
        
        for element in currentapps
        {
            if !element.selected
            {
                appStore.append(element)
            }
        }
        
    }
}
