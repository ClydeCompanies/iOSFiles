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
    
    var test: String = "TEST" // Used for receiving username
    
    var Apps: [AnyObject] = []  // Saves list of uncompiled apps, saved as raw data
    var AppStore: [App] = []  // Saves list of all apps
    var flag: Int = 0  // Saves any errors as 1
    
    var appButtons: Array = [App]()  // Holds clickable buttons
    
    var AppCount: Int = 0  // Increments and controls distribution of array data to UITable
    
    let prefs = NSUserDefaults.standardUserDefaults()  // Current user preferences
    var currentapps: Array = [App]()  // Holds currently selected apps
    
    var baseController = Office365ClientFetcher()
    var serviceEndpointLookup = NSMutableDictionary()
    
    override func viewDidLoad() {  // Runs when the view loads
        super.viewDidLoad()
        loadChecked()
        
        test = "TEST"
        
        for element in currentapps
        {
            self.appButtons.append(element)
        }
        
        AppTable.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        AppTable.tableFooterView = UIView(frame: CGRectZero)
        
        print(prefs.boolForKey("launchedBefore"))
        if prefs.boolForKey("launchedBefore") {
            //Not first Launch
        }
        else {
            //Sync
            getAppStore()
        }
        
    }
    
    
    //Sync if first launch
    func getAppStore()
    {
        if let url = NSURL(string: "https://clydewap.clydeinc.com/webservices/json/GetAppsInfo?token=tRuv%5E:%5D56NEn61M5vl3MGf/5A/gU%3C@") {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                guard error == nil && data != nil else {
                    print("error=\(error)")
                    return
                }
                if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 { // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                let mydata = try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) // Creates dictionary array to save results of query
                dispatch_async(dispatch_get_main_queue()) {  // Brings data from background task to main thread, loading data and populating TableView
                    if (mydata == nil)
                    {
                        let alertController = UIAlertController(title: "Error", message:
                            "Could not connect to the server.", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                        return
                    } else {
                        let date = NSDate()
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "MMM d, yyyy"
                        
                        let timeFormatter = NSDateFormatter()
                        timeFormatter.dateFormat = "h:mm"
                        
                        self.prefs.setObject("Last Sync: " + dateFormatter.stringFromDate(date) + " " + timeFormatter.stringFromDate(date), forKey: "lastsync")
                        self.prefs.setBool(true, forKey: "launchedBefore")
                        self.prefs.synchronize()
                    }
                    self.Apps = mydata as! Array<AnyObject>  // Saves the resulting array to Employees Array
                    self.buildAppStore()
                    
                }
            }
            task.resume()  // Reloads Table View cells as results
        }
        self.buildAppStore()
    }
    
    func buildAppStore() {  // Convert raw data into more easily accessible appstore
        AppStore = []
        for element in Apps
        {
            AppStore.append(App(h: (element["Header"] as? String)!,t: (element["Title"] as? String)!,l: (element["Link"] as? String)!,p: (element["Permissions"] as? Int)!,s: (element["Selected"] as? Bool)!,i: (element["Icon"] as? String)!, u: (element["Url"] as? String)!, o: (element["Order"] as? Double)!))
        }
        sortArray()
        updateCurrentApps()
    }
    
    func sortArray() {  // Get accurate order of apps based on "order" from individual apps
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
        let appData = NSKeyedArchiver.archivedDataWithRootObject(sorted)
        prefs.setObject(appData, forKey: "syncedappstore")
        prefs.synchronize()
        
    }
    
    func updateCurrentApps() {  // If any names of apps have changed, or if apps were no longer supported, update the user's library
        if let data = prefs.objectForKey("userapps") as? NSData {
            var currentapps = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [App]
            for el in currentapps
            {
                var found: Bool = false
                for element in AppStore
                {
                    if (el.link == element.link)
                    {
                        el.title = element.title
                        found = true
                        break
                    }
                }
                if (!found)
                {
                    currentapps.removeAtIndex(currentapps.indexOf(el)!)
                }
            }
            let data = NSKeyedArchiver.archivedDataWithRootObject(currentapps)
            prefs.setObject(data, forKey: "userapps")
            prefs.synchronize()
        }
    }

    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // MARK: - AppTable View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {  // Informs GUI of how many sections there are
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 18
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {  // Sets up title and sets username as the title for the home menu
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        userDefaults.setObject(serviceEndpointLookup, forKey: "O365ServiceEndpoints")
        userDefaults.synchronize()
        if userDefaults.stringForKey("LogInUser") != nil {
            let userEmail = userDefaults.stringForKey("LogInUser")!
            var parts = userEmail.componentsSeparatedByString("@")
            
            self.test = String(parts[0])
        }
        
        if let url = NSURL(string: "https://clydewap.clydeinc.com/webservices/json/GetUserProfile?username=\(self.test)&token=tRuv%5E:%5D56NEn61M5vl3MGf/5A/gU%3C@") {  // Sends POST request to the DMZ server, and prints the response string as an array
            
            let request = NSMutableURLRequest(URL: url)
            
            //        request.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding)
            request.HTTPMethod = "POST"
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                guard error == nil && data != nil else { // check for fundamental networking error
                    print("error=\(error)")
                    
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
                        let alertController = UIAlertController(title: "Error", message:
                            "Could not connect to the server.", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        return
                    }
                }
                
            }
            task.resume()
        }
        
        
        if (userDefaults.stringForKey("LogInUser") == nil)
        {
            return "Not logged in"
        }
        else if (self.test != "TEST")
        {
            return "Logged in as " + self.test
        }
        else {
            return "Unrecognized Username"
        }
        
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        header.textLabel!
            .textColor = UIColor.blackColor()
        header.textLabel!.font = UIFont.boldSystemFontOfSize(12)
        header.textLabel!.frame = header.frame
        header.textLabel!.textAlignment = NSTextAlignment.Left
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {  // Returns length of all the buttons needed
        
        return self.appButtons.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {  // Determines which buttons should be header buttons and which chould carry on to other views
        loadChecked()
        
            let cell = self.AppTable.dequeueReusableCellWithIdentifier("AppCell", forIndexPath: indexPath) as! AppTableViewCell
            
            cell.Title.text = self.appButtons[indexPath.row].title
            if let icon = appButtons[indexPath.row].icon {
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
            return cell
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {  // Delete the selected app
        if editingStyle == .Delete {
            for element in currentapps
            {
                if (element.title == appButtons[indexPath.row].title)
                {
                    currentapps.removeAtIndex(currentapps.indexOf(element)!)
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
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {  // All apps are moveable
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {  // Move apps within table
        let itemToMove = appButtons[fromIndexPath.row]
        appButtons.removeAtIndex(fromIndexPath.row)
        appButtons.insert(itemToMove, atIndex: toIndexPath.row)
//        currentapps.removeAtIndex(fromIndexPath.row)
//        currentapps.insert(itemToMove, atIndex: toIndexPath.row)
        var fromindex: Int = 0
        for element in currentapps
        {
            if (element.title == itemToMove.title) {
                fromindex = currentapps.indexOf(element)!
            }
        }
        
        var toindex: Int = 0
        var change: Int = 0
        
        if (toIndexPath.row > fromIndexPath.row)
        {
            //Down
            change = 1
        } else if (toIndexPath.row < fromIndexPath.row){
            //Up
            change = -1
        } else {
            change = 0
        }
        
        
        for element in currentapps
        {
            if (element.title == appButtons[fromIndexPath.row + change].title) {
                toindex = currentapps.indexOf(element)!
            }
        }
        currentapps.removeAtIndex(fromindex)
        if (toindex + change >= currentapps.count)
        {
            change = 0
        }
        if (toindex + change < 0)
        {
            change = 0
        }
        currentapps.insert(itemToMove, atIndex: toindex + change)
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
        
        //Log in
        connectToOffice365()
        
        
        if (prefs.stringForKey("LogInUser") != nil)
        {
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
        
    }
    
    @IBAction func editTable(sender: AnyObject) {  // Edit button pressed
        if (leftButton.title == "Edit")
        {
            AppTable.setEditing(true,animated: true)
            leftButton.title = "All"
            rightButton.title = "Done"
        } else {
            let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("All")
            self.presentViewController(vc as! UIViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func settingsButton(sender: AnyObject) {  // Settings button pressed
        if (rightButton.title == "Done")
        {
            AppTable.setEditing(false,animated: true)
            leftButton.title = "Edit"
            rightButton.title = "Settings"
        }
        else {
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("Settings")
        self.presentViewController(vc as! UIViewController, animated: true, completion: nil)
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
        sortarray(&currentapps)
    }
    
    func fillAppArray(inout currentapps: [App])
    {
        currentapps = []
        //Convert function
        let appData = NSKeyedArchiver.archivedDataWithRootObject(currentapps)
        prefs.setObject(appData, forKey: "userapps")
        prefs.synchronize()
    }
    func sortarray(inout currentapps: [App])
    {
        for element in currentapps
        {
            if (!element.selected)
            {
                currentapps.removeAtIndex(currentapps.indexOf(element)!)
                currentapps.append(element)
            }
        }
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

    
    
    
//    let url = NSURL(string: "mspbi://")
//    UIApplication.sharedApplication().openURL(url)
//    else if let itunesUrl = NSURL(string: "https://itunes.apple.com/itunes-link-to-app") where UIApplication.sharedApplication().canOpenURL(itunesUrl)
//    {
//        UIApplication.sharedApplication().openURL(itunesUrl)
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
