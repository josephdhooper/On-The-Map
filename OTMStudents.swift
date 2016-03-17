//
//  OTMStudents.swift
//  On The Map
//
//  Created by Joseph Hooper on 3/13/16.
//  Copyright © 2016 josephdhooper. All rights reserved.
//  Code from http://stackoverflow.com/questions/24180954/how-to-hide-keyboard-in-swift-on-pressing-return-key was repurposed in the OTMPinViewController. Code from https://github.com/jarrodparkes/on-the-map was repurposed throught project.  

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

    struct sharedInstance {
        var students: [StudentInfo]
        var accountKey: String?
        var firstName: String?
        var lastName: String?
        var sessionId: String?
        
        init() {
            students = [StudentInfo]()    }
    
    }
    
    
    func fullName() -> String {
        return firstName + " " + lastName
    }
    
}

