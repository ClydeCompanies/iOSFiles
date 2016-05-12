//
//  ViewController.swift
//  ClydeLink Apps
//
//  Created by J J Feddock on 5/9/16.
//  Copyright © 2016 XLR8 Development LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        View1.hidden = true
        View2.hidden = true
        View3.hidden = true
        View4.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet var MainView: UIView!
    
    @IBOutlet weak var FirstButton: UIButton!
    
    @IBAction func Test(sender: AnyObject) {
        if (View1.hidden == true)
        {
            
            AccCreditButton.selected = true
            view.bringSubviewToFront(View1)
            View1.hidden = false
            
            EmployeeApps.enabled = false
            Equipment.enabled = false
            HRApps.enabled = false
        }
        else
        {
            AccCreditButton.selected = false
            View1.hidden = true
            view.sendSubviewToBack(View1)
            
            AccCreditButton.enabled = true
            EmployeeApps.enabled = true
            Equipment.enabled = true
            HRApps.enabled = true
        }
    }
    
    
    @IBAction func EmployeeButtonPush(sender: AnyObject) {
        if (View2.hidden == true)
        {
            EmployeeApps.selected = true
            view.bringSubviewToFront(View2)
            View2.hidden = false
            
            AccCreditButton.enabled = false
            Equipment.enabled = false
            HRApps.enabled = false
        }
        else{
            EmployeeApps.selected = false
            View2.hidden = true
            view.sendSubviewToBack(View2)
            
            AccCreditButton.enabled = true
            EmployeeApps.enabled = true
            Equipment.enabled = true
            HRApps.enabled = true
        }
    }
    
    @IBAction func EquipmentButtonPush(sender: AnyObject) {
        if (View3.hidden == true)
        {
            Equipment.selected = true
            view.bringSubviewToFront(View3)
            View3.hidden = false
            
            AccCreditButton.enabled = false
            EmployeeApps.enabled = false
            HRApps.enabled = false
        }
        else{
            Equipment.selected = false
            View3.hidden = true
            view.sendSubviewToBack(View3)
            
            AccCreditButton.enabled = true
            EmployeeApps.enabled = true
            Equipment.enabled = true
            HRApps.enabled = true
        }

    }
    
    @IBAction func HRButtonPress(sender: AnyObject) {
        if (View4.hidden == true)
        {
            HRApps.selected = true
            view.bringSubviewToFront(View4)
            View4.hidden = false
            
            AccCreditButton.enabled = false
            EmployeeApps.enabled = false
            Equipment.enabled = false
        }
        else{
            HRApps.selected = false
            View4.hidden = true
            view.sendSubviewToBack(View4)
            
            AccCreditButton.enabled = true
            EmployeeApps.enabled = true
            Equipment.enabled = true
            HRApps.enabled = true
        }
    }
    
    @IBOutlet weak var HRApps: UIButton!
    
    @IBOutlet weak var View4: UIView!
    
    @IBOutlet weak var Equipment: UIButton!
    
    
    @IBOutlet weak var View3: UIView!
    
    @IBOutlet weak var View2: UIView!
    
    @IBOutlet weak var EmployeeApps: UIButton!
    
    @IBOutlet weak var View1: UIView!
    
    @IBOutlet weak var Accounting: UIButton!

    @IBOutlet weak var Credit: UIButton!
    
    @IBOutlet weak var AccCreditButton: UIButton!
    
}

