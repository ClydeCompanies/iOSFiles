//
//  SyncNow.swift
//  ClydeLink Apps
//
//  Created by JFed on 7/5/16.
//  Copyright © 2016 XLR8 Development LLC. All rights reserved.
//

import UIKit

class SyncNow: NSObject {
    
    var flag: Int = 0
    let prefs = NSUserDefaults.standardUserDefaults()
    var Apps: [AnyObject] = []
    var AppStore: [App] = []
    var currentapps: [App] = []
    var syncnow: Int = 0
    var done: Int = 0
    
    init(sync: Int) {
        super.init()
        done = 0
        flag = 0
        getAppStore(sync)
    }
    
    func getAppStore(sync: Int)
    {  // Load apps from online database
        syncnow = sync
        if let data = prefs.objectForKey("syncedappstore") as? NSData {
            AppStore = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [App]
            sortArray()
            if (AppStore.count == 0)
            {
                fillAppArray(syncnow)
            } else {
                
            }
        } else {
            fillAppArray(syncnow)
        }
        if let data = prefs.objectForKey("userapps") as? NSData {
            currentapps = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [App]
            done = 1
        } else {
            currentapps = []
        }
        
    }
    func fillAppArray(sync: Int) {
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
                        self.flag = 1
                        return
                    } else {
                        
                        //If
                    }
                    self.Apps = mydata as! Array<AnyObject>  // Saves the resulting array to Employees Array
                    self.buildAppStore()
                }
            }
            
            self.buildAppStore()
            task.resume()  // Reloads Table View cells as results
        }
        
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
        AppStore = sorted
        prefs.setObject(appData, forKey: "syncedappstore")
        prefs.synchronize()
        if (AppStore != []) {
            updateCurrentApps()
        } else {
            done = 1
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
                        print("Found")
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
        let date = NSDate()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "h:mm"
        if (self.flag == 0 && syncnow == 1)
        {
            self.prefs.setObject("Last Sync: " + dateFormatter.stringFromDate(date) + " " + timeFormatter.stringFromDate(date), forKey: "lastsync")
            self.prefs.synchronize()
        }
        done = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
    }

}
