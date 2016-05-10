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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func Test(sender: AnyObject) {
        if (View1.hidden == true)
        {
            View1.hidden = false
        }
        else
        {
            View1.hidden = true
        }
    }
    
    @IBOutlet weak var View1: UIView!
    

}

