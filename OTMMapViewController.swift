//
//  OTMMapViewController.swift
//  On The Map
//
//  Created by Joseph Hooper on 3/14/16.
//  Copyright © 2016 josephdhooper. All rights reserved.
//  Code from http://stackoverflow.com/questions/24180954/how-to-hide-keyboard-in-swift-on-pressing-return-key was repurposed in the OTMPinViewController. Code from https://github.com/jarrodparkes/on-the-map was repurposed for this project.

import UIKit
import MapKit
import Foundation

class OTMMapViewController: UIViewController, MKMapViewDelegate {
    

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad()
    {
//        super.viewDidLoad()
//        self.activityIndicator.startAnimating()
//        self.activityIndicator.hidden = false
        self.mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        removeAnnotations()
        addAnnotations()
   
    }
    

    func removeAnnotations() {
        let annotationsNeedToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations(annotationsNeedToRemove)
    
}

    func addAnnotations() {
        var annotations = [MKPointAnnotation]()
        for studentInfo in APIClients.sharedInstance().students {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: studentInfo.latitude, longitude: studentInfo.longitude)
            annotation.title = "\(studentInfo.firstName) \(studentInfo.lastName)"
            annotation.subtitle = studentInfo.linkUrl
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    

    @IBAction func refreshButton(sender: UIBarButtonItem) {
        APIClients.sharedInstance().loadStudentInformation  { (success, errorString) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
//                    self.removeAnnotations()
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
        let loginController = self.storyboard!.instantiateViewControllerWithIdentifier("OTMLoginViewController") as! OTMLoginViewController
        presentViewController(loginController, animated: true, completion: nil)
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
    }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as! MKPinAnnotationView?
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView!.canShowCallout = true
        pinView!.rightCalloutAccessoryView = UIButton.init(type: .DetailDisclosure)
    
        return pinView
}

func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    let pin = view.annotation as! MKPointAnnotation?
    let url = NSURL(string: pin!.subtitle!)
    if url != nil && url!.scheme != "" {
        UIApplication.sharedApplication().openURL(url!)
    
    } else {
        
        self.displayURLAlert()
    }
}
    func displayURLAlert()
    
    {
        let alert = UIAlertController.init(title:"Link Error", message:"Invalid link.", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}


