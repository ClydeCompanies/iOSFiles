//
//  AppDelegate.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 5/9/16
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        loadHTTPCookies()
        
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        
        // Check for newer version
        if let url = URL(string: "https://cciportal.clydeinc.com/webservices/json/ClydeWebServices/GetLatestVersions") {  // Sends POST request to the DMZ server, and prints the response string as an array
            
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard error == nil && data != nil else { // check for fundamental networking error
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 { // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }
                
                
                let mydata = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) // Creates dictionary array to save results of query
                
                
                DispatchQueue.main.async {
                    if (mydata == nil || mydata is NSNull) {
                        return
                    }
                    
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        
                        let jsondata = mydata as? [String : String]
                        
                        if ((version as NSString).doubleValue < (jsondata?["ios"]! as! NSString).doubleValue) {
                            let alert: UIAlertController = UIAlertController(title: "New Version Ready", message: "Please update the app to the latest version", preferredStyle: .alert)
                            let link = "itms-services://?action=download-manifest&amp;url=itms-services://?action=download-manifest&amp;url=https://cciportal.clydeinc.com/clydelinkapp/manifest.plist"
                            let defaultAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                            let updateAction = UIAlertAction(title: "Update", style:.default, handler: {
                                (action:UIAlertAction!) -> Void in
                                UIApplication.shared.openURL(NSURL(string: link)! as URL)
                            })
                            alert.addAction(updateAction)
                            alert.addAction(defaultAction)
                            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        }
                        
                        
                        
                    }
                    
                }
                
            })
            task.resume()
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveCookies()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        loadHTTPCookies()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveCookies()
        self.saveContext()
    }
    
    @objc func loadHTTPCookies() {
        
        if let cookieDict = UserDefaults.standard.value(forKey: "cookieArray") as? NSMutableArray {
            
            for c in cookieDict {
                
                let cookies = UserDefaults.standard.value(forKey: c as!String) as!NSDictionary
                let cookie = HTTPCookie(properties: cookies as![HTTPCookiePropertyKey: Any])
                
                HTTPCookieStorage.shared.setCookie(cookie!)
            }
        }
    }
    
    @objc func saveCookies() {
        
        let cookieArray = NSMutableArray()
        if let savedC = HTTPCookieStorage.shared.cookies {
            for c: HTTPCookie in savedC {
                
                let cookieProps = NSMutableDictionary()
                cookieArray.add(c.name)
                cookieProps.setValue(c.name, forKey: HTTPCookiePropertyKey.name.rawValue)
                cookieProps.setValue(c.value, forKey: HTTPCookiePropertyKey.value.rawValue)
                cookieProps.setValue(c.domain, forKey: HTTPCookiePropertyKey.domain.rawValue)
                cookieProps.setValue(c.path, forKey: HTTPCookiePropertyKey.path.rawValue)
                cookieProps.setValue(c.version, forKey: HTTPCookiePropertyKey.version.rawValue)
                cookieProps.setValue(NSDate().addingTimeInterval(2629743), forKey: HTTPCookiePropertyKey.expires.rawValue)
                
                UserDefaults.standard.setValue(cookieProps, forKey: c.name)
                UserDefaults.standard.synchronize()
            }
        }
        
        UserDefaults.standard.setValue(cookieArray, forKey: "cookieArray")
    }
    
    // MARK: - Core Data stack
    
    @objc lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    @objc lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "DataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    @objc lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("ClydeLink Apps.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    @objc lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    @objc func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
}

