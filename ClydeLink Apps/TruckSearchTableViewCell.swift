//
//  TruckSearchTableViewCell.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 5/19/16.
//

import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.nextResponder()
            if parentResponder is UIViewController {
                return parentResponder as! UIViewController!
            }
        }
        return nil
    }
}

class TruckSearchTableViewCell: UITableViewCell {  // Controls the content of each cell that is added to the Results Table from the Truck Search
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
    @IBOutlet weak var mobileLabel: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var truckLabel: UILabel!
    @IBOutlet weak var supervisorLabel: UILabel!
    
    @IBOutlet weak var employeePhoto: UIImageView!
    @IBOutlet weak var phoneNumber: UILabel!
    
    
    @IBAction func mobileClick(sender: AnyObject!) {
        if phoneNumber.text != "" {
            var phone = phoneNumber.text!
            if phone.characters.count == 10
            {
//                phone = "(" + phone.substringFromIndex(0,3) + ")" + phone.substring(4,3) + "-" + phone(substring(7
                
                phone = "(" + phone.substringWithRange(Range<String.Index>(phone.startIndex...phone.startIndex.advancedBy(3))) + ") " + phone.substringWithRange(Range<String.Index>(phone.startIndex.advancedBy(3)...phone.startIndex.advancedBy(6))) + "-" + phone.substringWithRange(Range<String.Index>(phone.startIndex.advancedBy(6)...phone.endIndex))
            }
            let callAlert = UIAlertController(title: "\(phone)", message:
                "", preferredStyle: UIAlertControllerStyle.Alert)
            callAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: nil))
            callAlert.addAction(UIAlertAction(title: "Call", style: UIAlertActionStyle.Default,handler: { (action: UIAlertAction!) in
                self.call(self.phoneNumber.text!)
            }))
            parentViewController!.presentViewController(callAlert, animated: true, completion: nil)
        } else {
            let errorAlert = UIAlertController(title: "Error", message:
                "Phone number not listed", preferredStyle: UIAlertControllerStyle.Alert)
            errorAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: nil))
            parentViewController!.presentViewController(errorAlert, animated: true, completion: nil)
        }
    }
    func call(number: String) {
        if let url: NSURL = NSURL(string: "tel://\(number)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(url)) {
                application.openURL(url);
            }
        }
    }
}
