//
//  AddViewController.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 6/5/16.
//

import UIKit

class AddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var AppTable: UITableView!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    
    var test: String = "TEST"
    
    var AppCount: Int = 0  // Increments and controls distribution of array data to UITable
    
    let prefs = NSUserDefaults.standardUserDefaults()  // Current user preferences
    var currentapps: Array = [App]()
    var Apps: Array = [AnyObject]()
    var AppStore: [App] = []
    var AppHeaders: [String] = ["Accounting and Credit", "Employee", "Equipment", "Human Resources"]
    var AppNumber: [Int] = [0,0,0,0,0]
    var sectionOpen: [Bool] =  [false,false,false,false,false]
    
    var flag: Int = 0
    
    var baseController = Office365ClientFetcher()
    var serviceEndpointLookup = NSMutableDictionary()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadApps()
        // Do any additional setup after loading the view.
        
        AppTable.tableFooterView = UIView(frame: CGRectZero)
        var apps: Int = 0
        var currentApp: String = ""
        for element in AppStore {
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
                self.AppNumber[Int(floor(element.order)) - 1] = apps + AppNumber[Int(floor(element.order)) - 2]
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
    
    
    @IBAction func DoneSelected(sender: AnyObject) {
//        let appData = NSKeyedArchiver.archivedDataWithRootObject(currentapps)
//        prefs.setObject(appData, forKey: "userapps")
//        prefs.synchronize()

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
//        self.ActivityIndicator.stopAnimating()
//            loadApps()
            let cell = self.AppTable.dequeueReusableCellWithIdentifier("AppCell", forIndexPath: indexPath) as! AddTableViewCell
            cell.Title.text = self.AppStore[indexPath.row + AppNumber[indexPath.section]].title
            cell.accessoryType = UITableViewCellAccessoryType.None;
            if let icon = AppStore[indexPath.row + AppNumber[indexPath.section]].icon as? String{
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
            for el in currentapps
            {
                if (el.title == AppStore[indexPath.row + AppNumber[indexPath.section]].title)
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int = 0
        for el in AppStore
        {
            if (el.header == AppHeaders[section])
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
    {
        sectionOpen[sender.tag] = !sectionOpen[sender.tag]
        self.AppTable.reloadData()
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {  // Informs GUI of how many sections there are
        return 4
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {  // Determine what to do with button press
        let buttonpressed = self.AppStore[indexPath.row]
        var vc : AnyObject! = nil
        
//        Log In
        connectToOffice365()
        
        switch (buttonpressed.link)
        {
        case "vehiclesearch":
            vc = self.storyboard!.instantiateViewControllerWithIdentifier("Truck Search")
            break;
        default:
            vc = self.storyboard!.instantiateViewControllerWithIdentifier("Construction")
            break;
        }
        
        prefs.setObject(buttonpressed.URL, forKey: "selectedButton")
        
        self.showViewController(vc as! UIViewController, sender: vc)
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
    
    func loadApps() {
        if (AppStore.count == 0) {
            if let data = prefs.objectForKey("syncedappstore") as? NSData {
                AppStore = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [App]
                sortArray()
                if (AppStore.count == 0)
                {
                    fillAppArray()
                }
                AppTable.reloadData()
            } else {
                fillAppArray()
            }
        }
        if let data = prefs.objectForKey("userapps") as? NSData {
            currentapps = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [App]
        } else {
            currentapps = []
        }
    }
    
    func fillAppArray()
    {
        if let url = NSURL(string: "https://clydewap.clydeinc.com/webservices/json/GetAppsInfo?token=tRuv%5E:%5D56NEn61M5vl3MGf/5A/gU%3C@") {  // Sends POST request to the DMZ server, and prints the response string as an array
            
            let request = NSMutableURLRequest(URL: url)
            
            request.HTTPMethod = "POST"
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                guard error == nil && data != nil else { // check for fundamental networking error
                    print("error=\(error)")
                    self.flag = 1
                    
                    let alertController = UIAlertController(title: "Error", message:
                        "Could not connect to the server.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                    return
                }
                
                if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 { // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                let mydata = try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) // Creates dictionary array to save results of query
                
                print(mydata)  // Direct response from server printed to console, for testing
                
                dispatch_async(dispatch_get_main_queue()) {  // Brings data from background task to main thread, loading data and populating TableView
                    if (mydata == nil)
                    {
                        self.flag = 1
                        self.AppTable.reloadData()
                        
                        let alertController = UIAlertController(title: "Error", message:
                            "Could not connect to the server.", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                        return
                    }
                    self.Apps = mydata as! Array<AnyObject>  // Saves the resulting array to Employees Array
                    self.buildAppStore()
                    self.AppTable.reloadData()
                }
            }
            task.resume()  // Reloads Table View cells as results
        }
        self.buildAppStore()
        AppTable.reloadData()
    }
    
    func buildAppStore() {
        AppStore = []
        for element in Apps
        {
            AppStore.append(App(h: (element["Header"] as? String)!,t: (element["Title"] as? String)!,l: (element["Link"] as? String)!,p: (element["Permissions"] as? Int)!,s: (element["Selected"] as? Bool)!,i: (element["Icon"] as? String)!, u: (element["Url"] as? String)!, o: (element["Order"] as? Double)!))
        }
        sortArray()
    }
    func sortArray()
    {
//        print("Unsorted")
//        for el in AppStore
//        {
//            print(el.title + ", " + String(el.order))
//        }
        var sorted: [App] = []
        for _ in AppStore
        {
            var min: App = App(h: "1", t: "1", l: "1", p: 1, s: true, i: "1", u: "1", o: 99)
            for el in AppStore
            {
                if (el.order < min.order)
                {
                    min = el
                }
            }
            sorted.append(min)
            AppStore.removeAtIndex(AppStore.indexOf(min)!)
        }
        AppStore = sorted
//        print("\nSorted")
//        for el in AppStore
//        {
//            print(el.title + ", " + String(el.order))
//        }
        let appData = NSKeyedArchiver.archivedDataWithRootObject(AppStore)
        prefs.setObject(appData, forKey: "syncedappstore")
        prefs.synchronize()
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
                        //                    self.headerLabel.hidden = false
                        //                    self.mainContentTextView.hidden = false
                        //                    self.emailTextField.text = userEmail
                        //                    self.statusTextView.text = ""
                        //                    self.disconnectButton.enabled = true
                        //                    self.sendMailButton.hidden = false
                        //                    self.emailTextField.hidden = false
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



