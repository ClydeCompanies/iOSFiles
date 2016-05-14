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
    
    var AccCreditButtons: NSMutableArray! = NSMutableArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.headerButtons.addObject("Accounting and Credit Apps")
        self.headerButtons.addObject("Employee Apps")
        self.headerButtons.addObject("Equipment Apps")
        self.headerButtons.addObject("Human Resources Apps")
        
        self.AccCreditButtons.addObject("Accounting Apps")
        self.AccCreditButtons.addObject("Credit Apps")
        
        AppTable.reloadData()
        
        AppTable.separatorStyle = UITableViewCellSeparatorStyle.None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - AppTable View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.headerButtons.count + self.AccCreditButtons.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        print(indexPath.row)
        
        if indexPath.row == 0
        {
            let cell = self.AppTable.dequeueReusableCellWithIdentifier("HeaderCell", forIndexPath: indexPath) as! HeaderTableViewCell
        
        cell.Title.text = self.headerButtons.objectAtIndex(indexPath.row) as? String
        
            
        return cell
        }
        else if (indexPath.row == 1 || indexPath.row == 2)
        {
            let cell = self.AppTable.dequeueReusableCellWithIdentifier("AppCell", forIndexPath: indexPath) as! AppTableViewCell
            
            cell.Title.text = self.AccCreditButtons.objectAtIndex(indexPath.row - 1) as? String
            
            return cell
        }
        else{
            let cell = self.AppTable.dequeueReusableCellWithIdentifier("HeaderCell", forIndexPath: indexPath) as! HeaderTableViewCell
            
            cell.Title.text = self.headerButtons.objectAtIndex(indexPath.row-2) as? String
            
            return cell
        }
    }
    
    @IBAction func editTable(sender: AnyObject) {
        if (AppTable.editing == false)
        {
            leftButton.title = "Done"
            AppTable.editing = true
        }
        else
        {
            leftButton.title = "Edit"
            AppTable.editing = false
        }
        
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
