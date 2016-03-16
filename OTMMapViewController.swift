//
//  OTMMapViewController.swift
//  On The Map
//
//  Created by Joseph Hooper on 3/14/16.
//  Copyright © 2016 josephdhooper. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class OTMMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        removeAnnotations()
        addAnnotations()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView =
                UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle!{
                app.openURL(NSURL(string: toOpen)!)
            }
        }
        
    }

    
    func removeAnnotations() {
        let annotationsNeedToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations(annotationsNeedToRemove)
    
}

    func addAnnotations() {
        var annotations = [MKPointAnnotation]()
        for studentInfo in UdacityClient.sharedInstance().students {
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: studentInfo.latitude, longitude: studentInfo.longitude)
            annotation.title = studentInfo.fullName()
            annotation.subtitle = studentInfo.linkUrl
            
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    

    @IBAction func refreshButton(sender: UIBarButtonItem) {
        UdacityClient.sharedInstance().loadStudentInformation  { (success, errorString) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                    self.removeAnnotations()
                    self.addAnnotations()
                } else {
                    let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }

    @IBAction func addPin(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            let pinViewController = self.storyboard?.instantiateViewControllerWithIdentifier("addPinViewController") as! OTMPinViewController
            self.presentViewController(pinViewController, animated: true, completion: nil)
            
        })
    }
    
    @IBAction func logoutButton(sender: UIBarButtonItem) {
        UdacityClient.sharedInstance().logout()
        let loginController = self.storyboard!.instantiateViewControllerWithIdentifier("OTMLoginViewController") as! OTMLoginViewController
        presentViewController(loginController, animated: true, completion: nil)
    }
    
    func submitNewPin() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 40.0, \"longitude\": -100.0}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard error == nil else {
                print("Error returned by request", error)
                return
            }
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }

}

