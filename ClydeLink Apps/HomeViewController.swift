//
//  HomeViewController.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 5/14/16.
//

import UIKit
import SystemConfiguration

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var leftButton: UIBarButtonItem!
    @IBOutlet weak var rightButton: UIBarButtonItem!
    @IBOutlet weak var AppTable: UITableView!
    
    var test: String = "TEST" // Used for receiving username
    var EmployeeInfo: Array<AnyObject> = []  // Holds information about current user
    var flag: Int = 0  // Saves any errors as 1
    var synced: SyncNow = SyncNow()
    
    
    var appButtons: Array = [App]()  // Holds clickable buttons
    
    var NoFavorite: Int = 0
    var finalEdit: Bool = false
    var AppCount: Int = 0  // Increments and controls distribution of array data to UITable
    
    let prefs = UserDefaults.standard  // Current user preferences
    
    var baseController = Office365ClientFetcher()
    var serviceEndpointLookup = NSMutableDictionary()
    var components: AnyObject = "" as AnyObject
    

    
    override func viewDidLoad() {  // Runs when the view loads
        super.viewDidLoad()
        
        finalEdit = false
        if (prefs.string(forKey: "username") == "Loading...")
        {
            prefs.set("", forKey: "username")
        }
        test = "TEST"
        
        NoFavorite = 0
        if (prefs.array(forKey: "permissions") == nil)
        {
            prefs.set([], forKey: "permissions")
        }
        for el in synced.currentapps
        {
            //*********************** Change this **************************
            if (prefs.array(forKey: "permissions")!.contains(el.title) == false && prefs.array(forKey: "permissions")!.contains(el.header) == false && el.header.lowercased() != "all")
            {
                synced.currentapps.remove(at: synced.currentapps.index(of: el)!)
            }
        }
        let appData = NSKeyedArchiver.archivedData(withRootObject: synced.currentapps)
        prefs.set(appData, forKey: "userapps")
        prefs.synchronize()
        
        for element in synced.currentapps
        {
            self.appButtons.append(element)
        }
        
        AppTable.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        
        AppTable.tableFooterView = UIView(frame: CGRect.zero)
        
        
        if (!prefs.bool(forKey: "launchedbefore"))
        {
            synced = SyncNow(sync: 1, complete: {
                DispatchQueue.main.async {
                    self.prefs.set(true, forKey: "launchedbefore")
                    self.prefs.synchronize()
                }
            })
            
        } else {
            //Not first launch
        }
        var lastsync: [String] = []
        //LastSync
        let calendar: Calendar = Calendar.current
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm"
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        if (prefs.object(forKey: "lastsync") == nil) {
            lastsync.append("Jan 1, 1990")
            lastsync.append("12:00")
            prefs.set(lastsync, forKey: "lastsync")
            prefs.synchronize()
        }
        else{
            lastsync = (prefs.object(forKey: "lastsync") as? [String])!
        }
        
        let date1 = calendar.startOfDay(for: dateFormatter.date(from: lastsync[0])!)
        let date2 = calendar.startOfDay(for: Date())
        
        let flags = NSCalendar.Unit.day
        components = (calendar as NSCalendar).components(flags, from: date1, to: date2, options: []) as AnyObject
        
        if (prefs.array(forKey: "permissions") == nil)
        {
            prefs.set([], forKey: "permissions")
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        prefs.synchronize()
//        if (prefs.stringForKey("username") == "")
//        {
//            AppTable.reloadData()
//        }
        
        if (connectedToNetwork() == false)
        {
            let alert = UIAlertController(title: "No Connection", message: "You are not connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { (action: UIAlertAction!) in
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "Main")
                self.present(vc, animated: false, completion: nil)
            }))
            
            present(alert, animated: true, completion: nil)
        }
        
        if (prefs.string(forKey: "username") == "")
        {
            
            let alert = UIAlertController(title: "Log In", message: "Please log in to view apps", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Log In", style: .default, handler: { (action: UIAlertAction!) in
                
                
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "Construction")
                
                self.prefs.set("http://clydelink.sharepoint.com/apps", forKey: "selectedButton")
                
                self.show(vc , sender: vc)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: { (action: UIAlertAction!) in
                
            }))
            
            present(alert, animated: true, completion: nil)
        }
        
        if (components.day >= 7)
        {
            let alert = UIAlertController(title: "Sync Now?", message: "It has been 7 days since your last sync.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                self.synced = SyncNow(sync: 1, complete: {})
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    
    
    // MARK: - AppTable View
    
    func numberOfSections(in tableView: UITableView) -> Int {  // Informs GUI of how many sections there are
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 18
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {  // Sets up title and sets username as the title for the home menu
        
        let userDefaults = UserDefaults.standard

//        userDefaults.setObject(serviceEndpointLookup, forKey: "O365ServiceEndpoints")
//        userDefaults.synchronize()
//        if userDefaults.stringForKey("LogInUser") != nil {
//            let userEmail = userDefaults.stringForKey("LogInUser")!
//            var parts = userEmail.componentsSeparatedByString("@")
//            
//            self.test = String(parts[0])
//        }
        
        userDefaults.synchronize()
        if (userDefaults.object(forKey: "username") == nil)
        {
            userDefaults.set("", forKey: "username")
        }
        if (userDefaults.string(forKey: "username") != "")
        {
            let userEmail = userDefaults.string(forKey: "username")!
            var parts = userEmail.components(separatedBy: "@")
            self.test = String(parts[0])
        }
        else
        {
            self.test = ""
        }
        
//        if let url = NSURL(string: "https://clydewap.clydeinc.com/webservices/json/GetUserProfile?username=\(self.test)") {  // Sends POST request to the DMZ server, and prints the response string as an array
//            
//            let request = NSMutableURLRequest(URL: url)
//            
//            //        request.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding)
//            request.HTTPMethod = "POST"
//            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
//                guard error == nil && data != nil else { // check for fundamental networking error
//                    print("error=\(error)")
//                    
//                    let alertController = UIAlertController(title: "Error", message:
//                        "Could not connect to the server.", preferredStyle: UIAlertControllerStyle.Alert)
//                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
//                    self.presentViewController(alertController, animated: true, completion: nil)
//                    
//                    return
//                }
//                
//                if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 { // check for http errors
//                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                    print("response = \(response)")
//                }
//                
//                let mydata = try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) // Creates dictionary array to save results of query
//                
//                print(mydata)  // Direct response from server printed to console, for testing
//                
//                dispatch_async(dispatch_get_main_queue()) {  // Brings data from background task to main thread, loading data and populating TableView
//                    if (mydata == nil)
//                    {
//                        let alertController = UIAlertController(title: "Error", message:
//                            "Could not connect to the server.", preferredStyle: UIAlertControllerStyle.Alert)
//                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
//                        
//                        self.presentViewController(alertController, animated: true, completion: nil)
//                        return
//                    }
//                }
//                
//            }
//            task.resume()
//        }
        
        
        if (self.test != "")
        {
            return "Logged in as " + self.test
        }
        else {
            print(" \(self.test)")
            return "Not Logged In"
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        header.textLabel!
            .textColor = UIColor.black
        header.textLabel!.font = UIFont.boldSystemFont(ofSize: 12)
        header.textLabel!.frame = header.frame
        header.textLabel!.textAlignment = NSTextAlignment.left
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {  // Returns length of all the buttons needed
        if (self.appButtons.count == 0 && finalEdit == false)
        {
            NoFavorite = 1
            return 1
        } else {
            return self.appButtons.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {  // Determines which buttons should be header buttons and which chould carry on to other views
        if (NoFavorite == 1)
        {
            let cell = self.AppTable.dequeueReusableCell(withIdentifier: "BlankFavorite", for: indexPath) as! BlankFavoriteTableViewCell
            return cell
        }
            let cell = self.AppTable.dequeueReusableCell(withIdentifier: "AppCell", for: indexPath) as! AppTableViewCell
            
            cell.Title.text = self.appButtons[(indexPath as NSIndexPath).row].title
            if let icon = appButtons[(indexPath as NSIndexPath).row].icon {
                let url = URL(string: "https://clydewap.clydeinc.com/images/large/icons/\(icon)")!
                if let data = try? Data(contentsOf: url){
                    if icon != "UNDEFINED" {
                        let myImage = UIImage(data: data)
                        cell.Icon.image = myImage
                    } else {
                        cell.Icon.image = UIImage(named: "generic-icon")
                    }
                }
                else
                {
                    cell.Icon.image = UIImage(named: "generic-icon")
                }
            }
            return cell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {  // Delete the selected app
        if editingStyle == .delete {
            if (appButtons.count == 1)
            {
                finalEdit = true
            }
            for element in synced.currentapps
            {
                if (element.title == appButtons[(indexPath as NSIndexPath).row].title)
                {
                    synced.currentapps.remove(at: synced.currentapps.index(of: element)!)
                    break
                }
            }
            let appData = NSKeyedArchiver.archivedData(withRootObject: synced.currentapps)
            prefs.set(appData, forKey: "userapps")
            prefs.synchronize()
            appButtons.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {  // Allow Delete
        if (self.AppTable.isEditing && self.NoFavorite == 0) {return .delete}
        return .none
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {  // All apps are moveable
        if (self.NoFavorite == 0) {return true}
        return false
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        if (NoFavorite == 1)
        {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {  // Move apps within table
        let itemToMove = appButtons[(fromIndexPath as NSIndexPath).row]
        appButtons.remove(at: (fromIndexPath as NSIndexPath).row)
        appButtons.insert(itemToMove, at: (toIndexPath as NSIndexPath).row)
//        currentapps.removeAtIndex(fromIndexPath.row)
//        currentapps.insert(itemToMove, atIndex: toIndexPath.row)
        var fromindex: Int = 0
        for element in synced.currentapps
        {
            if (element.title == itemToMove.title) {
                fromindex = synced.currentapps.index(of: element)!
            }
        }
        
        var toindex: Int = 0
        var change: Int = 0
        
        if ((toIndexPath as NSIndexPath).row > (fromIndexPath as NSIndexPath).row)
        {
            //Down
            change = 1
        } else if ((toIndexPath as NSIndexPath).row < (fromIndexPath as NSIndexPath).row){
            //Up
            change = -1
        } else {
            change = 0
        }
        
        
        for element in synced.currentapps
        {
            if (element.title == appButtons[(fromIndexPath as NSIndexPath).row + change].title) {
                toindex = synced.currentapps.index(of: element)!
            }
        }
        synced.currentapps.remove(at: fromindex)
        if (toindex + change >= synced.currentapps.count)
        {
            change = 0
        }
        if (toindex + change < 0)
        {
            change = 0
        }
        synced.currentapps.insert(itemToMove, at: toindex + change)
        let appData = NSKeyedArchiver.archivedData(withRootObject: synced.currentapps)
        prefs.set(appData, forKey: "userapps")
        prefs.synchronize()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {  // Gives the height for each row
        if (NoFavorite == 0) {return 60.0}
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {  // Determine what to do with button press
        let buttonpressed = self.appButtons[(indexPath as NSIndexPath).row]
        var vc : AnyObject! = nil
        
        //Log in
//        connectToOffice365()
        
//        if (prefs.stringForKey("username") != nil)
//        {
            switch (buttonpressed.link)
            {
                case "vehiclesearch":
                    vc = self.storyboard!.instantiateViewController(withIdentifier: "Truck Search")
                    break;
                default:
                    vc = self.storyboard!.instantiateViewController(withIdentifier: "Construction")
                    break;
            }
            
            prefs.set(buttonpressed.URL, forKey: "selectedButton")
            prefs.set(buttonpressed.redirect, forKey: "redirectbutton")
            self.show(vc as! UIViewController, sender: vc)
            AppTable.deselectRow(at: indexPath, animated: true)
//        }
//        else
//        {
//            
//            AppTable.cellForRowAtIndexPath(indexPath)?.selected = false
//        }
        
    }
    
    @IBAction func editTable(_ sender: AnyObject) {  // Edit button pressed
        if (leftButton.title == "Edit")
        {
            AppTable.setEditing(true,animated: true)
            leftButton.title = "Add"
            rightButton.title = "Done"
        } else {
            let vc : AnyObject! = self.storyboard!.instantiateViewController(withIdentifier: "All")
            self.present(vc as! UIViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func settingsButton(_ sender: AnyObject) {  // Settings button pressed
        finalEdit = false
        if (rightButton.title == "Done")
        {
            AppTable.setEditing(false,animated: true)
            leftButton.title = "Edit"
            rightButton.title = "Settings"
            self.AppTable.reloadData()
        }
        else {
        let vc : AnyObject! = self.storyboard!.instantiateViewController(withIdentifier: "Settings")
        self.present(vc as! UIViewController, animated: true, completion: nil)
        }
    }
    
    func sortarray(_ currentapps: inout [App])
    {
        for element in currentapps
        {
            if (!element.selected)
            {
                currentapps.remove(at: currentapps.index(of: element)!)
                currentapps.append(element)
            }
        }
    }
    
    func loadUserInfo() {  // Get user's information
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(serviceEndpointLookup, forKey: "O365ServiceEndpoints")
        userDefaults.synchronize()
        
        if let userEmail = userDefaults.string(forKey: "username") {
            var parts = userEmail.components(separatedBy: "@")
            
            let uName: String = String(format:"%@", parts[0])
            
            if let url = URL(string: "https://webservices.clydeinc.com/ClydeRestServices.svc/json/ClydeWebServices/GetUserProfile") {  // Sends POST request to the DMZ server, and prints the response string as an array
                
                let request = NSMutableURLRequest(url: url)
                
                //        request.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding)
                request.httpMethod = "POST"
                let bodyData = "{UserName: \"\(uName)\"}"
                request.httpBody = bodyData.data(using: String.Encoding.utf8)
                let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                    guard error == nil && data != nil else { // check for fundamental networking error
                        print("error=\(error)")
                        self.flag = 1
                        
                        let alertController = UIAlertController(title: "Error", message:
                            "Could not connect to the server.", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                        
                        
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 { // check for http errors
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(response)")
                    }
                    
                    let mydata = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) // Creates dictionary array to save results of query
                    
                    print(" My Data: ")
                    print(mydata ?? "No Data")  // Direct response from server printed to console, for testing
                    
                    DispatchQueue.main.async {  // Brings data from background task to main thread, loading data and populating TableView
                        if (mydata == nil)
                        {
                            //                        self.activityIndicator.stopAnimating()  // Ends spinner
                            //                        self.activityIndicator.hidden = true
                            self.flag = 1
                            
                            let alertController = UIAlertController(title: "Error", message:
                                "Could not connect to the server.", preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                            
                            self.present(alertController, animated: true, completion: nil)
                            
                            return
                        }
                        
                        self.EmployeeInfo = mydata as! Array<AnyObject>  // Saves the resulting array to Employee Info Array
                        let employeedata = NSKeyedArchiver.archivedData(withRootObject: self.EmployeeInfo)
                        self.prefs.set(employeedata, forKey: "userinfo")
                        
                    }
                    
                }) 
                task.resume()
            }
            
            
        }
        
        
    }
    
    
    func connectToOffice365(_ complete: @escaping () -> Void) {
     // Connect to the service by discovering the service endpoints and authorizing
     // the application to access the user's email. This will store the user's
     // service URLs in a property list to be accessed when calls are made to the
     // service. This results in two calls: one to authenticate, and one to get the
     // URLs. ADAL will cache the access and refresh tokens so you won't need to
     // provide credentials unless you sign out.
     
     // Get the discovery client. First time this is ran you will be prompted
     // to provide your credentials which will authenticate you with the service.
     // The application will get an access token in the response.
     
         baseController.fetchDiscoveryClient
        {
            (discoveryClient) -> () in
             let servicesInfoFetcher = discoveryClient.getservices()
             
             // Call the Discovery Service and get back an array of service endpoint information
             
             let servicesTask = servicesInfoFetcher?.read
             {
                (serviceEndPointObjects:[Any]?, error:MSODataException?) -> Void in
                 let serviceEndpoints = serviceEndPointObjects as! [MSDiscoveryServiceInfo]
                 
                 if (serviceEndpoints.count > 0)
                 {
                     // Here is where we cache the service URLs returned by the Discovery Service. You may not
                     // need to call the Discovery Service again until either this cache is removed, or you
                     // get an error that indicates that the endpoint is no longer valid.
                     
                     var serviceEndpointLookup = [AnyHashable: Any]()
                     
                     for serviceEndpoint in serviceEndpoints
                     {
                        serviceEndpointLookup[serviceEndpoint.capability] = serviceEndpoint.serviceEndpointUri
                     }
                     
                     // Keep track of the service endpoints in the user defaults
                     let userDefaults = UserDefaults.standard
                     
                     userDefaults.set(serviceEndpointLookup, forKey: "O365ServiceEndpoints")
                     userDefaults.synchronize()
                     
                     DispatchQueue.main.async
                     {
                         let userEmail = userDefaults.string(forKey: "LogInUser")!
                         var parts = userEmail.components(separatedBy: "@")
                         
                         self.test = String(format:"Hi %@!", parts[0])
                        complete()
                     }
                 }
                 else
                 {
                     DispatchQueue.main.async
                     {
                        let alert: UIAlertController = UIAlertController(title: "ERROR", message: "Authentication failed. This may be because the Internet connection is offline  or perhaps the credentials are incorrect. Check the log for errors and try again.", preferredStyle: .alert)
                        //                        let alert: UIAlertController = UIAlertController(title: "Error", message: "Authentication failed. This may be because the Internet connection is offline  or perhaps the credentials are incorrect. Check the log for errors and try again.", delegate: self, cancelButtonTitle: "OK")
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                     }
                 }
                
                
             }
                
                servicesTask?.resume()
            
         }
        
     }

    
    
    
//    let url = NSURL(string: "mspbi://")
//    UIApplication.sharedApplication().openURL(url)
//    else if let itunesUrl = NSURL(string: "https://itunes.apple.com/itunes-link-to-app") where UIApplication.sharedApplication().canOpenURL(itunesUrl)
//    {
//        UIApplication.sharedApplication().openURL(itunesUrl)
//    }
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
