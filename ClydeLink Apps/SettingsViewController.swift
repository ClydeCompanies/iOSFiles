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
    func fadeIn(duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        })
    }
    
    /**
     Fade out a view with a duration
     
     - parameter duration: custom animation duration
     */
    func fadeOut(_ duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: {
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
    
    let prefs = UserDefaults.standard  // Current user preferences
    var flag:Int=0;  // Keeps track of any errors
    var AppStore: [App] = []  // Holds all apps
    var Apps: [AnyObject] = []  // Holds raw data of AppStore
    
    
    
    override func viewDidLoad() {  // Runs when view loads
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector:#selector(SettingsViewController.updateProgressBar/*(_:)*/), name: NSNotification.Name(rawValue: "TEST"), object: nil)
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionNumber.text = "Version: " + version  // Version number as found in project info
        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildNumber.text = "Build: " + build  // Build Number as found in project info
        }
        ProgressBar.progress = 0.0
        if (prefs.string(forKey: "username") == "")
        {
            userName.text = "Not logged in"
            JobTitle.text = ""
            CompanyName.text = ""
            SignOutButton.title = "Clear Cache"
            prefs.set([], forKey: "permissions")
        }
        var lastdate = prefs.object(forKey: "lastsync") as? [String]
        
        let lastsync = "Last Sync: " + lastdate![0] + " " + lastdate![1]
        
        LastSync.text = lastsync
        
        
        loadUserInfo()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SignOut(_ sender: AnyObject) {  // Sign out button clicked
        if (SignOutButton.title == "Clear Cache")
        {
            let alert = UIAlertController(title: "Clear Cache?", message: "App settings will be reset", preferredStyle: UIAlertControllerStyle.alert)
            
            
            
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
                self.prefs.set("", forKey: "username")
                self.prefs.set("", forKey: "LogInUser")
                self.prefs.set([], forKey: "userapps")
                self.prefs.set([], forKey: "permissions")
                
                let authenticationManager:AuthenticationManager = AuthenticationManager.sharedInstance
                authenticationManager.clearCredentials()
                
                _ = HTTPCookie.self
                let cookieJar = HTTPCookieStorage.shared
                for cookie in cookieJar.cookies! {
                    // print(cookie.name+"="+cookie.value)
                    cookieJar.deleteCookie(cookie)
                }
                
                let vc : AnyObject! = self.storyboard!.instantiateViewController(withIdentifier: "Main")
                self.present(vc as! UIViewController, animated: true, completion: nil)
                self.prefs.synchronize()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                //            print("Phew!")
            }))
            
            
            present(alert, animated: true, completion: nil)
        }
        
        
        else {
            let alert = UIAlertController(title: "Sign out?", message: "All favorites will be lost.", preferredStyle: UIAlertControllerStyle.alert)
            
            
            
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
                self.prefs.set("", forKey: "username")
                self.prefs.set("", forKey: "LogInUser")
                self.prefs.set([], forKey: "userapps")
                self.prefs.set([], forKey: "permissions")
                
                let authenticationManager:AuthenticationManager = AuthenticationManager.sharedInstance
                authenticationManager.clearCredentials()
                
                _ = HTTPCookie.self
                let cookieJar = HTTPCookieStorage.shared
                for cookie in cookieJar.cookies! {
                    // print(cookie.name+"="+cookie.value)
                    cookieJar.deleteCookie(cookie)
                }
                
                let vc : AnyObject! = self.storyboard!.instantiateViewController(withIdentifier: "Main")
                self.present(vc as! UIViewController, animated: true, completion: nil)
                self.prefs.synchronize()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
    //            print("Phew!")
            }))
            
            
            present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    func updateProgressBar(_ notification: Notification)
    {
        DispatchQueue.main.async {
            self.ProgressBar.setProgress(/*(notification.userInfo!.first?.1 as? Float)!*/ 0.1 + self.ProgressBar.progress, animated: true)
        }
    }
    
    @IBAction func SyncButton(_ sender: AnyObject) {  // Sync button clicked
        ProgressBar.setProgress(0.0, animated: false)
        ActivityIndicator.startAnimating()
        
        ProgressBar.alpha = 1
        ProgressBar.isHidden = false
        synced = SyncNow(sync: 1, complete: {
            DispatchQueue.main.async {
                self.ActivityIndicator.stopAnimating()
                
                var lastdate = self.prefs.object(forKey: "lastsync") as? [String]
                
                let lastsync = "Last Sync: " + lastdate![0] + " " + lastdate![1]
                
                self.LastSync.text = lastsync
                
                
                self.ProgressBar.setProgress(1, animated: true)
                self.ProgressBar.fadeOut(3.0)
                
            }
        })
        
    }

    func loadUserInfo() {  // Get user's information
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(serviceEndpointLookup, forKey: "O365ServiceEndpoints")
        userDefaults.synchronize()
        
        
        
        if ((prefs.string(forKey: "username")) == "") {
            self.flag = 1
            DispatchQueue.global().async {
                let alertController = UIAlertController(title: "Error", message:
                    "No user logged in", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
            
            return
        }
        
        if let userEmail = userDefaults.string(forKey: "username") {
            var parts = userEmail.components(separatedBy: "@")
            
            let uName: String = String(format:"%@", parts[0])
            
            if let url = URL(string: "https://webservices.clydeinc.com/ClydeRestServices.svc/json/ClydeWebServices/GetUserProfile?username=\(uName)&token=tRuv%5E:%5D56NEn61M5vl3MGf/5A/gU%3C@") {  // Sends POST request to the DMZ server, and prints the response string as an array
                
                let request = NSMutableURLRequest(url: url)
                
                //        request.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding)
                request.httpMethod = "POST"
                let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                    guard error == nil && data != nil else { // check for fundamental networking error
                        print("error=\(error)")
                        self.flag = 1
                        
                        let alertController = UIAlertController(title: "Error", message:
                            "Could not connect to the server.", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                        
                        
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 { // check for http errors
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(response)")
                    }
                    
                    let mydata = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) // Creates dictionary array to save results of query
                    
                    print(" My Data: ")
                    print("*********************")
                    print(mydata)  // Direct response from server printed to console, for testing
                    print("*********************")
                    DispatchQueue.main.async {  // Brings data from background task to main thread, loading data and populating TableView
                        if (mydata == nil || mydata is NSNull)
                        {
                            //                        self.activityIndicator.stopAnimating()  // Ends spinner
                            //                        self.activityIndicator.hidden = true
                            self.flag = 1
                            
                            let alertController = UIAlertController(title: "Error", message:
                                "Could not get info from the the server.", preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                            
                            self.present(alertController, animated: true, completion: nil)
                            
                            return
                        }
                        
                        self.EmployeeInfo = mydata as! Array<AnyObject>  // Saves the resulting array to Employee Info Array
                        let employeedata = NSKeyedArchiver.archivedData(withRootObject: self.EmployeeInfo)
                        self.prefs.set(employeedata, forKey: "userinfo")
                        
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
                        
                        
                        
                        
                        
                        print(self.prefs.array(forKey: "permissions"))
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
                            self.prefs.set(permissions, forKey: "permissions")
                            
                            print(self.prefs.array(forKey: "permissions"))
                        } else {
                            self.prefs.set([],forKey: "permissions")
                        }
                        
                        
                        
                        if (self.EmployeeInfo[0]["PicLocation"] is NSNull)
                        {
                            self.UserPicture.image = UIImage(named: "person-generic")
                        }
                        else
                        {
                            self.picLocation = (self.EmployeeInfo[0]["PicLocation"] as? String)!
                            if let data = try? Data(contentsOf: URL(string: "https://clydewap.clydeinc.com/images/Small/\(self.picLocation)")!)
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
                    
                }) 
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
