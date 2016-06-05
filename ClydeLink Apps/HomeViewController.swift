//
//  HomeViewController.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 5/14/16.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var leftButton: UIBarButtonItem!
    
    @IBOutlet weak var rightButton: UIBarButtonItem!
    
    @IBOutlet weak var AppTable: UITableView!
    
    var appButtons: Array = [App]()
    
    var AppCount: Int = 0  // Increments and controls distribution of array data to UITable
    
    let prefs = NSUserDefaults.standardUserDefaults()  // Current user preferences
    var currentapps: Array = [App]()
    
    override func viewDidLoad() {  // Runs when the view loads
        super.viewDidLoad()
        loadChecked()
        
        //Go through and find headers
        for element in currentapps
        {
            if (element.selected)
            {
                self.appButtons.append(element)
            }
        }
        
        AppTable.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        AppTable.tableFooterView = UIView(frame: CGRectZero)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // MARK: - AppTable View
    
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {  // Returns length of all the buttons needed
        
        return self.appButtons.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {  // Determines which buttons should be header buttons and which chould carry on to other views
        if indexPath.row == 0
        {
            AppCount = 0
        }
        if (AppCount == self.appButtons.count)
        {
            AppCount = 0
        }
            let cell = self.AppTable.dequeueReusableCellWithIdentifier("AppCell", forIndexPath: indexPath) as! AppTableViewCell
            
            cell.Title.text = self.appButtons[AppCount].title
            AppCount += 1;
            return cell
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {  // Delete the selected app
        if editingStyle == .Delete {
            for element in currentapps
            {
                if (element.title == appButtons[indexPath.row].title)
                {
                    element.selected = false
                    break
                }
            }
            let appData = NSKeyedArchiver.archivedDataWithRootObject(currentapps)
            prefs.setObject(appData, forKey: "userapps")
            prefs.synchronize()
            appButtons.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {  // Allow Delete
        if self.AppTable.editing {return .Delete}
        return .None
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {  // Move apps within table
        let itemToMove = appButtons[fromIndexPath.row]
        appButtons.removeAtIndex(fromIndexPath.row)
        appButtons.insert(itemToMove, atIndex: toIndexPath.row)
        var fromindex: Int = 0
        for element in currentapps
        {
            if (element.title == itemToMove.title) {
                fromindex = currentapps.indexOf(element)!
            }
        }
        
        var toindex: Int = 0
        
        for element in currentapps
        {
            if (element.title == appButtons[fromIndexPath.row + 1].title) {
                toindex = currentapps.indexOf(element)!
            }
        }
        currentapps.removeAtIndex(fromindex)
        currentapps.insert(itemToMove, atIndex: toindex + 1)
        let appData = NSKeyedArchiver.archivedDataWithRootObject(currentapps)
        prefs.setObject(appData, forKey: "userapps")
        prefs.synchronize()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {  // Gives the height for each row
        return 60.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {  // Determine what to do with button press
        let buttonpressed = self.appButtons[indexPath.row]
        var vc : AnyObject! = nil
        switch (buttonpressed.link)
        {
            case "vehiclesearch":
                vc = self.storyboard!.instantiateViewControllerWithIdentifier("Truck Search")
                break;
            default:
                vc = self.storyboard!.instantiateViewControllerWithIdentifier("Construction")
                break;
        }
        self.showViewController(vc as! UIViewController, sender: vc)
        AppTable.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    @IBAction func editTable(sender: AnyObject) {  // Edit button pressed
        if (leftButton.title == "Edit")
        {
            AppTable.setEditing(true,animated: true)
            leftButton.title = "Done"
            rightButton.title = "Add"
        } else if (leftButton.title == "Done")
        {
            AppTable.setEditing(false,animated: true)
            leftButton.title = "Edit"
            rightButton.title = "Settings"
        }
    }
    
    
    @IBAction func settingsButton(sender: AnyObject) {  // Settings button pressed
        if (rightButton.title == "Settings")
        {
            let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("Settings")
            self.presentViewController(vc as! UIViewController, animated: false, completion: nil)
        } else if (rightButton.title == "Add")
        {
            let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("Add Features")
            self.presentViewController(vc as! UIViewController, animated: false, completion: nil)
        }
    }
    
    func loadChecked()
    {  // Find the array for visible buttons
        if let data = prefs.objectForKey("userapps") as? NSData {
            currentapps = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [App]
        } else {
            currentapps = []
            fillAppArray(&currentapps)
        }
    }
    
    func fillAppArray(inout currentapps: [App])
    {
        let debug = true
        //              HEADER                          TITLE                           LINK      PERMISSIONS SELECTED
        currentapps.append(
        App(h:"Accounting and Credit Apps", t: "Create New Customer Account",l: "newcustomeraccount",  p: 4, s: debug))
        currentapps.append(
        App(h: "Accounting and Credit Apps",t: "Credit Dashboard",           l: "creditdashboard",     p: 4, s: debug))
        
        currentapps.append(
        App(h: "Employee Apps",             t: "New Hire",                   l: "newhire",             p: 4, s: debug))
        currentapps.append(
        App(h: "Employee Apps",             t: "Expense Reimbursement",      l: "expensereimbursement",p: 4, s: debug))
        
        currentapps.append(
        App(h: "Equipment Apps",           t: "Vehicle Search",              l: "vehiclesearch",       p: 4, s: debug))
        currentapps.append(
        App(h: "Equipment Apps",           t: "Equipment Search",            l: "equipmentsearch",     p: 4, s: debug))
        
        currentapps.append(
        App(h: "Human Resources Apps",     t: "Training Request Form",       l: "trainingrequestform", p: 4, s: debug))
        currentapps.append(
        App(h: "Human Resources Apps",     t: "Employee Directory",          l: "employeedirectory",   p: 4, s: debug))
        
        //Convert function
        let appData = NSKeyedArchiver.archivedDataWithRootObject(currentapps)
        prefs.setObject(appData, forKey: "userapps")
        prefs.synchronize()
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
