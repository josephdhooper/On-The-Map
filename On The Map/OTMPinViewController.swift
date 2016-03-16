//
//  OTMPinViewController.swift
//  On The Map
//
//  Created by Joseph Hooper on 3/14/16.
//  Copyright © 2016 josephdhooper. All rights reserved.
//

import UIKit
import MapKit

class OTMPinViewController: UIViewController {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    var placemark: MKPlacemark!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func findButtonPushed(sender: AnyObject) {
        guard locationTextField.text != "" else {
            let alert = UIAlertController(title: "Error", message: "Must enter a location.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationTextField.text!) { (placemarks, error) -> Void in
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                return
            }
            
            guard placemarks!.count > 0 else {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertController(title: "Error", message: "No Match Found.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.placemark = MKPlacemark(placemark: placemarks![0])
                self.mapView.addAnnotation(self.placemark)
                let region = MKCoordinateRegionMakeWithDistance(self.placemark.coordinate, 100000, 100000)
                self.mapView.setRegion(region, animated: true)
                self.submitButton.enabled = true
            })
        }
    }
    
    @IBAction func submitButtonPushed(sender: AnyObject) {
        guard linkTextField.text != "" else {
            let alert = UIAlertController(title: "Error", message: "Must enter a link.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        UdacityClient.sharedInstance().submitStudentInformation(locationTextField.text!, mediaURL: linkTextField.text!, placemark: self.placemark) { (success, errorString) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if (success) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Error", message: errorString!, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func previewButtonPushed(sender: AnyObject) {
        guard linkTextField.text != "" else {
            let alert = UIAlertController(title: "Error", message: "Must enter a link.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        let app = UIApplication.sharedApplication()
        let url = NSURL(string: linkTextField.text!)!
        if app.canOpenURL(url) {
            app.openURL(url)
        } else {
            let alert = UIAlertController(title: "Error", message: "Cannot open link.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonPushed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Keyboard methods
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y = -getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
}