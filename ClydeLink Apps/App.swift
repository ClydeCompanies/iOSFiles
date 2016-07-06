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
        if let header = aDecoder.decodeObjectForKey("header") as? String {
            self.header = header
        }
        if let title = aDecoder.decodeObjectForKey("title") as? String {
            self.title = title
        }
        if let link = aDecoder.decodeObjectForKey("link") as? String {
            self.link = link
        }
        if let selected = aDecoder.decodeObjectForKey("selected") as? Bool {
            self.selected = selected
        }
        if let icon = aDecoder.decodeObjectForKey("icon") as? String {
            self.icon = icon
        }
        if let URL = aDecoder.decodeObjectForKey("URL") as? String {
            self.URL = URL
        }
        if let order = aDecoder.decodeObjectForKey("order") as? Double {
            self.order = order
        }
        if let redirect = aDecoder.decodeObjectForKey("redirect") as? String {
            self.redirect = redirect
        }
    }
    
    func encodeWithCoder(_aCoder: NSCoder) {
        if let header: String = self.header {
            _aCoder.encodeObject(header, forKey: "header")
        }
        if let title: String = self.title {
            _aCoder.encodeObject(title, forKey: "title")
        }
        if let link: String = self.link {
            _aCoder.encodeObject(link, forKey: "link")
        }
        if let selected: Bool = self.selected {
            _aCoder.encodeObject(selected, forKey: "selected")
        }
        if let icon: String = self.icon {
            _aCoder.encodeObject(icon, forKey: "icon")
        }
        if let URL: String = self.URL {
            _aCoder.encodeObject(URL, forKey: "URL")
        }
        if let order: Double = self.order {
            _aCoder.encodeObject(order, forKey: "order")
        }
        if let redirect: String = self.redirect {
            _aCoder.encodeObject(redirect, forKey: "redirect")
        }
    }
}