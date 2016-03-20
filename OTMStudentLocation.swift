//
//  OTMStudentLocation.swift
//  On The Map
//
//  Created by Joseph Hooper on 3/18/16.
//  Copyright © 2016 josephdhooper. All rights reserved.
//

import Foundation

class StudentLocations: NSObject {
    
    // MARK: Initializers
    var firstName: String
    var lastName: String
    var mediaURL: String
    var fullName: String!
    var longitude: Double!
    var latitude: Double!
    var mapString: String!
    var objectId: String!
    var accountKey: String?
    var sessionId: String?

    
    init(dictionary: [String: AnyObject]) {
        self.firstName = dictionary["firstName"] as! String
        self.lastName = dictionary["lastName"] as! String
        self.mediaURL = dictionary["mediaURL"] as! String
        self.latitude = dictionary["latitude"] as! Double
        self.longitude = dictionary["longitude"] as! Double
    
    }

}



