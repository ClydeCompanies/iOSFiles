//
//  TruckSearchViewController.swift
//  ClydeLink Apps
//
//  Created by J J Feddock on 5/12/16.
//  Copyright © 2016 XLR8 Development LLC. All rights reserved.
//

import UIKit

class TruckSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
        
    if let url = NSURL(string: "https://63.157.124.27/") {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPBody = "name=&truck=70&token=tRuv^:]56NEn61M5vl3MGf/5A/gU<@".dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPMethod = "POST"
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else { // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
    }
    
    
    @IBOutlet weak var SearchCriteria: UILabel!

    @IBOutlet weak var SearchStart: UILabel!
    
    @IBOutlet weak var ChangeSearch: UIButton!
    
    @IBOutlet weak var TextBox: UITextField!
    
    @IBOutlet weak var ResultsTable: UITableView!
    
    
    
    
    // MARK: Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.ResultsTable.dequeueReusableCellWithIdentifier("NONE", forIndexPath: indexPath) as! TruckSearchTableViewCell
        
        return cell
    }

    
    
}







