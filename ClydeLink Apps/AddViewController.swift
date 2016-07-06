//
//  AddViewController.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 6/5/16.
//

import UIKit


extension Array {
    func contains<T where T : Equatable>(obj: T) -> Bool {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

class AddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var AppTable: UITableView!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    
    var test: String = "TEST"  // Holds users name
    
    var AppCount: Int = 0  // Increments and controls distribution of array data to UITable
    
    
    var extra: Int = 0
    
    let prefs = NSUserDefaults.standardUserDefaults()  // Current user preferences
    //    var currentapps: Array = [App]()  // Holds user's selected apps
    //    var Apps: Array = [AnyObject]()  // Holds raw data for AppStore
    var AppStore: [App] = []  // Holds all available Apps
    let synced: SyncNow = SyncNow()
    var AppHeaders: [String] = []  // Holds headers
    var AppNumber: [Int] = [0]  // Holds number of apps in each section
    var sectionOpen: [Bool] =  [false]  // Holds values for which sections are expanded
    
    var flag: Int = 0  // Keeps track of any errors
    
    var baseController = Office365ClientFetcher()
    var serviceEndpointLookup = NSMutableDictionary()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadApps()
        
        AppHeaders = (prefs.arrayForKey("headers") as? [String])!
        print(AppHeaders)
        for _ in AppHeaders
        {
            sectionOpen.append(false)
        }
        
        print(sectionOpen)
        
        AppTable.tableFooterView = UIView(frame: CGRectZero)
        var apps: Int = 0
        var currentApp: String = ""
        for element in synced.AppStore {  // Load app numbers
            if (currentApp == "")
            {
                currentApp = element.header
                apps+=1
                continue
            }
            if (element.header == currentApp)
            {
                apps += 1
                continue
            }
            else
            {
                self.AppNumber.append(self.AppNumber.last! + apps)
                currentApp = element.header
                apps = 1
                continue
            }
        }
        //        print(AppNumber)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func DoneSelected(sender: AnyObject) {  // Done button selected
        //        let appData = NSKeyedArchiver.archivedDataWithRootObject(currentapps)
        //        prefs.setObject(appData, forKey: "userapps")
        //        prefs.synchronize()
        
        let vc : UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Main")
        //vc.setEditing(true, animated: true)
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func addButtonClicked(sender: AnyObject) {  // Add button clicked for an app
        loadApps()
        self.AppTable.reloadData()
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {  // Returns each cell
        //        self.ActivityIndicator.stopAnimating()
        //            loadApps()
        let synced: SyncNow = SyncNow()
        if (indexPath.row == 0)
        {
            extra = 0
        }
        var appCell: App = synced.AppStore[indexPath.row + extra + AppNumber[indexPath.section]]
        while (prefs.arrayForKey("permissions")!.contains(appCell.title) == false)
        {
            extra += 1
            appCell = synced.AppStore[indexPath.row + extra + AppNumber[indexPath.section]]
        }
        
        let cell = self.AppTable.dequeueReusableCellWithIdentifier("AppCell", forIndexPath: indexPath) as! AddTableViewCell
        cell.Title.text = appCell.title
        cell.accessoryType = UITableViewCellAccessoryType.None;
        if let icon = appCell.icon {
            let url = NSURL(string: "https://clydewap.clydeinc.com/images/large/icons/\(icon)")!
            if let data = NSData(contentsOfURL: url){
                if icon != "UNDEFINED" {
                    let myImage = UIImage(data: data)
                    cell.Icon.image = myImage
                } else {
                    cell.Icon.image = UIImage(named: "generic-icon")
                }
            }
            else
            {
                cell.Icon.image = UIImage(named: "generic-icon")
            }
        }
        var found: Bool = false
        for el in synced.currentapps
        {
            if (el.title == appCell.title)
            {
                found = true
                break
            }
        }
        if found {
            cell.addButton.hidden = true
        }
        else
        {
            cell.addButton.hidden = false
        }
        AppCount += 1
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {  // Returns number of cells in each category
        var count: Int = 0
        for el in synced.AppStore
        {
            if (el.header == AppHeaders[section] && prefs.arrayForKey("permissions")!.contains(el.title))
            {
                count += 1
            }
        }
        if (sectionOpen[section] == false)
        {
            count = 0
        }
        
        return count
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        header.textLabel!
            .textColor = UIColor.blackColor()
        header.textLabel!.font = UIFont.boldSystemFontOfSize(20)
        header.textLabel!.frame = header.frame
        header.textLabel!.textAlignment = NSTextAlignment.Center
        header.textLabel!.text = AppHeaders[section]
        let pic = UIImageView()
        pic.frame = CGRectMake(header.frame.width - 40, 10, 25, 25)
        pic.image = UIImage(named: "down-arrow")
        
        let btn = UIButton(type: UIButtonType.Custom) as UIButton
        btn.frame = CGRectMake(0, 0, header.frame.width, header.frame.height)
        btn.addTarget(self, action: #selector(AddViewController.pressed), forControlEvents: .TouchUpInside)
        btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        btn.tag = section
        
        header.addSubview(pic)
        header.addSubview(btn)
        
        
    }
    
    func pressed(sender: UIButton)
    {  // Opens each section
        sectionOpen[sender.tag] = !sectionOpen[sender.tag]
        self.AppTable.reloadData()
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {  // Informs GUI of how many sections there are
        return AppHeaders.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {  // Determine what to do with button press
       
            AppTable.deselectRowAtIndexPath(indexPath, animated: true)
       
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {  // Sets up title and sets username as the title for the home menu
        var uName: String = ""
        if (prefs.stringForKey("username") != nil && prefs.stringForKey("username") != "")
        {
            uName = "Logged in as " + prefs.stringForKey("username")!
        } else {
            uName = "Not logged in"
        }
        
        return uName
    }
    
    func loadApps() {  // Get all apps
        let synced = SyncNow()
        
        AppTable.reloadData()
    }
    
    
    
    func connectToOffice365() {
        // Connect to the service by discovering the service endpoints and authorizing
        // the application to access the user's email. This will store the user's
        // service URLs in a property list to be accessed when calls are made to the
        // service. This results in two calls: one to authenticate, and one to get the
        // URLs. ADAL will cache the access and refresh tokens so you won't need to
        // provide credentials unless you sign out.
        
        // Get the discovery client. First time this is ran you will be prompted
        // to provide your credentials which will authenticate you with the service.
        // The application will get an access token in the response.
        
        baseController.fetchDiscoveryClient { (discoveryClient) -> () in
            let servicesInfoFetcher = discoveryClient.getservices()
            
            // Call the Discovery Service and get back an array of service endpoint information
            
            let servicesTask = servicesInfoFetcher.readWithCallback{(serviceEndPointObjects:[AnyObject]!, error:MSODataException!) -> Void in
                let serviceEndpoints = serviceEndPointObjects as! [MSDiscoveryServiceInfo]
                
                if (serviceEndpoints.count > 0) {
                    // Here is where we cache the service URLs returned by the Discovery Service. You may not
                    // need to call the Discovery Service again until either this cache is removed, or you
                    // get an error that indicates that the endpoint is no longer valid.
                    
                    var serviceEndpointLookup = [NSObject: AnyObject]()
                    
                    for serviceEndpoint in serviceEndpoints {
                        serviceEndpointLookup[serviceEndpoint.capability] = serviceEndpoint.serviceEndpointUri
                    }
                    
                    // Keep track of the service endpoints in the user defaults
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    
                    userDefaults.setObject(serviceEndpointLookup, forKey: "O365ServiceEndpoints")
                    userDefaults.synchronize()
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        let userEmail = userDefaults.stringForKey("LogInUser")!
                        var parts = userEmail.componentsSeparatedByString("@")
                        
                        self.test = String(format:"Hi %@!", parts[0])
                    }
                }
                    
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        NSLog("Error in the authentication: %@", error)
                        let alert: UIAlertView = UIAlertView(title: "Error", message: "Authentication failed. This may be because the Internet connection is offline  or perhaps the credentials are incorrect. Check the log for errors and try again.", delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                    }
                }
            }
            
            servicesTask.resume()
        }
    }
    
    
    
    
}



