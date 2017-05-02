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
//        let link = "https://clydelink.sharepoint.com/_api/Web/CurrentUser"
        print(link ?? "No Link")
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
        print("Debug: " + webView.request!.url!.absoluteString)
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
        
        if (webView.request!.url!.absoluteString.contains("clydelink")) {
            
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
            prefs.set(cookieArray, forKey: "cookieArray")
            
        }
        
        if (webView.request!.url!.absoluteString.contains("clydelink.sharepoint.com") && prefs.string(forKey: "username") == "")
        {
            print("SAVED")
            prefs.set(tempUser, forKey: "username")
            
//            var synced: SyncNow = SyncNow(sync: 1, complete: {})
            
            
            if (webView.request!.url!.absoluteString.contains("clydelink.sharepoint.com/apps"))
            {
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "Main")
                self.show(vc, sender: vc)
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
