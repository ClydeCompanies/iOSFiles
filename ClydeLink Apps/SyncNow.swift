//
//  SyncNow.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 6/5/16.
//

import UIKit
import CryptoSwift

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
    var EmployeeInfo: Array<AnyObject> = []  // Holds information about current user
    var serviceEndpointLookup = NSMutableDictionary()
    
    override init() {
        super.init()
        syncnow = 0
        done = 0
        flag = 0
        getToken({
            getAppStore({
                self.buildAppStore({
                    self.sortArray({
                        self.updateCurrentApps({
                            self.loadUserInfo({
                                return
                            })
                        })
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
        getToken({
            fillAppArray({
                self.buildAppStore({
                    self.sortArray({
                        self.updateCurrentApps({
                            self.retrieveUserInfo({
                                complete()
                            })
                        })
                    })
                })
            })
        })
        
    }
    
    func getIP() -> String
    {
        let data: Array<AnyObject>? = sendPost(urlstring: "https://clydewap.clydeinc.com/webservices/json/ClydeWebServices/GetIP")
        if (!(data?[0]["IP"] is NSNull))
        {
            return data?[0]["Ip"] as! String
        } else {
            
            return ""
        }
    }
    
    func getToken(_ complete: () -> Void) {
        let userDefaults = UserDefaults.standard
        let code = userDefaults.string(forKey: "username")  // Get user email, set to code
        var parts = code?.components(separatedBy: "@")
        let uname: String = String(format:"%@", parts![0])  // Get username
        let userdetails = sendGet(urlstring: "https://clydelink.sharepoint.com/_api/Web/CurrentUser")
        print("USER")
        print(userdetails)
        
        if (userdetails.count > 0) {
        
            let account = userdetails[0]["ID"] // Get the user account number
            let salt = "i:0h.f|membership|1003bffd8a289327@live.com"  // TODO: Make sure it pulls salt, Where do I get it?
            let ip = getIP()  // Get IP
            
            let key = hashingAlgorithm(code: code!, ip: ip, account: account as! String, salt: salt)  // Use it all to generate the token key
            
            sendPost(urlstring: "https://clydewap.clydeinc.com/webservices/json/ClydeWebServices/GetToken", json: "{Email: \"\(uname)\", Key: \(key)}")  // Send post request
            
            complete()
        }
    
    }
    
    func hashingAlgorithm(code: String, ip: String, account: String, salt: String) -> String
    {
        var hashedPassword: String = ""
        var data: Array<UInt8>
        let passwordarr: Array<UInt8> = Array(code.utf8)
        let saltarr: Array<UInt8> = Array(salt.utf8)
        
        do {
            data = try PKCS5.PBKDF2(password: passwordarr, salt: saltarr, iterations: 1500, keyLength: 8, variant: .sha256).calculate()  //That usually means the arguments don't work right
            var dataBase = data.toBase64()
            print("1st Hash: \(String(describing: dataBase))")
        } catch {
            print("Error in SHA256 hashing")
            return "" //Why is that? Okay, so the data.toBase64 returns a byte array, it's not a simple function,
                        // Also, the try thing is confusing, but I think I got it right
        }
          // It is supposed to be do, but the try right here doesn't appear to throw anything (which it does)
        let message = String(bytes: data, encoding: String.Encoding.utf8)! + salt + account
        var data2: String = ""
        do {
            data2 = try HMAC(key: saltarr, variant: .sha256).authenticate(Array(message.utf8)).toBase64()!
        }
        catch {  // I'm fine with String!
            print("Error in hmac")
        }
//        let hmac = HMAC(key: saltarr, variant: .sha256)
//        let data2 = hmac.variant.calculateHash(Array(message.utf8)).toBase64()
        print("2nd Hash: \(data2)")
        //I have an idea... Never mind
        // Tell me what you are trying to do
        // I just need to access that function! So I wanted to take it out of the enum context
        // Is there documentation for Crypto? We could see how to use that calculateHash function
        // Here's what I found:
        let mydate = Date()
        
        let ticks = mydate.timeIntervalSince1970 * 10000 + 621355968000000000
        
//        NSString* ua = [webView.request valueForHTTPHeaderField:@"User-Agent"];
        let ua = UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent")!
        let ua2 = ua.components(separatedBy: " ")
        var message2: String = account
            message2 += ":"
            message2 += ip
            message2 += ":"
            message2 += ua2[2]
            message2 += ":"
            message2 += ua2[1]
            message2 += ":"
            message2 += String(format:"%f", ticks)
        
        
        var token: String = ""
        do {
            token = try HMAC(key: data2, variant: .sha256).authenticate(Array(message2.utf8)).toBase64()!
//            token = String(data: HMAC(key: data2, variant: .sha256).calculate(Array(message2.utf8)).toBase64(), encoding: NSUTF8StringEncoding)
        }
        catch {  // I'm fine with String!
            print("Error in hmac")
        }
        
        
        
        let tokenID = account + ":" + String(format:"%f", ticks)
        
        let tokencombo: String = token + ":" + tokenID
        
        var finaldata = String(data: (tokencombo.data(using: .utf8)!), encoding: String.Encoding.utf8)
        finaldata = finaldata?.data(using: .utf8)?.base64EncodedString()
        //So it doesn't like tokencombo Wait?ded Wait I got it! Whoa?! Ugh, I don't think this is working Let me try
        hashedPassword = finaldata!
        //No smileys!! Haha I was gonna wait for you to have to debug that one Haha you stink.
        return hashedPassword
        
    }
    
    func loadUserInfo(_ complete: @escaping () -> Void) {  // Get user's information
        
        if let data = prefs.object(forKey: "userinfo") as? Data {
            self.EmployeeInfo = NSKeyedUnarchiver.unarchiveObject(with: data) as! Array<AnyObject>
        }

    }
    
    func retrieveUserInfo(_ complete: @escaping () -> Void) {  // Get user's information
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(serviceEndpointLookup, forKey: "O365ServiceEndpoints")
        userDefaults.synchronize()
        
        if let userEmail = userDefaults.string(forKey: "username") {
            var parts = userEmail.components(separatedBy: "@")
            
            let uName: String = String(format:"%@", parts[0])
            
            self.EmployeeInfo = sendPost(urlstring: "https://webservices.clydeinc.com/ClydeRestServices.svc/json/ClydeWebServices/GetUserProfile", json: "{UserName: \"\(uName)\"}")
            
            let employeedata = NSKeyedArchiver.archivedData(withRootObject: self.EmployeeInfo)
            self.prefs.set(employeedata, forKey: "userinfo")
            
            print(self.prefs.array(forKey: "permissions") ?? "No Permissions Loaded")
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
                
                print(self.prefs.array(forKey: "permissions") ?? "No Permissions Loaded")
            } else {
                self.prefs.set([],forKey: "permissions")
            }

            
            complete()
            
            
        }
        
        
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
        self.Apps = sendPost(urlstring: "https://cciportal.clydeinc.com/webservices/json/ClydeWebServices/GetAppsInfo", complete: complete)
        
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
    
    func sendGet(urlstring: String, json: String = "", complete: @escaping () -> Void = {}) -> Array<AnyObject> {
        var result: Array<AnyObject>? = nil
        if let url = URL(string: urlstring) {  // Sends POST request to the DMZ server, and prints the response string as an array
            
            let request = NSMutableURLRequest(url: url)
            
            request.httpMethod = "GET"
            let bodyData = json
            request.httpBody = bodyData.data(using: String.Encoding.utf8)
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard error == nil && data != nil else { // check for fundamental networking error
                    print("error=\(error)")
                    self.flag = 1
                    
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 { // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }
                
                let mydata = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) // Creates dictionary array to save results of query
                
                print(" My Data from \(urlstring): ")
                print(mydata ?? "No Data")  // Direct response from server printed to console, for testing
                
                DispatchQueue.main.async {  // Brings data from background task to main thread, loading data and populating TableView
                    if (mydata == nil)
                    {
                        self.flag = 1
                        
                        
                        return
                    }
                    
                    result = mydata as? Array<AnyObject>
                    
                    complete()
                    
                }
                
            })
            task.resume()
        }
        return result ?? Array<AnyObject>()
    }
    
    func sendPost(urlstring: String, json: String = "", complete: @escaping () -> Void = {}) -> Array<AnyObject> {
        var result: Array<AnyObject>? = nil
        if let url = URL(string: urlstring) {  // Sends POST request to the DMZ server, and prints the response string as an array
            
            let request = NSMutableURLRequest(url: url)
            
            request.httpMethod = "POST"
            let bodyData = json
            request.httpBody = bodyData.data(using: String.Encoding.utf8)
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard error == nil && data != nil else { // check for fundamental networking error
                    print("error=\(error)")
                    self.flag = 1
                    
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 { // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }
                
                let mydata = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) // Creates dictionary array to save results of query
                
                print(" My Data from \(urlstring): ")
                print(mydata ?? "No Data")  // Direct response from server printed to console, for testing
                
                DispatchQueue.main.async {  // Brings data from background task to main thread, loading data and populating TableView
                    if (mydata == nil)
                    {
                        self.flag = 1
                        
                        
                        return
                    }
                    
                    result = mydata as? Array<AnyObject>
                    
                    complete()
                    
                }
                
            })
            task.resume()
        }
        return result ?? Array<AnyObject>()
    }
}
