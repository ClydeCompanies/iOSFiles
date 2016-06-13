//
//  AddViewController.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 6/5/16.
//

import UIKit

class AddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var AppTable: UITableView!
    
    var AppCount: Int = 0  // Increments and controls distribution of array data to UITable
    
    let prefs = NSUserDefaults.standardUserDefaults()  // Current user preferences
    var currentapps: Array = [App]()
    var appStore: Array = [App]()
//    var selected: Array = [App]()
//    var headers: Array = [String]()
//    var headered: Array = [App]()
    
//    var headersused: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadApps()
        // Do any additional setup after loading the view.
        
        AppTable.tableFooterView = UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func DoneSelected(sender: AnyObject) {
        for element in appStore
        {
            if (element.selected)
            {
                for element2 in currentapps
                {
                    if (element.title == element2.title)
                    {
                        currentapps.removeAtIndex(currentapps.indexOf(element2)!)
                        element.selected = true
                        currentapps.append(element)
                        break
                    }
                }
            }
        }
        let appData = NSKeyedArchiver.archivedDataWithRootObject(currentapps)
        prefs.setObject(appData, forKey: "userapps")
        prefs.synchronize()

        let vc : UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Main")
        //vc.setEditing(true, animated: true)
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func addButtonClicked(sender: AnyObject) {
        loadApps()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: Table View Functions
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {  // Disallow Delete
        return .None
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        loadApps()
            let cell = self.AppTable.dequeueReusableCellWithIdentifier("AppCell", forIndexPath: indexPath) as! AddTableViewCell
                cell.Title.text = self.appStore[indexPath.row].title
                cell.accessoryType = UITableViewCellAccessoryType.None;
        
            return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appStore.count
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        header.textLabel!
            .textColor = UIColor.blackColor()
        header.textLabel!.font = UIFont.boldSystemFontOfSize(12)
        header.textLabel!.frame = header.frame
        header.textLabel!.textAlignment = NSTextAlignment.Left
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 18
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {  // Informs GUI of how many sections there are
        return 1;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {  // Determine what to do with button press
        //appStore[indexPath.row].selected = !appStore[indexPath.row].selected
        let buttonpressed = self.appStore[indexPath.row]
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
    
    //cell click add function:
    /*
     for element in currentapps
     {
     let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as! AppTableViewCell
     if (currentCell.Title.text == element.title)
     {
     element.selected = true
     }
     }
     buildAppStore()
     tableView.reloadData()
    */
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {  // Sets up title and sets username as the title for the home menu
        var uName: String = ""
        if (prefs.stringForKey("username") != nil)
        {
            uName = prefs.stringForKey("username")!
        }
        return "Logged in as " + uName
    }
    
    func loadApps() {
        if let data = prefs.objectForKey("userapps") as? NSData {
            currentapps = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [App]
        } else {
            currentapps = []
            fillAppArray(&currentapps)
        }
        buildAppStore()
//        sortarray(&currentapps)
    }
    
    func fillAppArray(inout currentapps: [App])
    {
        let debug = false
        //              HEADER                          TITLE                           LINK      PERMISSIONS SELECTED
        currentapps.append(
            App(h: "Accounting and Credit Apps",t: "Create New Customer Account",l: "newcustomeraccount",  p: 4, s: debug))
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
        
        let appData = NSKeyedArchiver.archivedDataWithRootObject(currentapps)
        prefs.setObject(appData, forKey: "userapps")
        prefs.synchronize()
    }
    
    func buildAppStore() {
        appStore = []
        
        for element in currentapps
        {
            if !element.selected
            {
                appStore.append(element)
            }
        }
    }
    
//    func sortarray(inout currentapps: [App])
//    {
//        headers = []
//        headered = []
//        for element in currentapps {
//            if (!headers.contains(element.header) && !element.selected)
//            {
//                headers.append(element.header)
//            }
//        }
//        for header in headers
//        {
//            for element in currentapps
//            {
//                if (element.header == header)
//                {
//                    headered.append(element)
//                }
//            }
//        }
////        currentapps = headered
//    }
}
