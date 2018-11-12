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
    @objc func fadeIn(duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        })
    }
    
    /**
     Fade out a view with a duration
     
     - parameter duration: custom animation duration
     */
    @objc func fadeOut(_ duration: TimeInterval) {
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
    
    @objc var EmployeeInfo: Array<AnyObject> = []  // Holds information about current user
    
    @objc var picLocation: String = ""
    @objc var synced: SyncNow = SyncNow()
    //    var baseController = Office365ClientFetcher()
    @objc var serviceEndpointLookup = NSMutableDictionary()
    
    @objc let prefs = UserDefaults.standard  // Current user preferences
    @objc var flag:Int=0;  // Keeps track of any errors
    @objc var AppStore: [App] = []  // Holds all apps
    @objc var Apps: [AnyObject] = []  // Holds raw data of AppStore
    
    
    
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
            SignOutButton.title = "Log In"
            prefs.set([], forKey: "permissions")
        } else {
            loadUserInfo()
        }
        var lastdate = prefs.object(forKey: "lastsync") as? [String]
        
        let lastsync = "Last Sync: " + lastdate![0] + " " + lastdate![1]
        
        LastSync.text = lastsync
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ClearCacheButton(_ sender: AnyObject) {
        print("Clearing Cache")
        
        let alert = UIAlertController(title: "Clear Cache?", message: "App settings will be reset", preferredStyle: UIAlertController.Style.alert)
        
        
        
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
            
            URLCache.shared.removeAllCachedResponses()
            
            _ = HTTPCookie.self
            let cookieJar = HTTPCookieStorage.shared
            for cookie in cookieJar.cookies! {
                cookieJar.deleteCookie(cookie)
            }
            
            let vc : AnyObject! = self.storyboard!.instantiateViewController(withIdentifier: "Main")
            self.present(vc as! UIViewController, animated: true, completion: nil)
            self.prefs.synchronize()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        
        present(alert, animated: true, completion: nil)
        
        print(URLCache.shared.currentDiskUsage)
        print(URLCache.shared.currentMemoryUsage)
    }
    
    @IBAction func SignOut(_ sender: AnyObject) {  // Sign out button clicked
        
        if (SignOutButton.title == "Sign Out") {
            let alert = UIAlertController(title: "Sign out?", message: "All favorites will be lost.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
                self.prefs.set("", forKey: "username")
                self.prefs.set("", forKey: "fullname")
                self.prefs.set("", forKey: "LogInUser")
                self.prefs.set([], forKey: "userapps")
                self.prefs.set([], forKey: "permissions")
                URLCache.shared.removeAllCachedResponses()
                
                _ = HTTPCookie.self
                let cookieJar = HTTPCookieStorage.shared
                for cookie in cookieJar.cookies! {
                    cookieJar.deleteCookie(cookie)
                }
                
                let vc : AnyObject! = self.storyboard!.instantiateViewController(withIdentifier: "Main")
                self.present(vc as! UIViewController, animated: true, completion: nil)
                self.prefs.synchronize()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            
            present(alert, animated: true, completion: nil)
        }
        if (SignOutButton.title == "Log In") {
            let alert = UIAlertController(title: "Log In", message: "Log in to view apps?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Log In", style: .default, handler: { (action: UIAlertAction!) in
                
                self.SignOutButton.title = "Sign Out"
                
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "Construction")
                
                self.prefs.set("http://clydelink.sharepoint.com/apps", forKey: "selectedButton")
                
                self.show(vc , sender: vc)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: { (action: UIAlertAction!) in
                
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func updateProgressBar(_ notification: Notification)
    {
        DispatchQueue.main.async {
            self.ProgressBar.setProgress(0.1 + self.ProgressBar.progress, animated: true)
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
    
    @objc func loadUserInfo() {  // Get user's information
        
        self.EmployeeInfo = synced.EmployeeInfo
        
        if (self.EmployeeInfo.count != 0) {
            self.userName.text = self.EmployeeInfo[0]["UserName"] as? String
            if (self.userName.text == nil) { self.userName.text = "Unknown User" }
            
            self.JobTitle.text = self.EmployeeInfo[0]["JobTitle"] as? String
            
            self.CompanyName.text = self.EmployeeInfo[0]["CompanyName"] as? String
            
            
            
            if (self.EmployeeInfo[0]["PicLocation"] is NSNull)
            {
                self.UserPicture.image = UIImage(named: "person-generic")
            }
            else
            {
                self.picLocation = (self.EmployeeInfo[0]["PicLocation"] as? String)!
                if let data = try? Data(contentsOf: URL(string: "https://cciportal.clydeinc.com/images/Small/\(self.picLocation)")!)
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
    
}
