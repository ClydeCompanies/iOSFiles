//
//  AddViewController.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 6/5/16.
//

import UIKit
var beenHere = false
var pathLookup = [String]()

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
    var AppStore: [App] = []  // Holds all available Apps
    var synced: SyncNow = SyncNow()
    var AppHeaders: [String] = []  // Holds headers
    var AppNumber: [Int] = [0]  // Holds number of apps in each section
    var sectionOpen: [Bool] =  [false]  // Holds values for which sections are expanded
    
    var flag: Int = 0  // Keeps track of any errors
    
    var serviceEndpointLookup = NSMutableDictionary()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        synced = SyncNow()
        AppTable.reloadData()
        
        AppHeaders = (prefs.array(forKey: "headers") as? [String])!
        
        for _ in AppHeaders
        {
            sectionOpen.append(false)
            NoApps.append(0)
        }
        
        
        AppTable.tableFooterView = UIView(frame: CGRect.zero)
        var apps: Int = 0
        var currentApp: String = ""
        for element in synced.AppStore {  // Load app numbers
            if (currentApp == "")
            {
                currentApp = element.header
                apps+=1
                //consider changing to apps++
                continue
            }
            if (element.header == currentApp)
            {
                //consider changing to apps++
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
        synced = SyncNow()
        
        if (NoApps[(indexPath as NSIndexPath).section] == 1)
        {
            let cell = self.AppTable.dequeueReusableCell(withIdentifier: "BlankAddCell", for: indexPath) as! BlankAddTableViewCell
            
            return cell
        }
        
        var realIndexPath = pathLookup.index(of: AppHeaders[indexPath[0]])!
        
        if ((indexPath as NSIndexPath).row == 0)
        {
            extra = 0
        }

        var appCell: App = synced.AppStore[(indexPath as NSIndexPath).row + extra + AppNumber[realIndexPath]]
        if (appCell.header.lowercased() != "all") {
            
            while (prefs.array(forKey: "permissions")!.contains(appCell.title) == false && prefs.array(forKey: "permissions")!.contains(appCell.header) == false)
            {
                extra += 1
                appCell = synced.AppStore[(indexPath as NSIndexPath).row + extra + AppNumber[realIndexPath]]
            }
        }
        let cell = self.AppTable.dequeueReusableCell(withIdentifier: "AppCell", for: indexPath) as! AddTableViewCell
        cell.Title.text = appCell.title
        cell.accessoryType = UITableViewCellAccessoryType.none;
        if let icon = appCell.icon {
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
            pic.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
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
        
        var invalidAppHeaderIndexes:[Int] = [Int]()
        for headerTitle in AppHeaders {
            var count: Int = 0
            for app in synced.AppStore
            {
                let isHeaderTitle:Bool = app.header == headerTitle
                let prefsPermissionsHasTitle = prefs.array(forKey: "permissions")!.contains(app.title)
                let prefsPermissionsHasHeader = prefs.array(forKey: "permissions")!.contains(app.header)
                let headerIsAll:Bool = app.header.lowercased() == "all"
                
                //*********************** Change this **************************
                if (isHeaderTitle && (prefsPermissionsHasTitle || prefsPermissionsHasHeader || headerIsAll))
                {
                    count += 1 // found valid app (?)
                }
            }
            
            // If app isn't valid
            if count == 0 {
                invalidAppHeaderIndexes.insert(AppHeaders.index(of: headerTitle)!, at: 0)
                //invalidAppHeaderIndexes.append(AppHeaders.index(of: headerTitle)!)
            }
        }
        
        if (!beenHere && AppHeaders.count != 0) {
            pathLookup = AppHeaders
            beenHere = true
        }
        // Remove all the invalid ones
        for invalidIndex in invalidAppHeaderIndexes {
            AppHeaders.remove(at: invalidIndex)
        }
        
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
}



