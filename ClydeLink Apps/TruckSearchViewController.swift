//
//  TruckSearchViewController.swift
//  ClydeLink Apps
//
//  Created by J J Feddock on 5/12/16.
//  Copyright © 2016 XLR8 Development LLC. All rights reserved.
//

import UIKit

class TruckSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var Employees: Array<AnyObject> = []
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ChangeSearchButtonPress(sender: AnyObject) {
        if (SearchCriteria.text == "Fleet Number:")
        {
            SearchCriteria.text = "Employee Name:"
            SearchStart.text = ""
            ChangeSearch.setTitle("Search by Truck Number", forState: UIControlState.Normal)
            TextBox.keyboardType = UIKeyboardType.Default
            TextBox.autocapitalizationType = .Words
            TextBox.reloadInputViews()
        }
        else{
            SearchCriteria.text = "Fleet Number:"
            SearchStart.text = "01 -"
            ChangeSearch.setTitle("Search by Employee Name", forState: UIControlState.Normal)
            TextBox.reloadInputViews()
            TextBox.keyboardType = UIKeyboardType.NumberPad
            TextBox.autocapitalizationType = .None
            TextBox.reloadInputViews()
        }
    }

    
    @IBAction func SearchClick(sender: AnyObject) {
        if (TextBox.text == "") {
            return
        }
        
        if (TextBox.text == ":-)") {
            let alertController = UIAlertController(title: "Wazzup?!", message:
                "", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        var nameSearched = ""
        var truckNumber = ""
        
        if (SearchCriteria.text == "Fleet Number:")
        {
            truckNumber = TextBox.text!
        }
        else if (SearchCriteria.text == "Employee Name:")
        {
            nameSearched = TextBox.text!
        }
        
    if let url = NSURL(string: "https://clydewap.clydeinc.com/webservices/json/GetTrucks?name=\(nameSearched)&truck=\(truckNumber)&token=tRuv%5E:%5D56NEn61M5vl3MGf/5A/gU%3C@") {

        let request = NSMutableURLRequest(URL: url)
        request.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPMethod = "POST"
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else { // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                print("response = \(response)")
            }
            
//            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            
            let mydata = try? NSJSONSerialization.JSONObjectWithData(data!, options:.MutableContainers)
            
            print(mydata)
            
            self.Employees = mydata as! Array<AnyObject>
            
            
            
        }
        task.resume()
        
        self.ResultsTable.reloadData()
        
        self.dismissKeyboard()
        
    }
    }
    
    
    @IBOutlet weak var SearchCriteria: UILabel!

    @IBOutlet weak var SearchStart: UILabel!
    
    @IBOutlet weak var ChangeSearch: UIButton!
    
    @IBOutlet weak var TextBox: UITextField!
    
    @IBOutlet weak var ResultsTable: UITableView!
    
    
    
    
    // MARK: Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Employees.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.ResultsTable.dequeueReusableCellWithIdentifier("RESULT", forIndexPath: indexPath) as! TruckSearchTableViewCell
        
            if let cName = Employees[indexPath.row]["CompanyName"] as? String {
                cell.companyLabel.text = cName
            }
            if let name = Employees[indexPath.row]["EmployeeName"] as? String {
                cell.nameLabel.text = name
            }
            if let mobile = Employees[indexPath.row]["PhoneNumber"] as? String {
                cell.mobileLabel.text = mobile
            }
            if let jobTitle = Employees[indexPath.row]["JobTitle"] as? String {
                cell.titleLabel.text = jobTitle
            }
            if let tNumber = Employees[indexPath.row]["TruckNumber"] as? String {
                cell.truckLabel.text = tNumber
            }
            if let Supervisor = Employees[indexPath.row]["SupervisorName"] as? String {
                cell.supervisorLabel.text = Supervisor
            }
        

        return cell
    }
    
    
}
