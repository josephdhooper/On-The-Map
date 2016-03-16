//
//  OTMUdacity.swift
//  On The Map
//
//  Created by Joseph Hooper on 3/13/16.
//  Copyright © 2016 josephdhooper. All rights reserved.
//

import Foundation
import MapKit

class UdacityClient: NSObject {
    var students: [StudentInfo]
    var accountKey: String?
    var firstName: String?
    var lastName: String?
    var sessionId: String?
    
    override init() {
        students = [StudentInfo]()
    }

    // Loging to Udacity Client - API
    func loginToUdacity(email: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
    let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.HTTPBody = NSString(format: "{\"udacity\": {\"username\": \"%@\", \"password\":\"%@\"}}", email, password).dataUsingEncoding(NSUTF8StringEncoding)
    
    // Submit request with a session.
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
        guard error == nil else {
            completionHandler(success: false, errorString: error?.localizedDescription)
            return
        }
        guard let data = data else {
            completionHandler(success: false, errorString: "No data was returned by the request!")
            return
        }
        
        let newData = data.subdataWithRange(NSMakeRange(5, data.length-5))
        
        // Connect to Parse; Returned data.
        let parsedResult = try! NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
        guard parsedResult.objectForKey("error") == nil else {
            completionHandler(success: false, errorString: (parsedResult.objectForKey("error")! as! String))
            return
        }
        // Record account key and session id
        let accountKey = ((parsedResult["account"] as! [String: AnyObject])["key"] as! String)
        self.sessionId = ((parsedResult["session"] as! [String: AnyObject])["id"] as! String)
        self.getUserData(accountKey, completionHandler: { (success, errorString) -> Void in
            if (success) {
                self.loadStudentInformation({ (success, errorString) -> Void in
                    completionHandler(success: success, errorString: errorString)
                })
            } else {
                completionHandler(success: false, errorString: errorString)
            }
        })
    }
    task.resume()
}
    func getUserData(accountKey: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: NSString(format: "https://www.udacity.com/api/users/%@", accountKey) as String)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in// Error checking of response.
            guard error == nil else {
                completionHandler(success: false, errorString: error?.localizedDescription)
                return
            }
            guard let data = data else {
                completionHandler(success: false, errorString: "No data was returned")
                return
            }
    
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            let parsedResult = try! NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            self.firstName = ((parsedResult["user"] as! [String: AnyObject])["first_name"] as! String)
            self.lastName = ((parsedResult["user"] as! [String: AnyObject])["last_name"] as! String)
            self.accountKey = accountKey
            completionHandler(success: true, errorString: nil)
        }
        task.resume()
    }
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
    func logout() {
        accountKey = nil
        firstName = nil
        lastName = nil
        sessionId = nil
    }

    // Retrieve location data from Parse
    func loadStudentInformation(completionHandler: (success: Bool, errorString: String?) -> Void) {
        _ = ["order": "-updatedAt"]
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard error == nil else {
                completionHandler(success: false, errorString: error?.description)
                return
            }
            guard let data = data else {
                completionHandler(success: false, errorString: "No data was returned by the request!")
                return
            }
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                completionHandler(success: false, errorString: "Not able to parse result from server!")
                return
            }
            let resultsArray = parsedResult.objectForKey("results") as? [NSDictionary]
            guard resultsArray != nil else {
                completionHandler(success: false, errorString: "Server error: unparseable results array.")
                return
            }
            self.students.removeAll()
            for dictionary in resultsArray! {
                let latitude = CLLocationDegrees(dictionary.objectForKey("latitude")! as! Double)
                let longitude = CLLocationDegrees(dictionary.objectForKey("longitude")! as! Double)
                
                let firstName = dictionary.objectForKey("firstName") as! String
                let lastName = dictionary.objectForKey("lastName") as! String
                let linkUrl = dictionary.objectForKey("mediaURL") as! String
                
                self.students.append(StudentInfo(dictionary: ["firstName": firstName, "lastName": lastName, "linkUrl": linkUrl, "latitude": latitude, "longitude": longitude]))
            }
            completionHandler(success: true, errorString: nil)
        }
        task.resume()
    }

func submitStudentInformation(mapString: String, mediaURL: String, placemark: MKPlacemark, completionHandler: (success: Bool, errorString: String?) -> Void) {
    let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
    request.HTTPMethod = "POST"
    request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.HTTPBody = NSString(format: "{\"uniqueKey\": \"%@\", \"firstName\": \"%@\", \"lastName\": \"%@\",\"mapString\": \"%@\", \"mediaURL\": \"%@\",\"latitude\": %f, \"longitude\": %f}", accountKey!, firstName!, lastName!, mapString, mediaURL, placemark.coordinate.latitude, placemark.coordinate.longitude).dataUsingEncoding(NSUTF8StringEncoding)
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
        guard error == nil else {
            completionHandler(success: false, errorString: error?.description)
            return
        }
        let studentInfo = StudentInfo(dictionary: ["firstName": self.firstName!, "lastName": self.lastName!, "linkUrl": mediaURL, "latitude": placemark.coordinate.latitude, "longitude": placemark.coordinate.longitude])
        self.students.insert(studentInfo, atIndex: 0)
        completionHandler(success: true, errorString: nil)
    }
    task.resume()
}

}

