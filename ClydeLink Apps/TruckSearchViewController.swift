//
//  TruckSearchViewController.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 5/12/16.
//

import UIKit

class TruckSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {  // Provides backend code for both the TruckSearchViewController, but also the DataSource and Delegate for the ResultsTable embedded within it
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var txtValue: UITextField!
    
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
        
        ResultsTable.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        
        ResultsTable.tableFooterView = UIView(frame: CGRect.zero)
        
        activityIndicator.isHidden = true
        
        txtValue.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        Search()
        return true
    }
    
    func Search() {
        if (TextBox.text == "") {
            return
        }
        
        self.activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        Employees = []
        ResultsTable.reloadData()
        
        if (TextBox.text == ":-)") {
            let alertController = UIAlertController(title: "You Win!", message:
                "", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            self.activityIndicator.stopAnimating()  // Ends spinner
            self.activityIndicator.isHidden = true
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
        
        if let url = URL(string: "https://cciportal.clydeinc.com/webservices/json/ClydeWebServices/GetTrucks?name=\(nameSearched)&truck=\(truckNumber)") {  // Sends POST request to the DMZ server, and prints the response string as an array
            
            let request = NSMutableURLRequest(url: url)
            
            request.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard error == nil && data != nil else { // check for fundamental networking error
                    print("error=\(String(describing: error))")
                    self.flag = 1
                    
                    let alertController = UIAlertController(title: "Error", message:
                        "Could not connect to the server.", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 { // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }
                
                let mydata = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) // Creates dictionary array to save results of query
                
                DispatchQueue.main.async {  // Brings data from background task to main thread, loading data and populating TableView
                    if (mydata == nil)
                    {
                        self.flag = 1
                        self.ResultsTable.reloadData()
                        
                        let alertController = UIAlertController(title: "Error", message:
                            "Could not connect to the server.", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                        
                        self.present(alertController, animated: true, completion: nil)
                        self.activityIndicator.stopAnimating()
                        
                        return
                    }
                    if ((mydata! as AnyObject).count == 0)
                    {
                        self.flag = 1
                        self.ResultsTable.reloadData()
                        
                        return
                    }
                    
                    self.Employees = mydata as! Array<AnyObject>  // Saves the resulting array to Employees Array
                    self.ResultsTable.reloadData()  // Reloads Table View cells as results
                    self.activityIndicator.stopAnimating()  // Ends spinner
                }
                
            }) 
            task.resume()
            
            self.dismissKeyboard()  // Dismisses keyboard after the search
            self.ResultsTable.reloadData()  // Reloads Table View cells as results
            
            
            
        }
    }

    
    @IBAction func SearchClick(_ sender: AnyObject) {  // Program reaction to a click on the search button, initially if the search box is empty, will have no effect, otherwise will query the database for information
        Search()
    }
    
    
    @IBOutlet weak var SearchCriteria: UILabel!

    @IBOutlet weak var SearchStart: UILabel!
    
    @IBOutlet weak var ChangeSearch: UIButton!
    
    @IBOutlet weak var TextBox: UITextField!
    
    @IBOutlet weak var ResultsTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {  // Returns length of the query result, showing how many table cells to create
        var numberOfRows: Int = 1
        if (Employees.count > numberOfRows)
        {
            numberOfRows = Employees.count
        }

        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {  // Creates each cell, by parsing through the data received from the Employees array which we returned from the database
        if (Employees.count == 0)
        {
            let cell = self.ResultsTable.dequeueReusableCell(withIdentifier: "NORESULT", for: indexPath) as! TruckSearchNRTableViewCell
            
            return cell
        }
            
        else {
            let cell = self.ResultsTable.dequeueReusableCell(withIdentifier: "RESULT", for: indexPath) as! TruckSearchTableViewCell
        
                cell.companyLabel.text = Employees[(indexPath as NSIndexPath).row]["CompanyName"] as? String
                cell.nameLabel.text = Employees[(indexPath as NSIndexPath).row]["EmployeeName"] as? String
            if let mobile = Employees[(indexPath as NSIndexPath).row]["PhoneNumber"] as? String {
                if (mobile == "")
                {
                    cell.mobileLabel.isHidden = true
                    cell.mobileTitle.isHidden = true
                } else {
                    cell.mobileTitle.isHidden = false
                    cell.mobileLabel.isHidden = false
                }
                let phonenumber = mobile.replacingOccurrences(of: "[^0-9]", with: "", options: NSString.CompareOptions.regularExpression, range:nil);
                cell.phoneNumber.text = phonenumber
            }
                cell.titleLabel.text = Employees[(indexPath as NSIndexPath).row]["JobTitle"] as? String
                cell.truckLabel.text = Employees[(indexPath as NSIndexPath).row]["TruckNumber"] as? String
                cell.supervisorLabel.text = Employees[(indexPath as NSIndexPath).row]["SupervisorName"] as? String
            if (Employees[(indexPath as NSIndexPath).row]["Synced"] as? Int) == 0 {
                turnRed(cell)
            } else {
                turnBlack(cell)
            }
            if let ePhoto = Employees[(indexPath as NSIndexPath).row]["PicLocation"] as? String {  // Save complete URL of picture location, and save it to the table
                
                let url = URL(string: "https://cciportal.clydeinc.com/images/Small/\(ePhoto)")!
                if let data = try? Data(contentsOf: url){
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (Employees.count > 0)
        {
            return 140
        }
        else
        {
            return 89
        }
        
    }
    
    
    func turnRed(_ cell:TruckSearchTableViewCell) {  // Turn all text labels in this cell to RED
        cell.companyLabel.textColor = UIColor.red
        cell.nameLabel.textColor = UIColor.red
        cell.titleLabel.textColor = UIColor.red
        cell.truckLabel.textColor = UIColor.red
        cell.supervisorLabel.textColor = UIColor.red
        
        cell.companyTitle.textColor = UIColor.red
        cell.nameTitle.textColor = UIColor.red
        cell.mobileTitle.textColor = UIColor.red
        cell.titleTitle.textColor = UIColor.red
        cell.truckTitle.textColor = UIColor.red
        cell.supervisorTitle.textColor = UIColor.red
    }
    func turnBlack(_ cell:TruckSearchTableViewCell) {  // Turn all text labels in this cell to black
        cell.companyLabel.textColor = UIColor.black
        cell.nameLabel.textColor = UIColor.black
        cell.titleLabel.textColor = UIColor.black
        cell.truckLabel.textColor = UIColor.black
        cell.supervisorLabel.textColor = UIColor.black
        
        cell.companyTitle.textColor = UIColor.black
        cell.nameTitle.textColor = UIColor.black
        cell.mobileTitle.textColor = UIColor.black
        cell.titleTitle.textColor = UIColor.black
        cell.truckTitle.textColor = UIColor.black
        cell.supervisorTitle.textColor = UIColor.black
    }
    
}
