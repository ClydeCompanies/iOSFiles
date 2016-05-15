//
//  HomeViewController.swift
//  ClydeLink Apps
//
//  Created by J J Feddock on 5/14/16.
//  Copyright © 2016 XLR8 Development LLC. All rights reserved.
//

// Jackson was here.

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.headerButtons.addObject("Accounting and Credit Apps")
        self.headerButtons.addObject("Employee Apps")
        self.headerButtons.addObject("Equipment Apps")
        self.headerButtons.addObject("Human Resources Apps")
       
        self.appButtons.addObject("Accounting App")
        self.appButtons.addObject("Credit App")
        self.appButtons.addObject("Employee Search")
        self.appButtons.addObject("Employee Info")
        self.appButtons.addObject("Truck Search")
        self.appButtons.addObject("Equipment Search")
        self.appButtons.addObject("Human Resources")
        self.appButtons.addObject("HR Search")
        
        
        AppTable.separatorStyle = UITableViewCellSeparatorStyle.None
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - AppTable View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.headerButtons.count + self.appButtons.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0
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
            if (indexPath.row == 1 || indexPath.row == 2)
            {
                return 60.0
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
            if (indexPath.row == 4 || indexPath.row == 5)
            {
                return 60.0
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
            if (indexPath.row == 7 || indexPath.row == 8)
            {
                return 60.0
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
            if (indexPath.row == 10 || indexPath.row == 11)
            {
                return 60.0
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
