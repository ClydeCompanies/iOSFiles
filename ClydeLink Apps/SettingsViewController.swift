//
//  SettingsViewController.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 5/16/16.
//

import UIKit

class SettingsViewController: UIViewController {  // Basics of Settings screen, will be added to when decision has been made as to how we must proceed with the development of the screen

    @IBOutlet weak var versionNumber: UILabel!
    @IBOutlet weak var buildNumber: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var LastSync: UILabel!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var CompanyName: UILabel!
    @IBOutlet weak var JobTitle: UILabel!
    @IBOutlet weak var UserPicture: UIImageView!
    
    var EmployeeInfo: Array<AnyObject> = []  // Holds information about current user
    
    var baseController = Office365ClientFetcher()
    var serviceEndpointLookup = NSMutableDictionary()
    
    let prefs = NSUserDefaults.standardUserDefaults()  // Current user preferences
    var flag:Int=0;  // Keeps track of any errors
    var AppStore: [App] = []  // Holds all apps
    var Apps: [AnyObject] = []  // Holds raw data of AppStore
    
    override func viewDidLoad() {  // Runs when view loads
        super.viewDidLoad()
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            versionNumber.text = "Version: " + version  // Version number as found in project info
        }
        if let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            buildNumber.text = "Build: " + build  // Build Number as found in project info
        }
//        var uName: String = "Username"
//        if (prefs.stringForKey("username") != nil)
//        {
//            uName = prefs.stringForKey("username")!
//        }
//        userName.text = uName
        let lastsync = prefs.objectForKey("lastsync") as? String
        if (lastsync != nil)
        {
            LastSync.text = lastsync
        }
        
        loadUserInfo()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SignOut(sender: AnyObject) {  // Sign out button clicked
        prefs.setObject(nil, forKey: "username")
        prefs.setObject(nil, forKey: "LogInUser")
        let authenticationManager:AuthenticationManager = AuthenticationManager.sharedInstance
        authenticationManager.clearCredentials()
        
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("Main")
        self.presentViewController(vc as! UIViewController, animated: true, completion: nil)
        prefs.synchronize()
        
    }
    
    @IBAction func SyncButton(sender: AnyObject) {  // Sync button clicked
        ActivityIndicator.startAnimating()
        
        flag = 0
        
        getAppStore()
        
        
    }
    
    func getAppStore()
    {  // Load apps from online database
        
        if let url = NSURL(string: "https://clydewap.clydeinc.com/webservices/json/GetAppsInfo?token=tRuv%5E:%5D56NEn61M5vl3MGf/5A/gU%3C@") {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                guard error == nil && data != nil else {
                    print("error=\(error)")
                    self.flag = 1
                    return
                }
                if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 { // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                    self.flag = 1
                }
                let mydata = try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) // Creates dictionary array to save results of query
                dispatch_async(dispatch_get_main_queue()) {  // Brings data from background task to main thread, loading data and populating TableView
                    if (mydata == nil)
                    {
                        let alertController = UIAlertController(title: "Error", message:
                            "Could not connect to the server.", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                        self.flag = 1
                        self.presentViewController(alertController, animated: true, completion: nil)
                        return
                    } else {
                        let date = NSDate()
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "MMM d, yyyy"
                        
                        let timeFormatter = NSDateFormatter()
                        timeFormatter.dateFormat = "h:mm"
                        if (self.flag == 0)
                        {
                            self.prefs.setObject("Last Sync: " + dateFormatter.stringFromDate(date) + " " + timeFormatter.stringFromDate(date), forKey: "lastsync")
                            self.prefs.synchronize()
                            self.LastSync.text = self.prefs.objectForKey("lastsync") as? String
                        }
                    }
                    self.Apps = mydata as! Array<AnyObject>  // Saves the resulting array to Employees Array
                    self.buildAppStore()
                    self.ActivityIndicator.stopAnimating()
                }
            }
            task.resume()  // Reloads Table View cells as results
        }
        self.buildAppStore()
    }
    
    func buildAppStore() {  // Convert raw data into more accessible AppStore
        AppStore = []
        for element in Apps
        {
            AppStore.append(App(h: (element["Header"] as? String)!,t: (element["Title"] as? String)!,l: (element["Link"] as? String)!,p: (element["Permissions"] as? Int)!,s: (element["Selected"] as? Bool)!,i: (element["Icon"] as? String)!, u: (element["Url"] as? String)!, o: (element["Order"] as? Double)!))
        }
        sortArray()
    }
    
    func sortArray()
    {  // Sort array based on individual apps' "order" property
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
        if (AppStore != []) {
            updateCurrentApps()
        }
    }
    
    func updateCurrentApps()
    {  // Updates the user's selected apps due to changes in online database
        
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
                    print("Uh oh")
                    print("AppStore:")
                    print(AppStore)
                    currentapps.removeAtIndex(currentapps.indexOf(el)!)
                }
            }
            let data = NSKeyedArchiver.archivedDataWithRootObject(currentapps)
            prefs.setObject(data, forKey: "userapps")
            prefs.synchronize()
        }
        
    }
    
    func loadUserInfo() {  // Get user's information
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        userDefaults.setObject(serviceEndpointLookup, forKey: "O365ServiceEndpoints")
        userDefaults.synchronize()
        
        let userEmail = userDefaults.stringForKey("LogInUser")!
        var parts = userEmail.componentsSeparatedByString("@")
        
        let uName: String = String(format:"%@", parts[0])
        
        if let url = NSURL(string: "https://clydewap.clydeinc.com/webservices/json/GetUserProfile?username=\(uName)&token=tRuv%5E:%5D56NEn61M5vl3MGf/5A/gU%3C@") {  // Sends POST request to the DMZ server, and prints the response string as an array
            
            let request = NSMutableURLRequest(URL: url)
            
            //        request.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding)
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
                
                print(" My Data: ")
                print(mydata)  // Direct response from server printed to console, for testing
                
                dispatch_async(dispatch_get_main_queue()) {  // Brings data from background task to main thread, loading data and populating TableView
                    if (mydata == nil)
                    {
                        //                        self.activityIndicator.stopAnimating()  // Ends spinner
                        //                        self.activityIndicator.hidden = true
                        self.flag = 1
                        
                        let alertController = UIAlertController(title: "Error", message:
                            "Could not connect to the server.", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        return
                    }
                    
                    self.EmployeeInfo = mydata as! Array<AnyObject>  // Saves the resulting array to Employee Info Array
                    let employeedata = NSKeyedArchiver.archivedDataWithRootObject(self.EmployeeInfo)
                    self.prefs.setObject(employeedata, forKey: "userinfo")
                    
                    //CompanyName
                    //CompanyNumber
                    //JobTitle
                    //PicLocation
                    //UserName
                    self.userName.text = self.EmployeeInfo[0]["UserName"] as? String
                    self.JobTitle.text = self.EmployeeInfo[0]["JobTitle"] as? String
                    self.CompanyName.text = self.EmployeeInfo[0]["CompanyName"] as? String
                    
                    if let data = NSData(contentsOfURL: NSURL(string: "\(self.EmployeeInfo[0]["PicLocation"] as? String)")!){
                        let myImage = UIImage(data: data)
                        self.UserPicture.image = myImage
                    }
                    else
                    {
                        self.UserPicture.image = UIImage(named: "person-generic")
                    }
                    
                }
                
            }
            task.resume()
            
            
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
