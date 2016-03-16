//
//  OTMStudents.swift
//  On The Map
//
//  Created by Joseph Hooper on 3/13/16.
//  Copyright © 2016 josephdhooper. All rights reserved.
//

import Foundation

struct StudentInfo {
    var firstName: String
    var lastName: String
    var linkUrl: String
    var latitude: Double
    var longitude: Double
    
    init(dictionary: [String: AnyObject]) {
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
        linkUrl = dictionary["linkUrl"] as! String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
    
    }
    
    
    
    func fullName() -> String {
        return firstName + " " + lastName
    }
}