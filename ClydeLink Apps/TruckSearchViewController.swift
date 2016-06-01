//
//  TruckSearchViewController.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 5/12/16.
//

import UIKit

class TruckSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {  // Provides backend code for both the TruckSearchViewController, but also the DataSource and Delegate for the ResultsTable embedded within it
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var Employees: Array<AnyObject> = []  // Array that holds information retrieved from server in POST query of Truck Search
    
    var flag: Int = 0  // An Error Connecting to the Server will set this flag to 1 and tell the Table to display the message!
    
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
        
        activityIndicator.hidden = true
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

    
    @IBAction func SearchClick(sender: AnyObject) {  // Program reaction to a click on the search button, initially if the search box is empty, will have no effect, otherwise will query the database for information
        
        if (TextBox.text == "") {
            return
        }
        
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
        
        Employees = []
        
        if (TextBox.text == ":-)") {
            let alertController = UIAlertController(title: "You Win!", message:
                "", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            self.activityIndicator.stopAnimating()  // Ends spinner
            self.activityIndicator.hidden = true
            return
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
        
//        request.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPMethod = "POST"
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else { // check for fundamental networking error
                print("error=\(error)")
                self.flag = 1
                self.ResultsTable.reloadData()
                
                let alertController = UIAlertController(title: "Error", message:
                    "Could not connect to the server.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                
                
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let mydata = try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) // Creates dictionary array to save results of query
            
            print(mydata)  // Direct response from server printed to console, for testing

            dispatch_async(dispatch_get_main_queue()) {  // Brings data from background task to main thread, loading data and populating TableView
                if (mydata == nil)
                {
                    self.activityIndicator.stopAnimating()  // Ends spinner
                    self.activityIndicator.hidden = true
                    self.flag = 1
                    self.ResultsTable.reloadData()
                    
                    let alertController = UIAlertController(title: "Error", message:
                        "Could not connect to the server.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                self.Employees = mydata as! Array<AnyObject>  // Saves the resulting array to Employees Array
                self.ResultsTable.reloadData()  // Reloads Table View cells as results
                self.activityIndicator.stopAnimating()  // Ends spinner
                self.activityIndicator.hidden = true  // Hides spinner
            }
            
        }
        task.resume()
        
        self.ResultsTable.reloadData()
        self.activityIndicator.stopAnimating()  // Ends spinner
        self.activityIndicator.hidden = true
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
            let cell = self.ResultsTable.dequeueReusableCellWithIdentifier("NORESULT", forIndexPath: indexPath) as! TruckSearchNRTableViewCell
            
            return cell
        }
            
//        if (Employees.count == 0 && flag == 1)
//        {
//            let cell = self.ResultsTable.dequeueReusableCellWithIdentifier("NORESULT", forIndexPath: indexPath) as! TruckSearchNRTableViewCell
//            
//            cell.errorLabel.text = "Error Connecting to Server"
//            
//            return cell
//        }
            
        else {
            let cell = self.ResultsTable.dequeueReusableCellWithIdentifier("RESULT", forIndexPath: indexPath) as! TruckSearchTableViewCell
        
            if let cName = Employees[indexPath.row]["CompanyName"] as? String {
                cell.companyLabel.text = cName
            }
            if let name = Employees[indexPath.row]["EmployeeName"] as? String {
                cell.nameLabel.text = name
            }
            if let mobile = Employees[indexPath.row]["PhoneNumber"] as? String {
                cell.mobileLabel.setTitle(mobile, forState: UIControlState.Normal)
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
            if (Employees[indexPath.row]["Synced"] as? Int) == 0 {
                turnRed(cell)
            }
            if let ePhoto = Employees[indexPath.row]["PicLocation"] as? String {  // Save complete URL of picture location, and save it to the table
                
                let url = NSURL(string: "https://clydewap.clydeinc.com/images/Medium/\(ePhoto)")!
                if let data = NSData(contentsOfURL: url){
                    let myImage = UIImage(data: data)
                    cell.employeePhoto.image = myImage
                }
                else
                {
                    cell.employeePhoto.image = UIImage(named: "person-generic")
                }
                
            }

            return cell
        }
    }
    func turnRed(cell:TruckSearchTableViewCell) {  // Turn all text labels in this cell to RED
        cell.companyLabel.textColor = UIColor.redColor()
        cell.nameLabel.textColor = UIColor.redColor()
        cell.titleLabel.textColor = UIColor.redColor()
        cell.truckLabel.textColor = UIColor.redColor()
        cell.supervisorLabel.textColor = UIColor.redColor()
        
        cell.companyTitle.textColor = UIColor.redColor()
        cell.nameTitle.textColor = UIColor.redColor()
        cell.mobileTitle.textColor = UIColor.redColor()
        cell.titleTitle.textColor = UIColor.redColor()
        cell.truckTitle.textColor = UIColor.redColor()
        cell.supervisorTitle.textColor = UIColor.redColor()
    }
    
}
