//
//  OTMClients
//  On The Map
//
//  Created by Joseph Hooper on 3/13/16.
//  Copyright © 2016 josephdhooper. All rights reserved.
//  Code from http://stackoverflow.com/questions/24180954/how-to-hide-keyboard-in-swift-on-pressing-return-key was repurposed in the OTMPinViewController. Code from https://github.com/jarrodparkes/on-the-map was repurposed for this project.

import Foundation
import MapKit

class OTMClients: NSObject {
    
    // MARK: - Initializers
    override init() {
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
        User.sessionId = ((parsedResult["session"] as! [String: AnyObject])["id"] as! String)
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
            User.firstName = ((parsedResult["user"] as! [String: AnyObject])["first_name"] as! String)
            User.lastName = ((parsedResult["user"] as! [String: AnyObject])["last_name"] as! String)
            User.accountKey = accountKey
            completionHandler(success: true, errorString: nil)
        }
        task.resume()
    }
    
    class func sharedInstance() -> OTMClients {
        struct Singleton {
            static var sharedInstance = OTMClients()
        }
        return Singleton.sharedInstance
    }

    // Retrieve location data from Parse
    func loadStudentInformation(completionHandler: (success: Bool, errorString: String?) -> Void) {
        let parameters = ["order": "-updatedAt"]
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation" + OTMClients.escapedParameters(parameters))!)
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
            Students.sharedInstance().studentLocations.removeAll()
            for dictionary in resultsArray! {
                let latitude = CLLocationDegrees(dictionary.objectForKey("latitude")! as! Double)
                let longitude = CLLocationDegrees(dictionary.objectForKey("longitude")! as! Double)
                
                let firstName = dictionary.objectForKey("firstName") as! String
                let lastName = dictionary.objectForKey("lastName") as! String
                let mediaURL = dictionary.objectForKey("mediaURL") as! String
                
               Students.sharedInstance().studentLocations.append(StudentLocations(dictionary: ["firstName": firstName, "lastName": lastName, "mediaURL": mediaURL, "latitude": latitude, "longitude": longitude]))
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
    
    request.HTTPBody = NSString(format: "{\"uniqueKey\": \(User.uniqueKey)\"firstName\": \(User.firstName)\"lastName\": \(User.firstName)\"mapString\": \(User.mapString)\"mediaURL\": \"%@\",\"latitude\": %f, \"longitude\": %f}", User.accountKey, User.firstName, User.lastName, mapString, mediaURL, placemark.coordinate.latitude, placemark.coordinate.longitude).dataUsingEncoding(NSUTF8StringEncoding)
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
        guard error == nil else {
            completionHandler(success: false, errorString: error?.description)
            return
        }
        let studentInfo = StudentLocations(dictionary: ["firstName": User.firstName, "lastName": User.lastName, "mediaURL": mediaURL, "latitude": placemark.coordinate.latitude, "longitude": placemark.coordinate.longitude])
        Students.sharedInstance().studentLocations.insert(studentInfo, atIndex: 0)
        completionHandler(success: true, errorString: nil)
    }
    task.resume()
}
    func logout () {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as [NSHTTPCookie]! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { 
                return
            }
        }
        task.resume()
    }

    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            let stringValue = "\(value)"
            
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
}
}

