//
//  SyncNow.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 6/5/16.
//

import UIKit

class SyncNow: NSObject {
    
    var flag: Int = 0
    let prefs = NSUserDefaults.standardUserDefaults()
    var Apps: [AnyObject] = []
    var AppStore: [App] = []
    var currentapps: [App] = []
    var done: Int = 0
    var syncnow: Int = 0
    var AppHeaders: [String] = []
    
    override init() {
        super.init()
        syncnow = 0
        done = 0
        flag = 0
        getAppStore({
            self.buildAppStore({
                self.sortArray({
                    self.updateCurrentApps({
                        return
                    })
                })
            })
        })
    }
    init(sync: Int, complete: () -> Void) {
        super.init()
        syncnow = 1
        done = 0
        flag = 0
        fillAppArray({
            self.buildAppStore({
                self.sortArray({
                    self.updateCurrentApps({
                        complete()
                    })
                })
            })
        })
        
    }
    
    func getAppStore(complete: () -> Void)
    {  // Load apps from online database
        var success: Bool = false
        if let data = prefs.objectForKey("syncedappstore") as? NSData {
            AppStore = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [App]
            sortArray({
                self.updateCurrentApps({
                    return
                })
            })
            if (AppStore.count == 0)
            {
                fillAppArray({
                    self.buildAppStore({
                        self.sortArray({
                            self.updateCurrentApps({
                                return
                            })
                        })
                    })
                })
            } else {
                success = true
            }
        } else {
            fillAppArray({
                self.buildAppStore({
                    self.sortArray({
                        self.updateCurrentApps({
                            return
                        })
                    })
                })
            })
        }
        if let data = prefs.objectForKey("userapps") as? NSData {
            currentapps = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [App]
        } else {
            currentapps = []
        }
        if (success)
        {
            complete()
        }
    }
    func fillAppArray(complete: () -> Void) {
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
//                dispatch_async(dispatch_get_main_queue()) {  // Brings data from background task to main thread, loading data and populating TableView
//                    print(mydata)
                    if (mydata == nil)
                    {
                        self.flag = 1
                    }
                
                    self.Apps = mydata as! Array<AnyObject>  // Saves the resulting array to Employees Array
                for el in self.Apps {
                    print("**")
                    print(el)
                }
                    complete()
//                }
            }
            
//            self.buildAppStore()
            task.resume()  // Reloads Table View cells as results
        }
        
    }
    
    func buildAppStore(complete: () -> Void) {  // Convert raw data into more accessible AppStore
        if (AppStore.count == 0) {
    //        AppStore = []
            for element in Apps
            {
                
                AppStore.append(App(h: (element["Header"] as? String)!,t: (element["Title"] as? String)!,l: (element["Link"] as? String)!,p: (element["Permissions"] as? Int)!,s: (element["Selected"] as? Bool)!,i: (element["Icon"] as? String)!, u: (element["Url"] as? String)!, o: (element["Order"] as? Double)!))
            }
        }
        complete()
    }
    
    func sortArray(complete: () -> Void)
    {  // Sort array based on individual apps' "order" property
        AppHeaders = []
        var sorted: [App] = []
        for element in AppStore
        {
            if (!AppHeaders.contains(element.header))
            {
                AppHeaders.append(element.header)
            }
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
        
        if (AppHeaders.count > 0) {
            prefs.setObject(AppHeaders, forKey: "headers")
        }
        prefs.synchronize()
//        print(AppHeaders)
        complete()
    }
    
    func updateCurrentApps(complete: () -> Void)
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
            var lastdate: [String!] = []
            lastdate.append(dateFormatter.stringFromDate(date))
            lastdate.append(timeFormatter.stringFromDate(date))
            self.prefs.setObject(lastdate, forKey: "lastsync")
            self.prefs.synchronize()
        }
        complete()
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
    }

}
