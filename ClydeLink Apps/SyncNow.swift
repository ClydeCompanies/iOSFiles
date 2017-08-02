//
//  SyncNow.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 6/5/16.
//

import UIKit
import CryptoSwift

var AppStore: [App] = []
var currentapps: [App] = []
var AppHeaders: [String] = []
var EmployeeInfo: Array<AnyObject> = []
var success: Bool = true

class SyncNow: NSObject {
    
    override init() {
        super.init()
        
        if let data = UserDefaults.standard.object(forKey: "userinfo") as? Data {
            EmployeeInfo = NSKeyedUnarchiver.unarchiveObject(with: data) as! Array<AnyObject>
        }
        if let data = UserDefaults.standard.object(forKey: "syncedappstore") as? Data {
            AppStore = NSKeyedUnarchiver.unarchiveObject(with: data) as! [App]
        }
        if (AppStore.count == 0) {
            let queue = OperationQueue()
            queue.isSuspended = true
            let iptask = getIpTask()
            let toktask = getTokenTask()
            let appsTask = getAppsTask()
            let ustask = getUserInfoTask()
            ustask.addDependency(toktask)
            appsTask.addDependency(toktask)
            toktask.addDependency(iptask)
            queue.addOperation(iptask)
            queue.addOperation(toktask)
            queue.addOperation(appsTask)
            queue.isSuspended = false
        }
    }
    
    init(sync: Int, complete: @escaping () -> Void) {
        super.init()
        let queue = OperationQueue()
        queue.isSuspended = true
        let iptask = getIpTask()
        let toktask = getTokenTask()
        let appsTask = getAppsTask()
        let ustask = getUserInfoTask()
        let setTask = updateSettingsTask()
        ustask.addDependency(toktask)
        appsTask.addDependency(toktask)
        toktask.addDependency(iptask)
        setTask.addDependency(ustask)
        
        queue.addOperation(iptask)
        queue.addOperation(toktask)
        queue.addOperation(ustask)
        queue.addOperation(appsTask)
        queue.addOperation(setTask)
        
        queue.isSuspended = false
        
        while (queue.operationCount > 0) {}
        complete()
    }
    
    required init(coder aDecoder: NSCoder) {
    }
    
}


class getIpTask: Operation {
    override func main() {
        print("IP")
        var finished: Bool = false
        if let url = URL(string: "https://clydewap.clydeinc.com/webservices/json/ClydeWebServices/GetIP") {
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                if (data != nil) {
                    do {
                        let mydata = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : Any]
                        UserDefaults.standard.set(mydata["Ip"],forKey: "Ip")
                        UserDefaults.standard.set((mydata["UserAgent"] as! String).replacingOccurrences(of: "%20", with: " "),forKey: "UserAgent")
                        UserDefaults.standard.synchronize()
                        print("******GETIP******")
                        print(mydata)
                        print("*****************")
                        finished = true
                    } catch let error {
                        print(error)
                    }
                }
            }).resume()
        }
        while (!finished) {}
    }
}

class getTokenTask: Operation {
    override func main() {
        print("Token")
        var finished: Bool = false
        if let url = URL(string: "https://clydelink.sharepoint.com/apps/_api/Web/CurrentUser") {
            let request = NSMutableURLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            if let cookies: NSMutableArray = UserDefaults.standard.object(forKey: "cookieArray") as? NSMutableArray {
                var mycookiestr = ""
                for el in (cookies as NSArray as! [String]) {
                    var cookieProps = NSMutableDictionary()
                    cookieProps = UserDefaults.standard.dictionary(forKey: el) as! NSMutableDictionary
                    mycookiestr += cookieProps.value(forKey: HTTPCookiePropertyKey.name.rawValue) as! String
                    mycookiestr += "="
                    mycookiestr += cookieProps.value(forKey: HTTPCookiePropertyKey.value.rawValue) as! String
                    mycookiestr += "; "
                }
                request.setValue(mycookiestr, forHTTPHeaderField: "Cookie")
            }
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                    if data != nil {
                        do {
                            dump(data)
                            let userdetails = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : AnyObject]
                            print(userdetails)
                            let code = UserDefaults.standard.string(forKey: "username")
                            if let testid = userdetails["Id"] {
                                let account: String = String(describing: testid)
                                let userId: String = userdetails["UserId"]!["NameId"]! as! String
                                let salt: String = "i:0h.f|membership|" + userId + "@live.com"
                                let ip = UserDefaults.standard.string(forKey: "Ip")
                                let ua = UserDefaults.standard.string(forKey: "UserAgent")
                                let key = hashingAlgorithm(code: code!, ip: ip!, account: account, salt: salt, ua: ua!)
                                let json = "{Email: \"\(code!)\", Key: \"\(key)\"}"
                                print(json)
                                if let url = URL(string: "https://clydewap.clydeinc.com/webservices/json/ClydeWebServices/GetToken") {
                                    let request = NSMutableURLRequest(url: url)
                                    request.httpMethod = "POST"
                                    request.httpBody = json.data(using: String.Encoding.utf8)
                                    URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                                        if (data != nil) {
                                            do {
                                                print("TOKEN ENDPOINT")
                                                dump(data)
                                                if let str: String = String(bytes: data!, encoding: String.Encoding.utf8) {
                                                    print("Token Response" + str)
                                                }
                                                let tokenMessage = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : Any]
                                                print("TOKENMESSAGE--", String(describing: tokenMessage["message"]!))
                                                if tokenMessage["message"] != nil {
                                                    if (String(describing: tokenMessage["message"]!) == "false") {
                                                        success = false
                                                        let alert: UIAlertController = UIAlertController(title: "Error Authenticating", message: "The token was unable to be created.", preferredStyle: .alert)
                                                        getTopViewController().present(alert, animated: true, completion: nil)
                                                        print("Token Failed")
                                                    } else if(String(describing: tokenMessage["message"]!) == "expired") {
                                                        success = false
                                                        let alert: UIAlertController = UIAlertController(title: "Error Authenticating", message: "The token was expired. Please sync again", preferredStyle: .alert)
                                                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                                                            let cookieJar = HTTPCookieStorage.shared
                                                            for cookie in cookieJar.cookies! {if (cookie.name=="Set-Cookie") {cookieJar.deleteCookie(cookie)}}
                                                            UserDefaults.standard.synchronize()
                                                        }))
                                                        getTopViewController().present(alert, animated: true, completion: nil)
                                                    }
                                                }
                                            } catch let error {
                                                success = false
                                                print(error)
                                            }
                                            finished = true
                                        }
                                    }).resume()
                                }
                            } else {
                                print("Error in data:")
                                dump(userdetails)
                                finished = true
                            }
                        }
                        catch let error {
                            print("Error",error)
                        }
                    }
            }.resume()
        }
        while (!finished) {}
    }
}

class getAppsTask: Operation {
    override func main() {
        print("Apps")
        var finished: Bool = false
        if let url = URL(string: "https://cciportal.clydeinc.com/webservices/json/ClydeWebServices/GetAppsInfo") {
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                if (data != nil) {
                    do {
                        let Apps = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! Array<AnyObject>
                        AppStore = []
                        for element in Apps
                        {
                            AppStore.append(App(h: (element["Header"] as? String)!,t: (element["Title"] as? String)!,l: (element["Link"] as? String)!,s: (element["Selected"] as? Bool)!,i: (element["Icon"] as? String)!, u: (element["Url"] as? String)!, o: (element["Order"] as? Double)!,r: (element["Redirect"] as? String)!))
                        }
                        AppHeaders = []
                        var sorted: [App] = []
                        while (AppStore.count > 0)
                        {
                            var min: App = App(h: "1", t: "1", l: "1", s: true, i: "1", u: "1", o: 99, r: "1")
                            for el in AppStore
                            {
                                if (el.order < min.order)
                                {
                                    min = el
                                }
                            }
                            if (!AppHeaders.contains(min.header))
                            {
                                AppHeaders.append(min.header)
                            }
                            sorted.append(min)
                            AppStore.remove(at: AppStore.index(of: min)!)
                        }
                        
                        let appData = NSKeyedArchiver.archivedData(withRootObject: sorted)
                        AppStore = sorted
                        UserDefaults.standard.set(appData, forKey: "syncedappstore")
                        UserDefaults.standard.set(AppHeaders, forKey: "headers")
                        UserDefaults.standard.synchronize()
                        currentapps = []
                        if let data = UserDefaults.standard.object(forKey: "userapps") as? Data {
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
                            }
                            let data = NSKeyedArchiver.archivedData(withRootObject: currentapps)
                            UserDefaults.standard.set(data, forKey: "userapps")
                            UserDefaults.standard.synchronize()
                            finished = true
                        }
                    } catch let error {
                        print(error)
                    }
                }
            }).resume()
        }
        while (!finished) {}
    }
}

class getUserInfoTask: Operation {
    override func main() {
        var finished: Bool = false
        print("User")
        if let userEmail = UserDefaults.standard.string(forKey: "username") {
            var parts = userEmail.components(separatedBy: "@")
            let uName: String = String(format:"%@", parts[0])
            let json: String = "{UserName: \"\(uName)\"}"
            if let url = URL(string: "https://webservices.clydeinc.com/ClydeRestServices.svc/json/ClydeWebServices/GetUserProfile") {
                let request = NSMutableURLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = json.data(using: String.Encoding.utf8)
                URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                    if (data != nil) {
                        do {
                            let empJSON = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                            print("GetUserProfile")
                            dump(empJSON)
                            if let _ = empJSON as? Array<AnyObject> {
                                print("OK")
                                EmployeeInfo =  empJSON as! Array<AnyObject>
                                UserDefaults.standard.set(EmployeeInfo[0]["CompanyNumber"]!, forKey: "Company")
                                UserDefaults.standard.set(data, forKey: "userinfo")
                                var permissions: [String] = []
                                for permission in EmployeeInfo[0]["Permissions"] as! Array<AnyObject> {
                                    permissions.append((permission["Group"]) as! String)
                                }
                                UserDefaults.standard.set(permissions, forKey: "permissions")
                                UserDefaults.standard.synchronize()
                            } else {
                                print("GetUserProfile Failed")
                            }
                            finished = true
                        } catch let error {
                            print(error)
                        }
                    }
                }).resume()
            }
        }
        while (!finished) {}
    }
}

class updateSettingsTask: Operation {
    override func main() {
        if (success) {
            print("Settings")
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm"
            var lastdate: [String] = []
            lastdate.append(dateFormatter.string(from: date))
            lastdate.append(timeFormatter.string(from: date))
            UserDefaults.standard.set(lastdate, forKey: "lastsync")
            UserDefaults.standard.synchronize()
        }
    }
}



func hashingAlgorithm(code: String, ip: String, account: String, salt: String, ua: String) -> String {
    print("******HASHING******")
    print("Code: \(code)\nIP: \(ip)\nAccount: \(account)\nSalt: \(salt)\nUserAgent: \(ua)")
    var firsthash: String = ""
    let passwordarr: Array<UInt8> = Array(code.utf8)
    let saltarr: Array<UInt8> = Array(salt.utf8)
    do {firsthash = try PKCS5.PBKDF2(password: passwordarr, salt: saltarr, iterations: 1500, keyLength: 32, variant: .sha256).calculate().toBase64()!}
    catch{print("HASH: Error in SHA256 hashing")}
    print("First: \(firsthash)")
    let message = firsthash + ":" + salt + ":" + account
    print("Message: \(message)")
    var data2: String = ""
    do {data2 = try HMAC(key: saltarr, variant: .sha256).authenticate(Array(message.utf8)).toBase64()!}
    catch {print("HASH: Error in hmac")}
    print("Data2: \(data2)")
    let ticks: UInt64 = UInt64(Date().timeIntervalSince1970) * 10000 + 635646076777520000
    print("Ticks: \(ticks)")
    let ua2 = ua.components(separatedBy: " ")
    var message2: String = ""
//    if (ua2.count > 2) {message2 = account + ":" + ip + ":" + ua2[1] + ua2[0] + ":" + String(describing: ticks)} else {message2 = ""}
    if (ua2.count > 2) {message2 = account + ":" + ip + ":" + ua + ":" + String(describing: ticks)} else {message2 = ""}
    print("UA2: \(ua2)")
    print("Message2: \(message2)")
    var token: String = ""
    do {token = try HMAC(key: Array(data2.utf8), variant: .sha256).authenticate(Array(message2.utf8)).toBase64()!}
    catch {print("HASH: Error in hmac")}
    let tokencombo: String = token + ":" + account + ":" + String(describing: ticks)
    print("TokenCombo: \(tokencombo)")
    let final: String = (String(data: (tokencombo.data(using: .utf8)!), encoding: String.Encoding.utf8)?.data(using: .utf8)?.base64EncodedString())!
    print("Final: \(final)")
    print("*******************")
    return final
}

func getTopViewController()->UIViewController{
    return topViewControllerWithRootViewController(rootViewController: UIApplication.shared.keyWindow!.rootViewController!)
}

func topViewControllerWithRootViewController(rootViewController:UIViewController)->UIViewController{
    if rootViewController is UITabBarController{
        let tabBarController = rootViewController as! UITabBarController
        return topViewControllerWithRootViewController(rootViewController: tabBarController.selectedViewController!)}
    if rootViewController is UINavigationController{
        let navBarController = rootViewController as! UINavigationController
        return topViewControllerWithRootViewController(rootViewController: navBarController.visibleViewController!)}
    if let presentedViewController = rootViewController.presentedViewController {
        return topViewControllerWithRootViewController(rootViewController: presentedViewController)}
    return rootViewController
}
