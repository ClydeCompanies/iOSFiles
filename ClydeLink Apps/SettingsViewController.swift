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
    
    var EmployeeInfo: Array<AnyObject> = []
    
    var baseController = Office365ClientFetcher()
    var serviceEndpointLookup = NSMutableDictionary()
    
    let prefs = NSUserDefaults.standardUserDefaults()  // Current user preferences
    var flag:Int=0;
    var AppStore: [App] = []
    var Apps: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            versionNumber.text = "Version: " + version
        }
        if let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            buildNumber.text = "Build: " + build
        }
        var uName: String = "Username"
        if (prefs.stringForKey("username") != nil)
        {
            uName = prefs.stringForKey("username")!
        }
        userName.text = uName
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
    
    @IBAction func SignOut(sender: AnyObject) {
        prefs.setObject("", forKey: "username")
        let authenticationManager:AuthenticationManager = AuthenticationManager.sharedInstance
        authenticationManager.clearCredentials()
        
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("Main")
        self.presentViewController(vc as! UIViewController, animated: true, completion: nil)
        
        
    }
    
    @IBAction func SyncButton(sender: AnyObject) {
        ActivityIndicator.startAnimating()
        getAppStore()
        let date = NSDate()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "h:mm"
        
        prefs.setObject("Last Sync: " + dateFormatter.stringFromDate(date) + " " + timeFormatter.stringFromDate(date), forKey: "lastsync")
        prefs.synchronize()
        LastSync.text = prefs.objectForKey("lastsync") as? String
    }
    
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
    
    func buildAppStore() {
        AppStore = []
        for element in Apps
        {
            AppStore.append(App(h: (element["Header"] as? String)!,t: (element["Title"] as? String)!,l: (element["Link"] as? String)!,p: (element["Permissions"] as? Int)!,s: (element["Selected"] as? Bool)!,i: (element["Icon"] as? String)!, u: (element["Url"] as? String)!, o: (element["Order"] as? Double)!))
        }
        sortArray()
        updateCurrentApps()
    }
    
    func sortArray()
    {
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
    
    func updateCurrentApps()
    {
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
    
    func loadUserInfo() {
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
