//
//  OTMStudents.swift
//  On The Map
//
//  Created by Joseph Hooper on 3/13/16.
//  Copyright © 2016 josephdhooper. All rights reserved.
//  Code from http://stackoverflow.com/questions/24180954/how-to-hide-keyboard-in-swift-on-pressing-return-key was repurposed in the OTMPinViewController. Code from https://github.com/jarrodparkes/on-the-map was repurposed for this project.

import Foundation

class Students{
    var studentLocations = [StudentLocations]()
    var student: [String: AnyObject] = [String: AnyObject]()
    
    class func sharedInstance() -> Students{
        
        struct Singleton{
            static var sharedInstance = Students()
        }
        
        return Singleton.sharedInstance
    }
}
