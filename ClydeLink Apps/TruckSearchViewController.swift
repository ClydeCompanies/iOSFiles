//
//  TruckSearchViewController.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 5/12/16.
//

import UIKit

class TruckSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {  // Provides backend code for both the TruckSearchViewController, but also the DataSource and Delegate for the ResultsTable embedded within it
    
    var Employees: Array<AnyObject> = []  // Array that holds information retrieved from server in POST query of Truck Search
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status and drop into background
        view.endEditing(true)
    }
    
    override func viewDidLoad() {  // Runs as soon as the view is brought into the foreground
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)  // Allows dismissal of keyboard on tap anywhere on screen besides the keyboard itself
        
        ResultsTable.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        ResultsTable.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
/*    @IBAction func ChangeSearchButtonPress(sender: AnyObject) {  // Runs when text is pressed signifying a change in search parameters
        if (SearchCriteria.text == "Fleet Number:")  // If current search criteria is Truck, change it to Employee
        {
            SearchCriteria.text = "Employee Name:"
            SearchStart.text = ""
            ChangeSearch.setTitle("Search by Truck Number", forState: UIControlState.Normal)
            TextBox.keyboardType = UIKeyboardType.Default
            TextBox.autocapitalizationType = .Words
            TextBox.reloadInputViews()
        }
        else{  // Do the opposite! (Change search parameter to
            SearchCriteria.text = "Fleet Number:"
            SearchStart.text = "01 -"
            ChangeSearch.setTitle("Search by Employee Name", forState: UIControlState.Normal)
            TextBox.reloadInputViews()
            TextBox.keyboardType = UIKeyboardType.NumberPad
            TextBox.autocapitalizationType = .None
            TextBox.reloadInputViews()
        }
    } */

    
    @IBAction func SearchClick(sender: AnyObject) {  // Program reaction to a click on the search button, initially if the search box is empty, will have to effect, otherwise will query the database for information
        
        if (TextBox.text == "") {
            return
        }
        
        Employees = []
        ResultsTable.reloadData()
        
        if (TextBox.text == ":-)") {
            let alertController = UIAlertController(title: "You Win!", message:
                "", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        var nameSearched = ""
        var truckNumber = ""
        
        if (Int(TextBox.text!) != nil)  // Tests whether the input was a number (for Truck Search) or text (for Employee Search)
        {
            truckNumber = TextBox.text!
        }
        else
        {
            nameSearched = TextBox.text!
        }
        
    if let url = NSURL(string: "https://clydewap.clydeinc.com/webservices/json/GetTrucks?name=\(nameSearched)&truck=\(truckNumber)&token=tRuv%5E:%5D56NEn61M5vl3MGf/5A/gU%3C@") {  // Sends POST request to the DMZ server, and prints the response string as an array

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
            
            let mydata = try? NSJSONSerialization.JSONObjectWithData(data!, options:.MutableContainers) // Creates dictionary array to save results of query
            
            print(mydata)
            
            self.Employees = mydata as! Array<AnyObject>  // Saves the resulting array to Employees Array
            
            self.ResultsTable.reloadData()  // Refreshes the table information
            
            
        }
        task.resume()
        
        
        self.dismissKeyboard()  // Dismisses keyboard after the search
        
    }
    }
    
    
    @IBOutlet weak var SearchCriteria: UILabel!

    @IBOutlet weak var SearchStart: UILabel!
    
    @IBOutlet weak var ChangeSearch: UIButton!
    
    @IBOutlet weak var TextBox: UITextField!
    
    @IBOutlet weak var ResultsTable: UITableView!
    
    
    
    
    // MARK: Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {  // Returns length of the query result, showing how many table cells to create
        var numberOfRows: Int = 1
        if (Employees.count > numberOfRows)
        {
            numberOfRows = Employees.count
        }

        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {  // Creates each cell, by parsing through the data received from the Employees array which we returned from the database
        if (Employees.count == 0)
        {
            let cell = self.ResultsTable.dequeueReusableCellWithIdentifier("NORESULT", forIndexPath: indexPath) as! TruckSearchTableViewCell
            
            return cell
        }
            
        else {
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
//            if let ePhoto = Employees[indexPath.row]["PicLocation"] as? String {  // Save complete URL of picture location, and save it to the table
//                
//                let url = NSURL(string: "https://clydelink.sharepoint.com/apps/Profile%20Pictures%20Large/\(ePhoto)LThumb.jpg")!
//                if let data = NSData(contentsOfURL: url){
//                    let myImage = UIImage(data: data)
//                    cell.employeePhoto.image = myImage
//                }
//                
//            }

            return cell
        }
    }
    
    
}
