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
    
    let buffer: CGFloat = 23

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet var MainView: UIView!
    
    @IBOutlet weak var FirstButton: UIButton!
    
    @IBAction func Test(sender: AnyObject) {
        if (View1.hidden == true)
        {
            if (View1.hidden == false) {
                EmployeeConst.constant = buffer
                View1.hidden = true
                AccCreditButton.selected = false
            }
            if (View2.hidden == false){
                EquipmentConst.constant = buffer
                View2.hidden = true
                EmployeeApps.selected = false
            }
            if (View3.hidden == false){
                HRAppsConst.constant = buffer
                View3.hidden = true
                Equipment.selected = false
            }
            if (View4.hidden == false)
            {
                HRApps.selected = false
                View4.hidden = true
            }
            
            EmployeeConst.constant = View1.frame.size.height + 10
            
            EmployeeApps.updateConstraintsIfNeeded()
            view.bringSubviewToFront(View1)
            View1.hidden = false
            
            
        }
        else
        {
            if (EmployeeConst.constant > 50) {
                EmployeeConst.constant = buffer}
            if (EquipmentConst.constant > 50){
                EquipmentConst.constant = buffer
            }
            if (HRAppsConst.constant > 50){
                HRAppsConst.constant = buffer
            }
            
            View1.frame.size.height = 30
            AccCreditButton.selected = false
            View1.hidden = true
            view.sendSubviewToBack(View1)
            
            
        }
    }
    
    
    @IBAction func EmployeeButtonPush(sender: AnyObject) {
        if (View2.hidden == true)
        {
            if (View1.hidden == false) {
                EmployeeConst.constant = buffer
                View1.hidden = true
                AccCreditButton.selected = false
            }
            if (View2.hidden == false){
                EquipmentConst.constant = buffer
                View2.hidden = true
                EmployeeApps.selected = false
            }
            if (View3.hidden == false){
                HRAppsConst.constant = buffer
                View3.hidden = true
                Equipment.selected = false
            }
            if (View4.hidden == false)
            {
                HRApps.selected = false
                View4.hidden = true
            }
            
            EquipmentConst.constant = View2.frame.size.height + 10
            
            view.bringSubviewToFront(View2)
            View2.hidden = false
            
            
        }
        else{
            EquipmentConst.constant = buffer
            
            EmployeeApps.selected = false
            View2.hidden = true
            view.sendSubviewToBack(View2)
            
            
        }
    }
    
    @IBAction func EquipmentButtonPush(sender: AnyObject) {
        if (View3.hidden == true)
        {
            if (View1.hidden == false) {
                EmployeeConst.constant = buffer
                View1.hidden = true
                AccCreditButton.selected = false
            }
            if (View2.hidden == false){
                EquipmentConst.constant = buffer
                View2.hidden = true
                EmployeeApps.selected = false
            }
            if (View3.hidden == false){
                HRAppsConst.constant = buffer
                View3.hidden = true
                Equipment.selected = false
            }
            if (View4.hidden == false)
            {
                HRApps.selected = false
                View4.hidden = true
            }
            
            HRAppsConst.constant = View3.frame.size.height + 10
            
            view.bringSubviewToFront(View3)
            View3.hidden = false
            
            
        }
        else{
            HRAppsConst.constant = buffer
            
            Equipment.selected = false
            View3.hidden = true
            view.sendSubviewToBack(View3)
            
            
        }

    }
    
    @IBAction func HRButtonPress(sender: AnyObject) {
        if (View4.hidden == true)
        {
            if (View1.hidden == false) {
                EmployeeConst.constant = buffer
                View1.hidden = true
                AccCreditButton.selected = false
            }
            if (View2.hidden == false){
                EquipmentConst.constant = buffer
                View2.hidden = true
                EmployeeApps.selected = false
            }
            if (View3.hidden == false){
                HRAppsConst.constant = buffer
                View3.hidden = true
                Equipment.selected = false
            }
            if (View4.hidden == false)
            {
                HRApps.selected = false
                View4.hidden = true
            }
            
            view.bringSubviewToFront(View4)
            View4.hidden = false
            
            
        }
        else{
            HRApps.selected = false
            View4.hidden = true
            view.sendSubviewToBack(View4)
            
            
        }
    }
    
    
    
    @IBOutlet weak var EquipFieldHeight: NSLayoutConstraint!
    
    @IBOutlet weak var AccFieldHeight: NSLayoutConstraint!
    
    @IBOutlet weak var EmployeeFieldHeight: NSLayoutConstraint!
    
    @IBOutlet weak var HRAppsConst: NSLayoutConstraint!
    
    @IBOutlet weak var EquipmentConst: NSLayoutConstraint!
    
    @IBOutlet weak var EmployeeConst: NSLayoutConstraint!
    
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

