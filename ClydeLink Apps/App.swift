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
    var permissions: Int = 0
    var selected: Bool = false
    var icon: String = "" // ex: "icon3.png" or "UNDEFINED"
    var URL: String = "" // ex: "http://www.clydelink.com/forms/communications/Pages/TrainingRequests.aspx" or "UNDEFINED"
    var order: Double = 0.0 // ex: 4.2
    
    init(h: String, t: String, l: String, p: Int, s: Bool, i: String, u: String, o: Double)
    {
        self.header = h
        self.title = t
        self.link = l
        self.permissions = p
        self.selected = s
        self.icon = i
        self.URL = u
        self.order = o
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
        if let permissions = aDecoder.decodeObjectForKey("permissions") as? Int {
            self.permissions = permissions
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
        if let permissions: Int = self.permissions {
            _aCoder.encodeObject(permissions, forKey: "permissions")
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
    }
}