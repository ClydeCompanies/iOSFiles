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
    let prefs = UserDefaults.standard  // Current user preferences
    @IBOutlet weak var NavBar: UINavigationBar!
    
    var tempUser: String = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadAddressURL()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if ((WebView.request?.url?.absoluteString.contains("http")) == nil)
        {
            ActivityIndicator.stopAnimating()
            
            
            
            let vc : UIViewController = self.storyboard!.instantiateViewController(withIdentifier: "Main")
            self.present(vc, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var Back: UIButton!
    
    // MARK: - Web View
//    
    func webViewDidStartLoad(_ webView: UIWebView) {  // Start loading web page
        if (WebView.request != nil)
        {
//            print("URL = " + webView.request!.URL!.absoluteString)
        }
        ActivityIndicator.startAnimating()
        
    }
    
    func loadAddressURL() {
        let link = prefs.string(forKey: "selectedButton")
        print(link)
        //        print(link)
        let requestURL = URL(string: link!)
        let request = URLRequest(url: requestURL!)

        if (UIApplication.shared.canOpenURL(requestURL!))
        {
            WebView.loadRequest(request)

        } else {

            print("App not installed")
            
            if (prefs.string(forKey: "redirectbutton") != "") {
                UIApplication.shared.openURL(URL(string: prefs.string(forKey: "redirectbutton")!)!)
            } else {
                //**ErrorMessage**
            }
            
        }
//        WebView.loadRequest(request)
        
        
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if (WebView.request != nil)
        {
//            print("URL = " + webView.request!.URL!.absoluteString)
//
//            if (webView.request!.URL?.absoluteString != "login.microsoftonline.com")
//            {
//                prefs.setObject("", forKey: "username")
//            }
        }
        
        return true
    }
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
//        print("Response = " + webView.request!.URL!.absoluteString)
//        let link = prefs.stringForKey("selectedButton")
        if (webView.request!.url!.absoluteString.contains("fs.clydeinc.com"))
        {
            //get the username employee is trying to login with from the url
            let urlComponents = URLComponents(string: webView.request!.url!.absoluteString)
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
        if (webView.request!.url!.absoluteString.contains("https://clydelink.sharepoint.com/apps") && prefs.string(forKey: "username") == "")
        {
            print("SAVED")
            prefs.set(tempUser, forKey: "username")
            let userEmail = tempUser
            var parts = userEmail.components(separatedBy: "@")
            tempUser = String(parts[0])
            
            
            if let url = URL(string: "https://webservices.clydeinc.com/ClydeRestServices.svc/json/ClydeWebServices/GetUserProfile?username=\(tempUser)&token=tRuv%5E:%5D56NEn61M5vl3MGf/5A/gU%3C@") {  // Sends POST request to the DMZ server, and prints the response string as an array
                
                let request = NSMutableURLRequest(url: url)
                
                //        request.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding)
                request.httpMethod = "POST"
                let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                    guard error == nil && data != nil else { // check for fundamental networking error
                        print("error=\(error)")
//                        self.flag = 1
                        
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
                    print(mydata)  // Direct response from server printed to console, for testing
                    
                    DispatchQueue.main.async {  // Brings data from background task to main thread, loading data and populating TableView
                        if (mydata == nil)
                        {
                            //                        self.activityIndicator.stopAnimating()  // Ends spinner
                            //                        self.activityIndicator.hidden = true
//                            self.flag = 1
                            
                            let alertController = UIAlertController(title: "Error", message:
                                "Could not connect to the server.", preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                            
                            self.present(alertController, animated: true, completion: nil)
                            
                            return
                        }
                        
                        let EmployeeInfo = mydata as! Array<AnyObject>  // Saves the resulting array to Employee Info Array
                        let employeedata = NSKeyedArchiver.archivedData(withRootObject: EmployeeInfo)
                        self.prefs.set(employeedata, forKey: "userinfo")
                        
                        
                        
                        self.prefs.synchronize()
                        var permissions: [String] = []
                        if (!(EmployeeInfo[0]["Permissions"] is NSNull)) {
                            let rawpermissions = EmployeeInfo[0]["Permissions"] as! Array<AnyObject>
                            if (!(rawpermissions is [String])) {
                                for permission in rawpermissions {
                                    print(permission)
                                    permissions.append((permission["Group"]) as! String)
                                }
                            }
                            self.prefs.set(permissions, forKey: "permissions")
                            
                            
                        } else {
                            self.prefs.set([],forKey: "permissions")
                        }
                        
                    }
                    
                }) 
                task.resume()
            }
            
            
            
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "Main")
            self.show(vc, sender: vc)
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
