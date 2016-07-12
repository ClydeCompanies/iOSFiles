//
//  SettingsViewController.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 5/16/16.
//

import UIKit

public extension UIView {
    
    /**
     Fade in a view with a duration
     
     - parameter duration: custom animation duration
     */
    func fadeIn(duration duration: NSTimeInterval) {
        UIView.animateWithDuration(duration, animations: {
            self.alpha = 1.0
        })
    }
    
    /**
     Fade out a view with a duration
     
     - parameter duration: custom animation duration
     */
    func fadeOut(duration: NSTimeInterval) {
        UIView.animateWithDuration(duration, animations: {
            self.alpha = 0.0
        })
    }
    
}
class SettingsViewController: UIViewController {  // Basics of Settings screen, will be added to when decision has been made as to how we must proceed with the development of the screen

    @IBOutlet weak var SignOutButton: UIBarButtonItem!
    @IBOutlet weak var ProgressBar: UIProgressView!
    @IBOutlet weak var versionNumber: UILabel!
    @IBOutlet weak var buildNumber: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var LastSync: UILabel!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var CompanyName: UILabel!
    @IBOutlet weak var JobTitle: UILabel!
    @IBOutlet weak var UserPicture: UIImageView!
    
    var EmployeeInfo: Array<AnyObject> = []  // Holds information about current user
    
    var picLocation: String = ""
    var synced: SyncNow = SyncNow()
    var baseController = Office365ClientFetcher()
    var serviceEndpointLookup = NSMutableDictionary()
    
    let prefs = NSUserDefaults.standardUserDefaults()  // Current user preferences
    var flag:Int=0;  // Keeps track of any errors
    var AppStore: [App] = []  // Holds all apps
    var Apps: [AnyObject] = []  // Holds raw data of AppStore
    
    
    
    override func viewDidLoad() {  // Runs when view loads
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(SettingsViewController.updateProgressBar/*(_:)*/), name: "TEST", object: nil)
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            versionNumber.text = "Version: " + version  // Version number as found in project info
        }
        if let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            buildNumber.text = "Build: " + build  // Build Number as found in project info
        }
        ProgressBar.progress = 0.0
        if (prefs.stringForKey("username") == "")
        {
            userName.text = "Not logged in"
            JobTitle.text = ""
            CompanyName.text = ""
            SignOutButton.enabled = false
            prefs.setObject([], forKey: "permissions")
        }
        var lastdate = prefs.objectForKey("lastsync") as? [String]
        
        let lastsync = "Last Sync: " + lastdate![0] + " " + lastdate![1]
        
        LastSync.text = lastsync
        
        
        loadUserInfo()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SignOut(sender: AnyObject) {  // Sign out button clicked
        let alert = UIAlertController(title: "Sign out?", message: "All favorites will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
        
        
        
        alert.addAction(UIAlertAction(title: "Confirm", style: .Default, handler: { (action: UIAlertAction!) in
            self.prefs.setObject("", forKey: "username")
            self.prefs.setObject("", forKey: "LogInUser")
            self.prefs.setObject([], forKey: "userapps")
            self.prefs.setObject([], forKey: "permissions")
            let authenticationManager:AuthenticationManager = AuthenticationManager.sharedInstance
            authenticationManager.clearCredentials()
            
            let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("Main")
            self.presentViewController(vc as! UIViewController, animated: true, completion: nil)
            self.prefs.synchronize()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
            print("Phew!")
        }))
        
        
        presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    func updateProgressBar(notification: NSNotification)
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.ProgressBar.setProgress(/*(notification.userInfo!.first?.1 as? Float)!*/ 0.1 + self.ProgressBar.progress, animated: true)
        }
    }
    
    @IBAction func SyncButton(sender: AnyObject) {  // Sync button clicked
        ProgressBar.setProgress(0.0, animated: false)
        ActivityIndicator.startAnimating()
        
        ProgressBar.alpha = 1
        ProgressBar.hidden = false
        synced = SyncNow(sync: 1, complete: {
            dispatch_async(dispatch_get_main_queue()) {
                self.ActivityIndicator.stopAnimating()
                
                var lastdate = self.prefs.objectForKey("lastsync") as? [String]
                
                let lastsync = "Last Sync: " + lastdate![0] + " " + lastdate![1]
                
                self.LastSync.text = lastsync
                
                
                self.ProgressBar.setProgress(1, animated: true)
                self.ProgressBar.fadeOut(3.0)
                
            }
        })
        
    }

    func loadUserInfo() {  // Get user's information
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        userDefaults.setObject(serviceEndpointLookup, forKey: "O365ServiceEndpoints")
        userDefaults.synchronize()
        
        if let userEmail = userDefaults.stringForKey("username") {
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
                        if (self.userName.text == nil) { self.userName.text = "Unknown User" }
                        
                        self.JobTitle.text = self.EmployeeInfo[0]["JobTitle"] as? String
//                        if (self.JobTitle.text == "") { self.JobTitle.text = "n/a" }
                        
                        self.CompanyName.text = self.EmployeeInfo[0]["CompanyName"] as? String
//                        if (self.CompanyName.text == "") { self.CompanyName.text = "n/a" }
                        
                        
                        
                        
                        
                        print(self.prefs.arrayForKey("permissions"))
                        self.prefs.synchronize()
                        var permissions: [String] = []
                        if (!(self.EmployeeInfo[0]["Permissions"] is NSNull)) {
                            let rawpermissions = self.EmployeeInfo[0]["Permissions"] as! Array<AnyObject>
                            if (!(rawpermissions is [String])) {
                                for permission in rawpermissions {
                                    print(permission)
                                    permissions.append((permission["Group"]) as! String)
                                }
                            }
                            self.prefs.setObject(permissions, forKey: "permissions")
                            
                            print(self.prefs.arrayForKey("permissions"))
                        } else {
                            self.prefs.setObject([],forKey: "permissions")
                        }
                        
                        
                        
                        if (self.EmployeeInfo[0]["PicLocation"] is NSNull)
                        {
                            self.UserPicture.image = UIImage(named: "person-generic")
                        }
                        else
                        {
                            self.picLocation = (self.EmployeeInfo[0]["PicLocation"] as? String)!
                            if let data = NSData(contentsOfURL: NSURL(string: "https://clydewap.clydeinc.com/images/Small/\(self.picLocation)")!)
                            {
                                let myImage = UIImage(data: data)
                                self.UserPicture.image = myImage
                            }
                            else
                            {
                                self.UserPicture.image = UIImage(named: "person-generic")
                            }
                        }
                        
                    }
                    
                }
                task.resume()
            }
            
            
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
    
    
    /*      ****CHECK IF USER IS USING IPAD****
     if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
     /* do something specifically for iPad. */
     } else {
     /* do something specifically for iPhone or iPod touch. */
     }
    */

}
