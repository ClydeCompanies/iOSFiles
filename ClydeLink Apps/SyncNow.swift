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
    var Apps: Array<AnyObject> = []
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
        
        self.getAppStore({
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
    }
    
    init(sync: Int, complete: @escaping () -> Void) {
        super.init()
        syncnow = 1
        done = 0
        flag = 0
        self.getIP()
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
        var data: [String : Any] = [:]
        sendPost(urlstring: "https://cciportal.clydeinc.com/webservices/json/ClydeWebServices/GetIP") { mydata in
            data = mydata
            
            if (data["Ip"] != nil)
            {
                UserDefaults.standard.setValue(data["Ip"] as! String, forKey: "IP")
            }
        }
        return ""
    }
    
    func hashingAlgorithm(code: String, ip: String, account: String, salt: String) -> String
    {
        var hashedPassword: String = ""
        var data: Array<UInt8>
        var firsthash: String = ""
        let passwordarr: Array<UInt8> = Array(code.utf8)
        let saltarr: Array<UInt8> = Array(salt.utf8)
        
        do {
            data = try PKCS5.PBKDF2(password: passwordarr, salt: saltarr, iterations: 1500, keyLength: 32, variant: .sha256).calculate()
            let dataBase = data.toBase64()!
            firsthash = dataBase
        } catch {
            print("HASH: Error in SHA256 hashing")
            return ""
        }
        let message = firsthash + ":" + salt + ":" + account
        var data2: String = ""
        do {
            data2 = try HMAC(key: saltarr, variant: .sha256).authenticate(Array(message.utf8)).toBase64()!
        }
        catch {
            print("HASH: Error in hmac")
        }
        
        let mydate = Date()
        
        let ticks: UInt64 = UInt64(mydate.timeIntervalSince1970) * 10000000 + 621355968000000000
        //        ticks = 636271773604240000
        
        let ua = UserDefaults.standard.string(forKey: "userAgent")!
        let ipAddr = UserDefaults.standard.string(forKey: "IP")!
        
        let message2: String = account + ":" + ipAddr + ":" + ua + ":" + String(describing: ticks)
        
        var token: String = ""
        let dataarr: Array<UInt8> = Array(data2.utf8)
        do {
            
            token = try HMAC(key: dataarr, variant: .sha256).authenticate(Array(message2.utf8)).toBase64()!
        }
        catch {
            print("HASH: Error in hmac")
        }
        
        
        let tokenID = account + ":" + String(describing: ticks)
        
        let tokencombo: String = token + ":" + tokenID
        
        var finaldata = String(data: (tokencombo.data(using: .utf8)!), encoding: String.Encoding.utf8)
        finaldata = finaldata?.data(using: .utf8)?.base64EncodedString()
        
        hashedPassword = finaldata!
        
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
            var tokenMessage: Array<AnyObject> = []
            
            sendAnyPost(urlstring: "https://cciportal.clydeinc.com/webservices/json/ClydeWebServices/GetUserProfile", json: ["UserName": uName]) { mydata in tokenMessage = mydata
                
                
                self.EmployeeInfo = tokenMessage
                self.prefs.set(self.EmployeeInfo[0]["CompanyNumber"]!, forKey: "Company")
                
                let employeedata = NSKeyedArchiver.archivedData(withRootObject: self.EmployeeInfo)
                self.prefs.set(employeedata, forKey: "userinfo")
                
                self.prefs.synchronize()
                var permissions: [String] = []
                if (self.EmployeeInfo.count != 0 && !(self.EmployeeInfo[0]["Permissions"] is NSNull)) {
                    let rawpermissions = self.EmployeeInfo[0]["Permissions"] as! Array<AnyObject>
                    if (!(rawpermissions is [String])) {
                        for permission in rawpermissions {
                            permissions.append((permission["Group"]) as! String)
                        }
                    }
                    self.prefs.set(permissions, forKey: "permissions")
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
        sendAnyPost(urlstring: "https://cciportal.clydeinc.com/webservices/json/ClydeWebServices/GetAppsInfo", json: ["":""]) { mydata in
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
        for el in (cookies as NSArray as! [String]) {
            var cookieProps = NSMutableDictionary()
            cookieProps = prefs.dictionary(forKey: el) as! NSMutableDictionary
            
            if (cookieProps.value(forKey: HTTPCookiePropertyKey.domain.rawValue) as! String == "clydelink.sharepoint.com" || cookieProps.value(forKey: HTTPCookiePropertyKey.domain.rawValue) as! String == ".sharepoint.com" || acceptAll)
            {
                mystr += cookieProps.value(forKey: HTTPCookiePropertyKey.name.rawValue) as! String
                mystr += "="
                mystr += cookieProps.value(forKey: HTTPCookiePropertyKey.value.rawValue) as! String
                mystr += "; "
            }
        }
        return mystr
    }
    
    func sendGet(urlstring: String, complete: @escaping ([String : Any]) -> Void = {mydata in}) {
        
        if let url = URL(string: urlstring) {
            let request = NSMutableURLRequest(url: url)
            
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            if let cookies: NSMutableArray = prefs.object(forKey: "cookieArray") as? NSMutableArray {
                let mycookiestr = getCookies(cookies: cookies)
                request.setValue(mycookiestr, forHTTPHeaderField: "Cookie")
            }
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                if error != nil {
                    print(error ?? "Test")
                } else {
                    if data != nil {
                        do {
                            let mydata = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : Any]
                            let result = mydata
                            complete(result)
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
    
    func sendPost(urlstring: String, json: String = "", complete: @escaping ([String : Any]) -> Void = {mydata in}) {
        if let url = URL(string: urlstring) {
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = json.data(using: String.Encoding.utf8)
            request.setValue(UserDefaults.standard.string(forKey: "userAgent")!, forHTTPHeaderField: "User-Agent")
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard error == nil && data != nil else { // check for fundamental networking error
                    print("error=\(String(describing: error))")
                    self.flag = 1
                    return
                }
                if (data != nil) {
                    do {
                        let mydata = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : Any]
                        let result = mydata
                        complete(result)
                    } catch let error {
                        print(error)
                    }
                }
            })
            task.resume()
        }
    }
    
    func sendAnyPost(urlstring: String, json:  Dictionary<String, String>, complete: @escaping (Array<AnyObject>) -> Void = {mydata in}) {
        if let url = URL(string: urlstring) {
            let params = json
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            //request.setValue(UserDefaults.standard.string(forKey: "userAgent")!, forHTTPHeaderField: "User-Agent")
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                
            } catch let error {
                print(error.localizedDescription)
            }
            
            
            //create dataTask using the session object to send data to the server
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard error == nil else {
                    self.flag = 1
                    return
                }
                
                guard let data = data else {
                    self.flag = 1
                    return
                }
                
                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Array<AnyObject> {
                        let result = json
                        complete(result)
                    }
                    
                } catch let error {
                    print(error.localizedDescription)
                }
                
            })
            
            task.resume()
        }
    }
    
    func getTopViewController()->UIViewController{
        return topViewControllerWithRootViewController(rootViewController: UIApplication.shared.keyWindow!.rootViewController!)
    }
    
    func topViewControllerWithRootViewController(rootViewController:UIViewController)->UIViewController{
        if rootViewController is UITabBarController{
            let tabBarController = rootViewController as! UITabBarController
            return topViewControllerWithRootViewController(rootViewController: tabBarController.selectedViewController!)
        }
        if rootViewController is UINavigationController{
            let navBarController = rootViewController as! UINavigationController
            return topViewControllerWithRootViewController(rootViewController: navBarController.visibleViewController!)
        }
        if let presentedViewController = rootViewController.presentedViewController {
            return topViewControllerWithRootViewController(rootViewController: presentedViewController)
        }
        return rootViewController
    }
    
    func getToken(_ complete: @escaping () -> Void) {
        let userDefaults = UserDefaults.standard
        let code = userDefaults.string(forKey: "username")  // Get user email, set to code
        var parts = code?.components(separatedBy: "@")
        let uname: String = String(format: "%@", parts![0])  // Get username
        var userdetails: [String : Any] = [:]
        
        sendGet(urlstring: "https://clydelink.sharepoint.com/apps/_api/Web/CurrentUser") { mydata in
            userdetails = mydata
            
            if (userdetails.count > 0 && userdetails["Id"] != nil) {
                
                let account: String = String(describing: userdetails["Id"]!) // Get the user account number
                var salt: String = String(describing: userdetails["LoginName"]!) // TODO: Make sure it pulls salt, Where do I get it?
                let userId = userdetails["UserId"] as? [String: String]
                let nameId : String = String(describing:(userId?["NameId"])! + "@live.com")
                let email : String = String(describing: userdetails["Email"])
                
                salt = "i:0h.f|membership|" +  nameId
                // Get IP
                let ip = self.getIP()
                
                let key = self.hashingAlgorithm(code: code!, ip: ip, account: account, salt: salt)  // Use it all to generate the token key
                
                var tokenMessage: [String : Any] = [:]
                // Send post request
                self.sendPost(urlstring: "https://cciportal.clydeinc.com/webservices/json/ClydeWebServices/GetToken", json: "{Email: \"\(code!)\", Key: \"\(key)\"}") { mydata in tokenMessage = mydata
                    
                    if tokenMessage["message"] != nil {
                        if (String(describing: tokenMessage["message"]!) == "false" || String(describing: tokenMessage["message"]!) == "expired") {
                            
                            let alert: UIAlertController = UIAlertController(title: "Error Authenticating", message: "There seems to be a problem with your user token. Please try logging out and in again. If the problem persists, please contact Infomation Management.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                                
                                self.prefs.set("", forKey: "username")
                                self.prefs.set("", forKey: "LogInUser")
                                self.prefs.set([], forKey: "userapps")
                                self.prefs.set([], forKey: "permissions")
                                
                                URLCache.shared.removeAllCachedResponses()
                                
                                _ = HTTPCookie.self
                                let cookieJar = HTTPCookieStorage.shared
                                for cookie in cookieJar.cookies! {
                                    cookieJar.deleteCookie(cookie)
                                }
                                
                                let vc : AnyObject! = self.getTopViewController().storyboard!.instantiateViewController(withIdentifier: "Main")
                                self.getTopViewController().present(vc as! UIViewController, animated: true, completion: nil)
                                self.prefs.synchronize()
                                
                            }))
                            self.getTopViewController().present(alert, animated: true, completion: nil)
                        } else {
                            complete()
                        }
                    } else {
                        complete()
                    }
                }
            }
        }
    }
}
