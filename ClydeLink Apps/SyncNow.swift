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
//        getToken({
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
//        })
    }
    
    init(sync: Int, complete: @escaping () -> Void) {
        super.init()
        syncnow = 1
        done = 0
        flag = 0
        getToken({
            self.fillAppArray({
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
        var data: Array<AnyObject>?
        sendPost(urlstring: "https://clydewap.clydeinc.com/webservices/json/ClydeWebServices/GetIP") { mydata in
            
            data = mydata
//            if (!(data?[0]["Ip"] is NSNull))
//            {
//                return data?[0]["Ip"] as! String
//            } else {
//                
//                return ""
//            }
        }
        return data![0]["Ip"] as! String
    }
    
    func getToken(_ complete: @escaping () -> Void) {
        let userDefaults = UserDefaults.standard
        let code = userDefaults.string(forKey: "username")  // Get user email, set to code
        var parts = code?.components(separatedBy: "@")
        let uname: String = String(format:"%@", parts![0])  // Get username
        var userdetails: Array<AnyObject> = Array<AnyObject>()
        sendGet(urlstring: "https://clydelink.sharepoint.com/_api/Web/CurrentUser") { mydata in
            userdetails = mydata
        
            print("TOKENUSER", userdetails)
        
            if (userdetails.count > 0) {
            
                let account = userdetails[0]["ID"] // Get the user account number
                let salt = "i:0h.f|membership|1003bffd8a289327@live.com"  // TODO: Make sure it pulls salt, Where do I get it?
                let ip = self.getIP()  // Get IP
                
                let key = self.hashingAlgorithm(code: code!, ip: ip, account: account as! String, salt: salt)  // Use it all to generate the token key
                
                self.sendPost(urlstring: "https://clydewap.clydeinc.com/webservices/json/ClydeWebServices/GetToken", json: "{Email: \"\(uname)\", Key: \(key)}")  // Send post request
                
                
            }
        }
        complete()

    }
    
    func hashingAlgorithm(code: String, ip: String, account: String, salt: String) -> String
    {
        var hashedPassword: String = ""
        var data: Array<UInt8>
        let passwordarr: Array<UInt8> = Array(code.utf8)
        let saltarr: Array<UInt8> = Array(salt.utf8)
        
        do {
            data = try PKCS5.PBKDF2(password: passwordarr, salt: saltarr, iterations: 1500, keyLength: 8, variant: .sha256).calculate()
            var dataBase = data.toBase64()
            print("1st Hash: \(String(describing: dataBase))")
        } catch {
            print("Error in SHA256 hashing")
            return ""
        }
        let message = String(bytes: data, encoding: String.Encoding.utf8)! + salt + account
        var data2: String = ""
        do {
            data2 = try HMAC(key: saltarr, variant: .sha256).authenticate(Array(message.utf8)).toBase64()!
        }
        catch {
            print("Error in hmac")
        }
        print("2nd Hash: \(data2)")
        let mydate = Date()
        
        let ticks = mydate.timeIntervalSince1970 * 10000 + 621355968000000000
        
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
        
//        userDefaults.set(serviceEndpointLookup, forKey: "O365ServiceEndpoints")
//        userDefaults.synchronize()
        
        if let userEmail = userDefaults.string(forKey: "username") {
            var parts = userEmail.components(separatedBy: "@")
            
            let uName: String = String(format:"%@", parts[0])
            
            
            sendPost(urlstring: "https://webservices.clydeinc.com/ClydeRestServices.svc/json/ClydeWebServices/GetUserProfile", json: "{UserName: \"\(uName)\"}") { mydata in
//                print("I've found: \(mydata)")
                self.EmployeeInfo = mydata
            
                let employeedata = NSKeyedArchiver.archivedData(withRootObject: self.EmployeeInfo)
                self.prefs.set(employeedata, forKey: "userinfo")
                
                print(self.prefs.array(forKey: "permissions") ?? "No Permissions Loaded")
                self.prefs.synchronize()
                var permissions: [String] = []
                if (self.EmployeeInfo.count != 0 && !(self.EmployeeInfo[0]["Permissions"] is NSNull)) {
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
            }
            
            complete()
            
            
        }
        
        
    }
    
    
    func getAppStore(_ complete: @escaping () -> Void)
    {  // Load apps from online database
        
        if let data = prefs.object(forKey: "syncedappstore") as? Data {
            AppStore = NSKeyedUnarchiver.unarchiveObject(with: data) as! [App]
            if (AppStore.count == 0)
            {
                fillAppArray(complete)
            } else {
                complete()
            }
        } else {
            fillAppArray(complete)
        }
    }
    
    func fillAppArray(_ complete: @escaping () -> Void) {
        sendPost(urlstring: "https://cciportal.clydeinc.com/webservices/json/ClydeWebServices/GetAppsInfo") { mydata in
            self.Apps = mydata
            complete()
        }
        
    }
    
    func buildAppStore(_ complete: () -> Void) {  // Convert raw data into more accessible AppStore
        if (AppStore.count == 0) {
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
        if (AppHeaders.count > 0) {
            prefs.set(AppHeaders, forKey: "headers")
            
        }
        prefs.synchronize()
        complete()
    }
    
    func updateCurrentApps(_ complete: () -> Void)
    {  // Updates the user's selected apps due to changes in online database
        
        if let data = prefs.object(forKey: "userapps") as? Data {
            currentapps = NSKeyedUnarchiver.unarchiveObject(with: data) as! [App]
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
    
    func getCookies(cookies: NSMutableArray) -> String {
        var mystr: String = ""
        let acceptAll: Bool = true
        print("TESTING")
        for el in (cookies as NSArray as! [String]) {
            var cookieProps = NSMutableDictionary()
            cookieProps = prefs.dictionary(forKey: el) as! NSMutableDictionary
            print(cookieProps.value(forKey: HTTPCookiePropertyKey.domain.rawValue) ?? "")
            print(cookieProps)
            if (cookieProps.value(forKey: HTTPCookiePropertyKey.domain.rawValue) as! String == "clydelink.sharepoint.com" || cookieProps.value(forKey: HTTPCookiePropertyKey.domain.rawValue) as! String == ".sharepoint.com" || acceptAll)
            {
                print("Using this one")
                mystr += cookieProps.value(forKey: HTTPCookiePropertyKey.name.rawValue) as! String
                mystr += "="
                mystr += cookieProps.value(forKey: HTTPCookiePropertyKey.value.rawValue) as! String
                mystr += "; "
            }
        }
        print("DONE")
        print("My Cookies: \(mystr)")
        return mystr
    }
    
    func sendGet(urlstring: String, complete: @escaping (Array<AnyObject>) -> Void = {mydata in}) {
        
        print("SENDINGGET")
        if let url = URL(string: urlstring) {
            let request = NSMutableURLRequest(url: url)
            
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            if let cookies: NSMutableArray = prefs.object(forKey: "cookieArray") as? NSMutableArray {
                print("MYCOOKIES: \(cookies)")
                let mycookiestr = getCookies(cookies: cookies)
                request.setValue(mycookiestr, forHTTPHeaderField: "Cookie")
            }
            
            request.httpMethod = "GET"
            
            print("Request: \(request)")
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                if error != nil {
                    print(error ?? "Test")
                } else {
                    if let mydata = data {
                        do {
                            print(mydata) //JSONSerialization
                            let mydata = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                            print(" My Data from \(urlstring): ")
                            print(mydata)
                            let result = mydata as? Array<AnyObject>
//                            complete(result!)
                        }
                        catch let error2 {
                            print("Error2",error2)
                        }
                    }
                }
            }
            task.resume()
            
        }
        
        
    }
    
    func sendPost(urlstring: String, json: String = "", complete: @escaping (Array<AnyObject>) -> Void = {mydata in}) {
        
        
        
        if let url = URL(string: urlstring) {
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = json.data(using: String.Encoding.utf8)
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard error == nil && data != nil else { // check for fundamental networking error
                    print("error=\(String(describing: error))")
                    self.flag = 1
                    return
                }
                do {
                    let mydata = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    print(" My Data from \(urlstring): ")
                    print(mydata)
                    let result = mydata as? Array<AnyObject>
                    complete(result!)
                } catch let error {
                    print(error)
                }
            })
            task.resume()
        }
        
        
        
        
        
    }
}
