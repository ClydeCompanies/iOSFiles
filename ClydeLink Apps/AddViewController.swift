//
//  AddViewController.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 6/5/16.
//

import UIKit


extension Array {
    func contains<T>(_ obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

class AddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var AppTable: UITableView!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    
    var test: String = "TEST"  // Holds users name
    
    var AppCount: Int = 0  // Increments and controls distribution of array data to UITable
    
    var NoApps: [Int] = [0]
    
    var extra: Int = 0
    
    let prefs = UserDefaults.standard  // Current user preferences
    //    var currentapps: Array = [App]()  // Holds user's selected apps
    //    var Apps: Array = [AnyObject]()  // Holds raw data for AppStore
    var AppStore: [App] = []  // Holds all available Apps
    var synced: SyncNow = SyncNow()
    var AppHeaders: [String] = []  // Holds headers
    var AppNumber: [Int] = [0]  // Holds number of apps in each section
    var sectionOpen: [Bool] =  [false]  // Holds values for which sections are expanded
    
    var flag: Int = 0  // Keeps track of any errors
    
    var baseController = Office365ClientFetcher()
    var serviceEndpointLookup = NSMutableDictionary()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadApps()
        synced = SyncNow()
        
//        NoApps = 0
        AppHeaders = (prefs.array(forKey: "headers") as? [String])!
        
        for _ in AppHeaders
        {
            sectionOpen.append(false)
            NoApps.append(0)
        }
        
        
        AppTable.tableFooterView = UIView(frame: CGRect.zero)
        var apps: Int = 0
        var currentApp: String = ""
//        print(synced.AppStore.count)
        for element in synced.AppStore {  // Load app numbers
            if (currentApp == "")
            {
                currentApp = element.header
                apps+=1
                continue
            }
            if (element.header == currentApp)
            {
                apps += 1
                continue
            }
            else
            {
                self.AppNumber.append(self.AppNumber.last! + apps)
                currentApp = element.header
                apps = 1
                continue
            }
        }
        //        print(AppNumber)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func DoneSelected(_ sender: AnyObject) {  // Done button selected
        //        let appData = NSKeyedArchiver.archivedDataWithRootObject(currentapps)
        //        prefs.setObject(appData, forKey: "userapps")
        //        prefs.synchronize()
        
        let vc : UIViewController = self.storyboard!.instantiateViewController(withIdentifier: "Main")
        //vc.setEditing(true, animated: true)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func addButtonClicked(_ sender: AnyObject) {  // Add button clicked for an app
        loadApps()
        self.AppTable.reloadData()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    // MARK: Table View Functions
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {  // Disallow Delete
        return .none
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (NoApps[(indexPath as NSIndexPath).section] == 1)
        {
            return 40.0
        }
        else
        {
            return 60.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {  // Returns each cell
        //        self.ActivityIndicator.stopAnimating()
        //            loadApps()
        synced = SyncNow()
        
        if (NoApps[(indexPath as NSIndexPath).section] == 1)
        {
            let cell = self.AppTable.dequeueReusableCell(withIdentifier: "BlankAddCell", for: indexPath) as! BlankAddTableViewCell
            
            return cell
        }
        
        
        if ((indexPath as NSIndexPath).row == 0)
        {
            extra = 0
        }
        var appCell: App = synced.AppStore[(indexPath as NSIndexPath).row + extra + AppNumber[(indexPath as NSIndexPath).section]]
        //*********************** Change this **************************
//        print("* " + String(appCell.order) + ", " + appCell.header + ", " + appCell.title + " *")
        if (appCell.header.lowercased() != "all") {
            
            while (prefs.array(forKey: "permissions")!.contains(appCell.title) == false && prefs.array(forKey: "permissions")!.contains(appCell.header) == false)
            {
                extra += 1
                appCell = synced.AppStore[(indexPath as NSIndexPath).row + extra + AppNumber[(indexPath as NSIndexPath).section]]
            }
        }
        let cell = self.AppTable.dequeueReusableCell(withIdentifier: "AppCell", for: indexPath) as! AddTableViewCell
        cell.Title.text = appCell.title
        cell.accessoryType = UITableViewCellAccessoryType.none;
        if let icon = appCell.icon {
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
        var found: Bool = false
        for el in synced.currentapps
        {
            if (el.title == appCell.title)
            {
                found = true
                break
            }
        }
        if found {
            cell.addButton.isHidden = true
        }
        else
        {
            cell.addButton.isHidden = false
        }
        AppCount += 1
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {  // Returns number of cells in each category
        var count: Int = 0
        for el in synced.AppStore
        {
            //*********************** Change this **************************
            if (el.header == AppHeaders[section] && (prefs.array(forKey: "permissions")!.contains(el.title) || prefs.array(forKey: "permissions")!.contains(el.header) || el.header.lowercased() == "all"))
            {
                count += 1
            }
        }
        if (sectionOpen[section] == false)
        {
            count = 0
        }
        if (count != 0)
        {
            NoApps[section] = 0
        }
        if (count == 0 && sectionOpen[section] == true)
        {
            count = 1
            NoApps[section] = 1
        }
        
        
        return count
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        for view in header.subviews{
            if (view is UIImageView)
            {
                view.removeFromSuperview()
            }
        }
        
        header.textLabel!
            .textColor = UIColor.black
        header.textLabel!.font = UIFont.boldSystemFont(ofSize: 20)
        header.textLabel!.frame = header.frame
        header.textLabel!.textAlignment = NSTextAlignment.center
        header.textLabel!.text = AppHeaders[section]
        let pic = UIImageView()
        pic.frame = CGRect(x: header.frame.width - 40, y: 10, width: 25, height: 25)
        pic.image = UIImage(named: "down-arrow")
        pic.removeFromSuperview()
        
        let uppic = UIImageView()
        uppic.frame = CGRect(x: header.frame.width - 40, y: 10, width: 25, height: 25)
        uppic.image = UIImage(named: "up-arrow")
        uppic.removeFromSuperview()
        
        let btn = UIButton(type: UIButtonType.custom) as UIButton
        btn.frame = CGRect(x: 0, y: 0, width: header.frame.width, height: header.frame.height)
        btn.addTarget(self, action: #selector(AddViewController.pressed), for: .touchUpInside)
        btn.setTitleColor(UIColor.black, for: UIControlState())
        btn.tag = section
        
        if (sectionOpen[section])
        {
            header.addSubview(pic)
            pic.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(M_PI)) / 180.0)
        }
        else
        {
            header.addSubview(pic)
        }
        
        
        header.addSubview(btn)
        
        
    }
    
    func pressed(_ sender: UIButton)
    {  // Opens each section
        sectionOpen[sender.tag] = !sectionOpen[sender.tag]
        self.AppTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {  // Informs GUI of how many sections there are
        return AppHeaders.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {  // Determine what to do with button press
       
            AppTable.deselectRow(at: indexPath, animated: true)
       
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {  // Sets up title and sets username as the title for the home menu
        var uName: String = ""
        if (prefs.string(forKey: "username") != nil && prefs.string(forKey: "username") != "")
        {
            uName = "Logged in as " + prefs.string(forKey: "username")!
        } else {
            uName = "Not logged in"
        }
        
        return uName
    }
    
    func loadApps() {  // Get all apps
        synced = SyncNow()
        
        AppTable.reloadData()
    }
    
    
    
    func connectToOffice365() {
        // Connect to the service by discovering the service endpoints and authorizing
        // the application to access the user's email. This will store the user's
        // service URLs in a property list to be accessed when calls are made to the
        // service. This results in two calls: one to authenticate, and one to get the
        // URLs. ADAL will cache the access and refresh tokens so you won't need to
        // provide credentials unless you sign out.
        
        // Get the discovery client. First time this is ran you will be prompted
        // to provide your credentials which will authenticate you with the service.
        // The application will get an access token in the response.
        
        baseController.fetchDiscoveryClient { (discoveryClient) -> () in
            let servicesInfoFetcher = discoveryClient.getservices()
            
            // Call the Discovery Service and get back an array of service endpoint information
            
            let servicesTask = servicesInfoFetcher?.read{(serviceEndPointObjects:[Any]?, error:MSODataException?) -> Void in
                let serviceEndpoints = serviceEndPointObjects as! [MSDiscoveryServiceInfo]
                
                if (serviceEndpoints.count > 0) {
                    // Here is where we cache the service URLs returned by the Discovery Service. You may not
                    // need to call the Discovery Service again until either this cache is removed, or you
                    // get an error that indicates that the endpoint is no longer valid.
                    
                    var serviceEndpointLookup = [AnyHashable: Any]()
                    
                    for serviceEndpoint in serviceEndpoints {
                        serviceEndpointLookup[serviceEndpoint.capability] = serviceEndpoint.serviceEndpointUri
                    }
                    
                    // Keep track of the service endpoints in the user defaults
                    let userDefaults = UserDefaults.standard
                    
                    userDefaults.set(serviceEndpointLookup, forKey: "O365ServiceEndpoints")
                    userDefaults.synchronize()
                    
                    DispatchQueue.main.async {
                        let userEmail = userDefaults.string(forKey: "LogInUser")!
                        var parts = userEmail.components(separatedBy: "@")
                        
                        self.test = String(format:"Hi %@!", parts[0])
                    }
                }
                    
                else {
                    DispatchQueue.main.async {
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
    
    
    
    
}



