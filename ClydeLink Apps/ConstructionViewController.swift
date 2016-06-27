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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadAddressURL()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var Back: UIButton!
    
    // MARK: - Web View
//    
//    func webViewDidStartLoad(webView: UIWebView) {
//
//    }
    func loadAddressURL() {
        let link = prefs.stringForKey("selectedButton")
        print(link)
        let requestURL = NSURL(string: link!)
        let request = NSURLRequest(URL: requestURL!)
        WebView.loadRequest(request)
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
