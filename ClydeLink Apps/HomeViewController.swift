//
//  HomeViewController.swift
//  ClydeLink Apps
//
//  Created by J J Feddock on 5/14/16.
//  Copyright © 2016 XLR8 Development LLC. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var leftButton: UIBarButtonItem!
    
    @IBOutlet weak var AppTable: UITableView!
    
    var headerButtons: NSMutableArray! = NSMutableArray()
    
    var appButtons: NSMutableArray! = NSMutableArray()
    
    var AccountingVisible = false
    var EmployeeVisible = false
    var EquipmentVisible = false
    var HRVisible = false
    
    var AppCount: Int = 0
    
    let prefs = NSUserDefaults.standardUserDefaults()
    var checked: Array = [AnyObject](count: 12, repeatedValue: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.headerButtons.addObject("Accounting and Credit Apps")
        self.headerButtons.addObject("Employee Apps")
        self.headerButtons.addObject("Equipment Apps")
        self.headerButtons.addObject("Human Resources Apps")
       
        self.appButtons.addObject("Create New Customer Account")
        self.appButtons.addObject("Credit Dashboard")
        self.appButtons.addObject("New Hire")
        self.appButtons.addObject("Expense Reimbursement")
        self.appButtons.addObject("Truck Search")
        self.appButtons.addObject("Equipment Search")
        self.appButtons.addObject("Training Request Form")
        self.appButtons.addObject("HR Search")
        
        
        AppTable.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        AppTable.tableFooterView = UIView(frame: CGRectZero)
        
        loadChecked()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    // MARK: - AppTable View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        return "Logged in as: " + prefs.stringForKey("username")!
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        loadChecked()
        
        return self.headerButtons.count + self.appButtons.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
            
            AppCount += 1;
            return cell
        }
    }
    
    
    // This is what the function does
    // Input:
    // Output:
    // @param: 
    // @return:
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if (AccountingVisible == true)
        {
            if (indexPath.row == 1 && checked[1] as! NSObject == true)
            {
                return 60.0
            }
            else if (indexPath.row == 1 && checked[1] as! NSObject == false)
            {
                return 0.0
            }
            if (indexPath.row == 2 && checked[2] as! NSObject == true)
            {
                return 60.0
            }
            else if (indexPath.row == 2 && checked[2] as! NSObject == false)
            {
                return 0.0
            }
            
        }
        else if (AccountingVisible == false)
        {
            if (indexPath.row == 1 || indexPath.row == 2)
            {
                return 0.0
            }
        }
        
        if (EmployeeVisible == true)
        {
            if (indexPath.row == 4 && checked[4] as! NSObject == true)
            {
                return 60.0
            }
            else if (indexPath.row == 4 && checked[4] as! NSObject == false)
            {
                return 0.0
            }
            if (indexPath.row == 5 && checked[5] as! NSObject == true)
            {
                return 60.0
            }
            else if (indexPath.row == 5 && checked[5] as! NSObject == false)
            {
                return 0.0
            }
        }
        else if (EmployeeVisible == false)
        {
            if (indexPath.row == 4 || indexPath.row == 5)
            {
                return 0.0
            }
        }
        
        if (EquipmentVisible == true)
        {
            if (indexPath.row == 7 && checked[7] as! NSObject == true)
            {
                return 60.0
            }
            else if (indexPath.row == 7 && checked[7] as! NSObject == false)
            {
                return 0.0
            }
            if (indexPath.row == 8 && checked[8] as! NSObject == true)
            {
                return 60.0
            }
            else if (indexPath.row == 8 && checked[8] as! NSObject == false)
            {
                return 0.0
            }
        }
        else if (EquipmentVisible == false)
        {
            if (indexPath.row == 7 || indexPath.row == 8)
            {
                return 0.0
            }
        }
        
        if (HRVisible == true)
        {
            if (indexPath.row == 10 && checked[10] as! NSObject == true)
            {
                return 60.0
            }
            else if (indexPath.row == 10 && checked[10] as! NSObject == false)
            {
                return 0.0
            }
            if (indexPath.row == 11 && checked[11] as! NSObject == true)
            {
                return 60.0
            }
            else if (indexPath.row == 11 && checked[11] as! NSObject == false)
            {
                return 0.0
            }
        }
        else if (HRVisible == false)
        {
            if (indexPath.row == 10 || indexPath.row == 11)
            {
                return 0.0
            }
        }
        return 60.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if (indexPath.row == 0 && AccountingVisible == false)
        {
            closeAllButtons()
            AccountingVisible = true
            AppTable.reloadData()
        }
        else if (indexPath.row == 0 && AccountingVisible == true)
        {
            AccountingVisible = false
            AppTable.reloadData()
        }
        
        if (indexPath.row == 3 && EmployeeVisible == false)
        {
            closeAllButtons()
            EmployeeVisible = true
            AppTable.reloadData()
        }
        else if (indexPath.row == 3 && EmployeeVisible == true)
        {
            EmployeeVisible = false
            AppTable.reloadData()
        }
        
        if (indexPath.row == 6 && EquipmentVisible == false)
        {
            closeAllButtons()
            EquipmentVisible = true
            AppTable.reloadData()
        }
        else if (indexPath.row == 6 && EquipmentVisible == true)
        {
            EquipmentVisible = false
            AppTable.reloadData()
        }
        
        if (indexPath.row == 9 && HRVisible == false)
        {
            closeAllButtons()
            HRVisible = true
            AppTable.reloadData()
        }
        else if (indexPath.row == 9 && HRVisible == true)
        {
            HRVisible = false
            AppTable.reloadData()
        }
        
        if (indexPath.row == 7)
        {
            let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("Truck Search")
            self.showViewController(vc as! UIViewController, sender: vc)
        }
        else if (indexPath.row % 3 != 0)
        {
            let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("Construction")
            self.showViewController(vc as! UIViewController, sender: vc)
        }
        
        AppTable.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func closeAllButtons()
    {
        AccountingVisible = false
        EmployeeVisible = false
        EquipmentVisible = false
        HRVisible = false
    }
    
    @IBAction func editTable(sender: AnyObject) {
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("Edit")
        self.showViewController(vc as! UIViewController, sender: vc)
        
    }
    
    
    @IBAction func settingsButton(sender: AnyObject) {
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("Settings")
        self.showViewController(vc as! UIViewController, sender: vc)
        
    }
    
    
    
    func loadChecked()
    {
        if (prefs.arrayForKey("userChecked") != nil) {
            checked = prefs.arrayForKey("userChecked")!
        } else {
            checked = [true,true,true,true,true,true,true,true,true,true,true,true]
        }
    }
    
    
    
    
    
    
//    This is for the URL Schemes:
//    
//    if let url = NSURL(string: "app://") where UIApplication.sharedApplication().canOpenURL(url) {
//    UIApplication.sharedApplication().openURL(url)
//    } else if let itunesUrl = NSURL(string: "https://itunes.apple.com/itunes-link-to-app") where UIApplication.sharedApplication().canOpenURL(itunesUrl) {
//    UIApplication.sharedApplication().openURL(itunesUrl)
//    }
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
