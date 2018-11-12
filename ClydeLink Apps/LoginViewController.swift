//
//  LoginViewController.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 5/14/16.
//

import UIKit

class LoginViewController: UIViewController {  // Basic ViewController for the Login Screen, will be added to when necessary to include implementation for Authentication. Currently stores username entered for use later in the application.

    @objc let prefs = UserDefaults.standard  // Where we are saving the user defaults in the Application data on the phone
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status and dismiss the keyboard
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func LoginButtonPress(_ sender: AnyObject) {  // Transitions to new VC without any Authentication, simply for ease of testing until we solidify the means of auth that we are going to use
        
        let vc : AnyObject! = self.storyboard!.instantiateViewController(withIdentifier: "Main")
        self.show(vc as! UIViewController, sender: vc)
        
        
        
        prefs.set(Username.text, forKey: "fullname")
        
    }
    
    @IBOutlet weak var Username: UITextField!
    
    @IBOutlet weak var Password: UITextField!
    
    
}
