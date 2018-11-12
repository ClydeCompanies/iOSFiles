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
    
    @objc var test: String = "TEST" // Used for receiving username
    @objc var EmployeeInfo: Array<AnyObject> = []  // Holds information about current user
    @objc var flag: Int = 0  // Saves any errors as 1
    @objc var synced: SyncNow = SyncNow()
    
    
    @objc var appButtons: Array = [App]()  // Holds clickable buttons
    
    @objc var NoFavorite: Int = 0
    @objc var finalEdit: Bool = false
    @objc var AppCount: Int = 0  // Increments and controls distribution of array data to UITable
    
    @objc let prefs = UserDefaults.standard  // Current user preferences
    
    @objc var serviceEndpointLookup = NSMutableDictionary()
    @objc var components: AnyObject = "" as AnyObject
    
    
    
    override func viewDidLoad() {  // Runs when the view loads
        super.viewDidLoad()
        
        let webView = UIWebView()
        webView.loadHTMLString("<html></html>", baseURL: nil)
        var appName: String? = webView.stringByEvaluatingJavaScript(from: "navigator.appName")
        // Netscape
        let userAgent: String? = webView.stringByEvaluatingJavaScript(from: "navigator.userAgent")
        prefs.set(userAgent, forKey: "userAgent")
        prefs.synchronize()
        
        synced.updateCurrentApps({})
        
        finalEdit = false
        if (prefs.string(forKey: "username") == "Loading...")
        {
            prefs.set("", forKey: "username")
            prefs.set("", forKey: "fullname")
        }
        test = "TEST"
        
        
        if (prefs.bool(forKey: "NeedsUpdate"))
        {
            prefs.set(false, forKey: "NeedsUpdate")
            let alert = UIAlertController(title: "Update Available", message: "There is an update available, would you like to install it?", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                
            }))
            
            alert.addAction(UIAlertAction(title: "Later", style: .cancel, handler: { (action: UIAlertAction!) in
                
            }))
            
            
            present(alert, animated: true, completion: nil)
        }
        
        NoFavorite = 0
        if (prefs.array(forKey: "permissions") == nil)
        {
            prefs.set([], forKey: "permissions")
        }
        for el in synced.currentapps
        {
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
        
        AppTable.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        
        AppTable.tableFooterView = UIView(frame: CGRect.zero)
        
        
        if (!prefs.bool(forKey: "launchedbefore"))
        {
            synced = SyncNow()
            self.prefs.set(true, forKey: "launchedbefore")
            self.prefs.synchronize()
            
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
        
        if (connectedToNetwork() == false)
        {
            let alert = UIAlertController(title: "No Connection", message: "You are not connected to the internet.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { (action: UIAlertAction!) in
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "Main")
                self.present(vc, animated: false, completion: nil)
            }))
            
            present(alert, animated: true, completion: nil)
        }
        
        if (prefs.string(forKey: "fullname") == "")
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
    
    @objc func connectedToNetwork() -> Bool {
        
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
        
        userDefaults.synchronize()
        if (userDefaults.object(forKey: "fullname") == nil)
        {
            userDefaults.set("", forKey: "fullname")
        }
        if (userDefaults.string(forKey: "fullname") != "")
        {
            let fullname = userDefaults.string(forKey: "fullname")!
            self.test = String(fullname)
        }
        else
        {
            self.test = ""
        }
        
        
        if (self.test != "")
        {
            return "Logged in as " + self.test
        }
        else {
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
            let url = URL(string: "https://cciportal.clydeinc.com/images/large/icons/\(icon)")!
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {  // Delete the selected app
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
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {  // Allow Delete
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
    
    @objc func loadUserInfo() {  // Get user's information
        
        EmployeeInfo = synced.EmployeeInfo
        
    }
}
