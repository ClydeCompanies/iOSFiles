//
//  TruckSearchViewController.swift
//  ClydeLink Apps
//
//  Created by J J Feddock on 5/12/16.
//  Copyright © 2016 XLR8 Development LLC. All rights reserved.
//

import UIKit

class TruckSearchViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ChangeSearchButtonPress(sender: AnyObject) {
        if (SearchCriteria.text == "Fleet Number:")
        {
            SearchCriteria.text = "Employee Name:"
            SearchStart.text = ""
            ChangeSearch.setTitle("Search by Truck Number", forState: UIControlState.Normal)
            TextBox.keyboardType = UIKeyboardType.Default
            TextBox.autocapitalizationType = .Words
            TextBox.reloadInputViews()
        }
        else{
            SearchCriteria.text = "Fleet Number:"
            SearchStart.text = "01 -"
            ChangeSearch.setTitle("Search by Employee Name", forState: UIControlState.Normal)
            TextBox.reloadInputViews()
            TextBox.keyboardType = UIKeyboardType.NumberPad
            TextBox.autocapitalizationType = .None
            TextBox.reloadInputViews()
        }
    }
    
    @IBAction func SearchClick(sender: AnyObject) {
        print(TextBox.text! + "Searched")
    }
    
    
    @IBOutlet weak var SearchCriteria: UILabel!

    @IBOutlet weak var SearchStart: UILabel!
    
    @IBOutlet weak var ChangeSearch: UIButton!
    
    @IBOutlet weak var TextBox: UITextField!
    
    @IBOutlet weak var ResultsTable: UITableView!
    
}