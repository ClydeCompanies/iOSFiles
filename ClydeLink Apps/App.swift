//
//  App.swift
//  ClydeLink Apps
//
//  Created by XLR8 Development LLC on 6/2/16.
//

import UIKit

class App: NSObject, NSCoding {
    var header: String = ""  // ex: "Equipment Apps"
    var title: String = ""  // ex: "Vehicle Search"
    var link: String = ""  // ex: "vehiclesearch"
    var selected: Bool = false
    var icon: String! = ""  // ex: "icon3.png" or ""
    var URL: String = ""  // ex: "http://www.clydelink.com/forms/communications/Pages/TrainingRequests.aspx" or "UNDEFINED"
    var order: Double = 0.0 // ex: 4.2
    var redirect: String = ""  // ex: "http://itunes.com/link-to-app" or ""
    
    
    init(h: String, t: String, l: String, s: Bool, i: String, u: String, o: Double, r: String)
    {
        self.header = h
        self.title = t
        self.link = l
        self.selected = s
        self.icon = i
        self.URL = u
        self.order = o
        self.redirect = r
    }
    
    required init(coder aDecoder: NSCoder) {
        if let header = aDecoder.decodeObject(forKey: "header") as? String {
            self.header = header
        }
        if let title = aDecoder.decodeObject(forKey: "title") as? String {
            self.title = title
        }
        if let link = aDecoder.decodeObject(forKey: "link") as? String {
            self.link = link
        }
        if let selected = aDecoder.decodeObject(forKey: "selected") as? Bool {
            self.selected = selected
        }
        if let icon = aDecoder.decodeObject(forKey: "icon") as? String {
            self.icon = icon
        }
        if let URL = aDecoder.decodeObject(forKey: "URL") as? String {
            self.URL = URL
        }
        if let order = aDecoder.decodeObject(forKey: "order") as? Double {
            self.order = order
        }
        if let redirect = aDecoder.decodeObject(forKey: "redirect") as? String {
            self.redirect = redirect
        }
    }
    
    func encode(with _aCoder: NSCoder) {
        if let header: String = self.header {
            _aCoder.encode(header, forKey: "header")
        }
        if let title: String = self.title {
            _aCoder.encode(title, forKey: "title")
        }
        if let link: String = self.link {
            _aCoder.encode(link, forKey: "link")
        }
        if let selected: Bool = self.selected {
            _aCoder.encode(selected, forKey: "selected")
        }
        if let icon: String = self.icon {
            _aCoder.encode(icon, forKey: "icon")
        }
        if let URL: String = self.URL {
            _aCoder.encode(URL, forKey: "URL")
        }
        if let order: Double = self.order {
            _aCoder.encode(order, forKey: "order")
        }
        if let redirect: String = self.redirect {
            _aCoder.encode(redirect, forKey: "redirect")
        }
    }
}
