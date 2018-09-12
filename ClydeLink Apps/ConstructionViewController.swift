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
    @objc let prefs = UserDefaults.standard  // Current user preferences
    @IBOutlet weak var NavBar: UINavigationBar!
    
    @objc var tempUser: String = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)?)
    {
        if self.presentedViewController != nil {
            super.dismiss(animated: flag, completion: completion)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBOutlet weak var Back: UIButton!
    
    func webViewDidStartLoad(_ webView: UIWebView) {  // Start loading web page
        ActivityIndicator.startAnimating()
    }
    
    @objc func loadAddressURL() {
        var link = prefs.string(forKey: "selectedButton")
        
        if link == ("http://www.clydelink.com/employeeresources/Pages/Policies.aspx?CID=") {
            link = "https://www.clydelink.com/employeeresources/Pages/Policies.aspx?CID="
        }
        
        if link == ("https://www.clydelink.com/employeeresources/Pages/Policies.aspx?CID=") {
            link = link! + prefs.string(forKey: "Company")!
        }
        
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
                print("No redirect button")
            }
            
        }
        
        
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        return true
    }
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if (webView.request!.url!.absoluteString.contains("fs.clydeinc.com"))
        {
            // Get the username employee is trying to login with from the url
            let urlComponents = URLComponents(string: webView.request!.url!.absoluteString)
            let queryItems = urlComponents?.queryItems
            let param1 = queryItems?.filter({$0.name == "username"}).first

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
            prefs.set(tempUser, forKey: "username")
            
            if (webView.request!.url!.absoluteString.contains("clydelink.sharepoint.com/apps"))
            {
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "Main")
                _ = SyncNow(sync: 1, complete: {
                    DispatchQueue.main.async {
                    }
                })
                self.show(vc, sender: vc)
            }
        }
        
        self.ActivityIndicator.stopAnimating()
        
    }
    
}
