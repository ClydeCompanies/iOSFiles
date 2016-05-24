//
//  EditViewController.swift
//  ClydeLink Apps
//
//  Created by J J Feddock on 5/14/16.
//  Copyright © 2016 XLR8 Development LLC. All rights reserved.
//

import UIKit
import CoreData

class EditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var AppTable: UITableView!
    
    var headerButtons: NSMutableArray! = NSMutableArray()
    
    var appButtons: NSMutableArray! = NSMutableArray()
    
    var AccountingVisible = true
    var EmployeeVisible = true
    var EquipmentVisible = true
    var HRVisible = true
    
    var AppCount: Int = 0
    
    let prefs = NSUserDefaults.standardUserDefaults()
    var checked: Array = [AnyObject](count: 12, repeatedValue: true)
    
    
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
        
        
        AppTable.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        AppTable.tableFooterView = UIView(frame: CGRectZero)
        
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
    
    @IBAction func DoneButtonPress(sender: AnyObject) {
        
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("Main")
        self.showViewController(vc as! UIViewController, sender: vc)
        prefs.setObject(checked, forKey: "userChecked")
        prefs.synchronize()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            
            if !(checked[indexPath.row] as! Bool) {
                cell.accessoryType = .None
            } else if (checked[indexPath.row] as! Bool) {
                cell.accessoryType = .Checkmark
            }
            AppCount += 1;
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 60.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
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
