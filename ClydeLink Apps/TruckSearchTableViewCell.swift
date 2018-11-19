//
//  TruckSearchTableViewCell.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 5/19/16.
//

import UIKit

extension UIView {
    @objc var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if parentResponder is UIViewController {
                return parentResponder as! UIViewController!
            }
        }
        return nil
    }
}

class TruckSearchTableViewCell: UITableViewCell {  // Controls the content of each cell that is added to the Results Table from the Truck Search
    
    
    @IBOutlet weak var ResultsStack: UIStackView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
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
    
    
    @IBAction func mobileClick(_ sender: AnyObject!) {
        if phoneNumber.text != "" {
            var phone = phoneNumber.text!
            phone = phone.replacingOccurrences(of: "[^0-9]", with: "", options: NSString.CompareOptions.regularExpression, range:nil);
            if phone.count == 10
            {
                phone = "" //Phone number in trucksearchview is not currently being used natively
            }
            let callAlert = UIAlertController(title: "\(phone)", message:
                "", preferredStyle: UIAlertControllerStyle.alert)
            callAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
            callAlert.addAction(UIAlertAction(title: "Call", style: UIAlertActionStyle.default,handler: { (action: UIAlertAction!) in
                self.call(self.phoneNumber.text!)
            }))
            parentViewController!.present(callAlert, animated: true, completion: nil)
        } else {
            let errorAlert = UIAlertController(title: "Error", message:
                "Phone number not listed", preferredStyle: UIAlertControllerStyle.alert)
            errorAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
            parentViewController!.present(errorAlert, animated: true, completion: nil)
        }
    }
    @objc func call(_ number: String) {
        if let url: URL = URL(string: "tel://\(number)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(url)) {
                application.openURL(url);
            }
        }
    }
}
