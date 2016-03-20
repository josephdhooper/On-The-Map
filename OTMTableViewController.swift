//
//  OTMTableViewController.swift
//  On The Map
//
//  Created by Joseph Hooper on 3/13/16.
//  Copyright © 2016 josephdhooper. All rights reserved.
//  Code from http://stackoverflow.com/questions/24180954/how-to-hide-keyboard-in-swift-on-pressing-return-key was repurposed in the OTMPinViewController. Code from https://github.com/jarrodparkes/on-the-map was repurposed for this project.

import Foundation
import MapKit
import UIKit

class OTMTableViewController: UITableViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
}
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Students.sharedInstance().studentLocations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationPin")!
        let location = Students.sharedInstance().studentLocations[indexPath.row]
        cell.textLabel?.text = "\(location.firstName) \(location.lastName)"
        cell.detailTextLabel?.text = location.mediaURL
        return cell
    }
    
    //Make URLS linkable and viewable
     override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = Students.sharedInstance().studentLocations[indexPath.row]
        UIApplication.sharedApplication().openURL(NSURL(string: location.mediaURL)!)
        
    }
    
    @IBAction func refreshButton(sender: UIBarButtonItem) {
        OTMClients.sharedInstance().loadStudentInformation  { (success, errorString) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                    self.tableView.reloadData()
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
        OTMClients.sharedInstance().logout()
        dispatch_async(dispatch_get_main_queue()) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}