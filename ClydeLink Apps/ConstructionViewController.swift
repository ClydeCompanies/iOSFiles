//
//  ConstructionViewController.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 5/10/16.
//

import UIKit

class ConstructionViewController: UIViewController, UIWebViewDelegate {  // Simple ViewController designed to be a placeholder for other HTML queries and Segues that will be developed in the future

    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var WebView: UIWebView!
    let prefs = NSUserDefaults.standardUserDefaults()  // Current user preferences
    @IBOutlet weak var NavBar: UINavigationBar!
    
    var tempUser: String = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadAddressURL()
    }
    
    override func viewDidAppear(animated: Bool) {
        if ((WebView.request?.URL?.absoluteString.containsString("http")) == nil)
        {
            ActivityIndicator.stopAnimating()
            
            let vc : UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Main")
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var Back: UIButton!
    
    // MARK: - Web View
//    
    func webViewDidStartLoad(webView: UIWebView) {  // Start loading web page
        if (WebView.request != nil)
        {
//            print("URL = " + webView.request!.URL!.absoluteString)
        }
        ActivityIndicator.startAnimating()
        
    }
    
    func loadAddressURL() {
        let link = prefs.stringForKey("selectedButton")
//        print(link)
        let requestURL = NSURL(string: link!)
        let request = NSURLRequest(URL: requestURL!)
        WebView.loadRequest(request)
        
        
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if (WebView.request != nil)
        {
//            print("URL = " + webView.request!.URL!.absoluteString)
//
//            if (webView.request!.URL?.absoluteString != "login.microsoftonline.com")
//            {
//                prefs.setObject("", forKey: "username")
//            }
        }
        
//        if (request.URL?.absoluteString == "fs.clydeinc.com")
//        {
//            
//            let value: NSString = WebView.stringByEvaluatingJavaScriptFromString("document.getElementById('cred_userid_inputtext').value")!;
//            
//            if (prefs.stringForKey("username") == "")
//            {
//                prefs.setObject(value, forKey: "username")
//            }
//            print(prefs.objectForKey("username"))
//        }
        
//        if (request.URL?.absoluteString == "fs.clydeinc.com")
//        {
//            prefs.setObject("", forKey: "username")
//        }
        return true
    }
    
    
    func webViewDidFinishLoad(webView: UIWebView) {
//        print("Response = " + webView.request!.URL!.absoluteString)
//        let link = prefs.stringForKey("selectedButton")
        if (webView.request!.URL!.absoluteString.containsString("fs.clydeinc.com"))
        {
            //get the username employee is trying to login with from the url
            let urlComponents = NSURLComponents(string: webView.request!.URL!.absoluteString)
            let queryItems = urlComponents?.queryItems
            let param1 = queryItems?.filter({$0.name == "username"}).first
//            print("PARAM: ")
//            print(param1)
            if (param1 != nil)
            {
                tempUser = (param1?.value!)!
            }
          
            prefs.synchronize()
        }
        if (webView.request!.URL!.absoluteString.containsString("https://clydelink.sharepoint.com/apps") && prefs.stringForKey("username") == "")
        {
            print("SAVED")
            prefs.setObject(tempUser, forKey: "username")
            let userEmail = tempUser
            var parts = userEmail.componentsSeparatedByString("@")
            tempUser = String(parts[0])
            
            
            if let url = NSURL(string: "https://clydewap.clydeinc.com/webservices/json/GetUserProfile?username=\(tempUser)&token=tRuv%5E:%5D56NEn61M5vl3MGf/5A/gU%3C@") {  // Sends POST request to the DMZ server, and prints the response string as an array
                
                let request = NSMutableURLRequest(URL: url)
                
                //        request.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding)
                request.HTTPMethod = "POST"
                let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                    guard error == nil && data != nil else { // check for fundamental networking error
                        print("error=\(error)")
//                        self.flag = 1
                        
                        let alertController = UIAlertController(title: "Error", message:
                            "Could not connect to the server.", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        
                        return
                    }
                    
                    if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 { // check for http errors
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(response)")
                    }
                    
                    let mydata = try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) // Creates dictionary array to save results of query
                    
                    print(" My Data: ")
                    print(mydata)  // Direct response from server printed to console, for testing
                    
                    dispatch_async(dispatch_get_main_queue()) {  // Brings data from background task to main thread, loading data and populating TableView
                        if (mydata == nil)
                        {
                            //                        self.activityIndicator.stopAnimating()  // Ends spinner
                            //                        self.activityIndicator.hidden = true
//                            self.flag = 1
                            
                            let alertController = UIAlertController(title: "Error", message:
                                "Could not connect to the server.", preferredStyle: UIAlertControllerStyle.Alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                            
                            return
                        }
                        
                        let EmployeeInfo = mydata as! Array<AnyObject>  // Saves the resulting array to Employee Info Array
                        let employeedata = NSKeyedArchiver.archivedDataWithRootObject(EmployeeInfo)
                        self.prefs.setObject(employeedata, forKey: "userinfo")
                        let perm = EmployeeInfo[0]["Permissions"]
                        self.prefs.setObject(perm, forKey: "permissions")
                        print(self.prefs.arrayForKey("permissions"))
                        self.prefs.synchronize()
                        
                        
                        var permissions: [String] = []
                        let rawpermissions = self.prefs.arrayForKey("permissions")
                        if (rawpermissions == nil)
                        {
                            permissions.append("New Hire") /*= ["Vehicle Search", "New Hire", "Fleet Search"]*/
                        } else {
                            if (!(rawpermissions is [String])) {
                                for permission in rawpermissions! {
                                    print(permission)
                                    permissions.append((permission["Group"]) as! String)
                                }
                            }
                        }
                        self.prefs.setObject(permissions, forKey: "permissions")
                        
                        print(self.prefs.arrayForKey("permissions"))
                        
                    }
                    
                }
                task.resume()
            }
        }
        
//        else{
//            prefs.setObject("", forKey: "username")
//        }
        
        self.ActivityIndicator.stopAnimating()
        
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
