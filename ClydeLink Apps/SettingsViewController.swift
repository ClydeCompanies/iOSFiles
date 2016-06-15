//
//  SettingsViewController.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 5/16/16.
//

import UIKit

class SettingsViewController: UIViewController {  // Basics of Settings screen, will be added to when decision has been made as to how we must proceed with the development of the screen

    @IBOutlet weak var versionNumber: UILabel!
    @IBOutlet weak var buildNumber: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    let prefs = NSUserDefaults.standardUserDefaults()  // Current user preferences
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            versionNumber.text = version
        }
        if let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            buildNumber.text = build
        }
        var uName: String = "Username"
        if (prefs.stringForKey("username") != nil)
        {
            uName = prefs.stringForKey("username")!
        }
        userName.text = uName
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func SignOut(sender: AnyObject) {
        prefs.setObject("", forKey: "username")
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("Main")
        self.presentViewController(vc as! UIViewController, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
