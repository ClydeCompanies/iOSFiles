//
//  SyncNow.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 6/5/16.
//

import UIKit

class SyncNow: NSObject {
    
    var flag: Int = 0
    let prefs = UserDefaults.standard
    var Apps: [AnyObject] = []
    var AppStore: [App] = []
    var currentapps: [App] = []
    var done: Int = 0
    var syncnow: Int = 0
    var AppHeaders: [String] = []
    var progress: Float = 0
    
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
    
    init(sync: Int, complete: @escaping () -> Void) {
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
    
    func getAppStore(_ complete: () -> Void)
    {  // Load apps from online database
        var success: Bool = false
        if let data = prefs.object(forKey: "syncedappstore") as? Data {
            AppStore = NSKeyedUnarchiver.unarchiveObject(with: data) as! [App]
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
        if let data = prefs.object(forKey: "userapps") as? Data {
            currentapps = NSKeyedUnarchiver.unarchiveObject(with: data) as! [App]
        } else {
            currentapps = []
        }
        if (success)
        {
            complete()
        }
    }
    func fillAppArray(_ complete: @escaping () -> Void) {
        if let url = URL(string: "https://clydewap.clydeinc.com/webservices/json/ClydeWebServices/GetAppsInfo") {
            notify()
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard error == nil && data != nil else {
                    print("error=\(error)")
                    self.flag = 1
                    return
                }
                self.notify()
                if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 { // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                    self.flag = 1
                }
                self.notify()
                
                let mydata = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) // Creates dictionary array to save results of query
//                dispatch_async(dispatch_get_main_queue()) {  // Brings data from background task to main thread, loading data and populating TableView
//                    print(mydata)
                if (mydata == nil)
                {
                    self.flag = 1
                } else {
                    print(mydata)
                }
                self.notify()
                self.Apps = mydata as! Array<AnyObject>  // Saves the resulting array to Employees Array
                self.notify()
                complete()
//                }
            }) 
            
            task.resume()  // Reloads Table View cells as results
        }
        
    }
    
    func buildAppStore(_ complete: () -> Void) {  // Convert raw data into more accessible AppStore
        if (AppStore.count == 0) {
    //        AppStore = []
            for element in Apps
            {
                
                AppStore.append(App(h: (element["Header"] as? String)!,t: (element["Title"] as? String)!,l: (element["Link"] as? String)!,s: (element["Selected"] as? Bool)!,i: (element["Icon"] as? String)!, u: (element["Url"] as? String)!, o: (element["Order"] as? Double)!,r: (element["Redirect"] as? String)!))
            }
        }
        self.notify()
        complete()
    }
    
    func sortArray(_ complete: () -> Void)
    {  // Sort array based on individual apps' "order" property
        AppHeaders = []
        var sorted: [App] = []
        for element in AppStore
        {
            if (!AppHeaders.contains(element.header))
            {
                AppHeaders.append(element.header)
            }
            var min: App = App(h: "1", t: "1", l: "1", s: true, i: "1", u: "1", o: 99, r: "1")
            for el in AppStore
            {
                if (el.order < min.order)
                {
                    min = el
                }
            }
            sorted.append(min)
            AppStore.remove(at: AppStore.index(of: min)!)
        }
        self.notify()
        let appData = NSKeyedArchiver.archivedData(withRootObject: sorted)
        AppStore = sorted
        prefs.set(appData, forKey: "syncedappstore")
//        for el in AppStore {
//            print(String(el.order) + ", " + el.header + ", " + el.title)
//        }
        if (AppHeaders.count > 0) {
            prefs.set(AppHeaders, forKey: "headers")
        }
        prefs.synchronize()
//        print(AppHeaders)
        complete()
    }
    
    func updateCurrentApps(_ complete: () -> Void)
    {  // Updates the user's selected apps due to changes in online database
        
        if let data = prefs.object(forKey: "userapps") as? Data {
            var currentapps = NSKeyedUnarchiver.unarchiveObject(with: data) as! [App]
            for el in currentapps
            {
                var found: Bool = false
                for element in AppStore
                {
                    if (el.link == element.link)
                    {
                        el.header = element.header
                        el.title = element.title
                        el.URL = element.URL
                        el.icon = element.icon
                        el.order = element.order
                        el.redirect = element.redirect
                        found = true
                        break
                    }
                }
                if (!found)
                {
                    currentapps.remove(at: currentapps.index(of: el)!)
                }
                self.notify()
            }
            let data = NSKeyedArchiver.archivedData(withRootObject: currentapps)
            prefs.set(data, forKey: "userapps")
            prefs.synchronize()
        }
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm"
        if (self.flag == 0 && syncnow == 1)
        {
            var lastdate: [String] = []
            lastdate.append(dateFormatter.string(from: date))
            lastdate.append(timeFormatter.string(from: date))
            self.prefs.set(lastdate, forKey: "lastsync")
            self.prefs.synchronize()
        }
        self.notify()
        complete()
    }
    
    required init(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
    }

    func notify() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TEST"), object: nil)
    }
}
