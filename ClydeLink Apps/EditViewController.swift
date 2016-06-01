//
//  EditViewController.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 5/14/16.
//

import UIKit
import CoreData

class EditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var AppTable: UITableView!
    
    var headerButtons: NSMutableArray! = NSMutableArray()
    
    var appButtons: NSMutableArray! = NSMutableArray()
    
    var AccountingVisible = true  //
    var EmployeeVisible = true    // Expand all views
    var EquipmentVisible = true   //
    var HRVisible = true          //
    
    var AppCount: Int = 0  // Increments and controls distribution of array data to UITable
    
    let prefs = NSUserDefaults.standardUserDefaults()  // Current user preferences
    var checked: Array = [AnyObject](count: 12, repeatedValue: true)  // Controls which buttons are visible
    
    
    override func viewDidLoad() {  // Runs when the view loads
        super.viewDidLoad()
        
        self.headerButtons.addObject("Accounting and Credit Apps")
        self.headerButtons.addObject("Employee Apps")
        self.headerButtons.addObject("Equipment Apps")
        self.headerButtons.addObject("Human Resources Apps")
        
        self.appButtons.addObject("Create New Customer Account")
        self.appButtons.addObject("Credit Dashboard")
        self.appButtons.addObject("New Hire")
        self.appButtons.addObject("Expense Reimbursement")
        self.appButtons.addObject("Vehicle Search")
        self.appButtons.addObject("Equipment Search")
        self.appButtons.addObject("Training Request Form")
        self.appButtons.addObject("Emmployee Directory")
        
        
        AppTable.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        AppTable.tableFooterView = UIView(frame: CGRectZero)
        //Get current preferred options
        if (prefs.arrayForKey("userChecked") != nil) {
            checked = prefs.arrayForKey("userChecked")!
        } else {
            checked = [true,true,true,true,true,true,true,true,true,true,true,true]
        }
//        print(checked)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func DoneButtonPress(sender: AnyObject) {  // Done button pressed > Go to Home View
        
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("Main")
        self.presentViewController(vc as! UIViewController, animated: false, completion: nil)
        
        
        prefs.setObject(checked, forKey: "userChecked")
        prefs.synchronize()
    }
    
    
    
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {  // Informs GUI of how many sections there are
        return 1;
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {  // Sets up title and sets username as the title for the home menu
        var uName: String = ""
        if (prefs.stringForKey("username") != nil)
        {
            uName = prefs.stringForKey("username")!
        }
        return "Logged in as " + uName
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {  // Get number of sections in table
        return self.headerButtons.count + self.appButtons.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {  // Return cells for each option
        
        if indexPath.row == 0
        {
            AppCount = 0
        }
        if (AppCount == 8)
        {
            AppCount = 0
        }
        
        if indexPath.row % 3 == 0
        {
            let cell = self.AppTable.dequeueReusableCellWithIdentifier("HeaderCell", forIndexPath: indexPath) as! HeaderTableViewCell
            
            cell.Title.text = self.headerButtons.objectAtIndex(indexPath.row / 3) as? String
            
            
            return cell
        }
        else
        {
            let cell = self.AppTable.dequeueReusableCellWithIdentifier("AppCell", forIndexPath: indexPath) as! AppTableViewCell
            
            cell.Title.text = self.appButtons.objectAtIndex(AppCount) as? String
            
            if !(checked[indexPath.row] as! Bool) {
                cell.accessoryType = .None
            } else if (checked[indexPath.row] as! Bool) {
                cell.accessoryType = .Checkmark
            }
            AppCount += 1;
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {  // Get height for each cell
        
        return 60.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){  // On select of any cell, change the checked  value of that cell
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .Checkmark {
                cell.accessoryType = .None
                checked[indexPath.row] = false
            }
            else if (cell.accessoryType == .None && indexPath.row % 3 != 0)
            {
                cell.accessoryType = .Checkmark
                checked[indexPath.row] = true
            }
        }
        
        
        AppTable.deselectRowAtIndexPath(indexPath, animated: true)
    }

    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
