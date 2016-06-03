//
//  HomeViewController.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 5/14/16.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var leftButton: UIBarButtonItem!
    
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
        loadChecked()
        
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {  // Gives the height for each row
        return 60.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {  // Determine what to do with button press
        let buttonpressed = self.appButtons[indexPath.row]
        print(buttonpressed.header)
        print(buttonpressed.title)
        print(buttonpressed.link)
        print(buttonpressed.selected)
        print(buttonpressed.permissions)
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
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("Edit")
        self.presentViewController(vc as! UIViewController, animated: false, completion: nil)
        
    }
    
    
    @IBAction func settingsButton(sender: AnyObject) {  // Settings button pressed
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("Settings")
        self.presentViewController(vc as! UIViewController, animated: false, completion: nil)
        
    }
    
    @IBAction func AddFeatures(sender: AnyObject) {
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("Add Features")
        self.presentViewController(vc as! UIViewController, animated: false, completion: nil)
    }
    
    func loadChecked()
    {  // Find the array for visible buttons
        if (prefs.arrayForKey("userapps") != nil) {
            currentapps = prefs.arrayForKey("userapps") as! [App]
        } else {
            currentapps = []
            fillAppArray(&currentapps)
        }
    }
    
    func fillAppArray(inout currentapps: [App])
    {
        currentapps.append(App())
        currentapps[currentapps.count - 1].header = "Accounting and Credit Apps"
        currentapps[currentapps.count - 1].title = "Create New Customer Account"
        currentapps[currentapps.count - 1].link = "newcustomeraccount"
        currentapps[currentapps.count - 1].permissions = 4
        currentapps[currentapps.count - 1].selected = true
        
        currentapps.append(App())
        currentapps[currentapps.count - 1].header = "Accounting and Credit Apps"
        currentapps[currentapps.count - 1].title = "Credit Dashboard"
        currentapps[currentapps.count - 1].link = "creditdashboard"
        currentapps[currentapps.count - 1].permissions = 4
        currentapps[currentapps.count - 1].selected = true
        
        currentapps.append(App())
        currentapps[currentapps.count - 1].header = "Employee Apps"
        currentapps[currentapps.count - 1].title = "New Hire"
        currentapps[currentapps.count - 1].link = "newhire"
        currentapps[currentapps.count - 1].permissions = 4
        currentapps[currentapps.count - 1].selected = true
        
        currentapps.append(App())
        currentapps[currentapps.count - 1].header = "Employee Apps"
        currentapps[currentapps.count - 1].title = "Expense Reimbursement"
        currentapps[currentapps.count - 1].link = "expensereimbursement"
        currentapps[currentapps.count - 1].permissions = 4
        currentapps[currentapps.count - 1].selected = true
        
        currentapps.append(App())
        currentapps[currentapps.count - 1].header = "Equipment Apps"
        currentapps[currentapps.count - 1].title = "Vehicle Search"
        currentapps[currentapps.count - 1].link = "vehiclesearch"
        currentapps[currentapps.count - 1].permissions = 4
        currentapps[currentapps.count - 1].selected = true  // Debug
        
        currentapps.append(App())
        currentapps[currentapps.count - 1].header = "Equipment Apps"
        currentapps[currentapps.count - 1].title = "Equipment Search"
        currentapps[currentapps.count - 1].link = "equipmentsearch"
        currentapps[currentapps.count - 1].permissions = 4
        currentapps[currentapps.count - 1].selected = true
        
        currentapps.append(App())
        currentapps[currentapps.count - 1].header = "Human Resources Apps"
        currentapps[currentapps.count - 1].title = "Training Request Form"
        currentapps[currentapps.count - 1].link = "trainingrequestform"
        currentapps[currentapps.count - 1].permissions = 4
        currentapps[currentapps.count - 1].selected = true
        
        currentapps.append(App())
        currentapps[currentapps.count - 1].header = "Human Resources Apps"
        currentapps[currentapps.count - 1].title = "Employee Directory"
        currentapps[currentapps.count - 1].link = "employeedirectory"
        currentapps[currentapps.count - 1].permissions = 4
        currentapps[currentapps.count - 1].selected = true
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
