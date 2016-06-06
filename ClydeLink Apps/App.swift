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
    init(h: String, t: String, l: String, p: Int, s: Bool)
    {
        self.header = h
        self.title = t
        self.link = l
        self.permissions = p
        self.selected = s
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
    }
}