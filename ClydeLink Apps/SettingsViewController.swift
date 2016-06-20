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
    
    
    
    let prefs = NSUserDefaults.standardUserDefaults()  // Current user preferences
    var flag:Int=0;
    var AppStore: [App] = []
    var Apps: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            versionNumber.text = version
        }
        if let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            buildNumber.text = build
        }
        var uName: String = "Username"
        if (prefs.stringForKey("username") != nil)
        {
            uName = prefs.stringForKey("username")!
        }
        userName.text = uName
        LastSync.text = prefs.objectForKey("lastsync") as? String
        
        printTimeSince()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SignOut(sender: AnyObject) {
        prefs.setObject("", forKey: "username")
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("Main")
        self.presentViewController(vc as! UIViewController, animated: true, completion: nil)
    }
    
    @IBAction func SyncButton(sender: AnyObject) {
        ActivityIndicator.startAnimating()
        getAppStore()
        let date = NSDate()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        prefs.setObject(dateFormatter.stringFromDate(date) /* + timeFormatter.stringFromDate(date) */, forKey: "lastsync")
        prefs.synchronize()
        printTimeSince()
    }
    
    func printTimeSince()
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let calendar = NSCalendar.autoupdatingCurrentCalendar()
        calendar.timeZone = NSTimeZone.systemTimeZone()
        
        
        //Find out a way to include time too
        
        if let startDate = dateFormatter.dateFromString((prefs.objectForKey("lastsync") as? String)!) {
            let components = calendar.components([ .Month, .Day, .Hour, .Minute ],
                                                 fromDate: startDate, toDate: NSDate(), options: [])
            let months = components.month
            let days = components.day
//            let hours = components.hour
//            let minutes = components.minute
            var text: String = ""
            if (months > 0)
            {
                text += "\(months) months and "
            }
            if (days > 0)
            {
                text += "\(days) days ago"
            } else {
                if (months==0)
                {
                    text += "Just now"
                }
            }
//            if (hours > 0)
//            {
//                text += "\(hours) hours, and "
//            }
//            text += "\(minutes) minutes"
            LastSync.text = text
        }

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
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
