//
//  OTMLoginViewController.swift
//  On The Map
//
//  Created by Joseph Hooper on 3/7/16.
//  Copyright © 2016 josephdhooper. All rights reserved.
//  Code from http://stackoverflow.com/questions/24180954/how-to-hide-keyboard-in-swift-on-pressing-return-key was repurposed in the OTMPinViewController. Code from https://github.com/jarrodparkes/on-the-map was repurposed for this project.

import UIKit

class OTMLoginViewController: UIViewController, UITextFieldDelegate {

    //Mark: Outlets
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
    
    }
    
    override func viewWillAppear(animated: Bool) {
        activityIndicator.hidesWhenStopped = true
    }
    
    //Input email => input password => click return to login
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        if (textField === emailField) {
            passwordField.becomeFirstResponder()
        } else if (textField === passwordField) {
            loginButton()
        }
        
        return true
    }

    //Use the syntax (sender: AnyObject? = nil) instead of (sender: AnyObject) to fix missing argument for parementer #1 in call loginButton()
    @IBAction func loginButton(sender: AnyObject? = nil) {
        self.activityIndicator.startAnimating()
        guard (!emailField.text!.isEmpty && !passwordField.text!.isEmpty) else {
            let alert = UIAlertController(title: "Error", message: "Email and/or password field is empty.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
}
       OTMClients.sharedInstance().loginToUdacity(emailField.text!, password: passwordField.text!) { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicator.stopAnimating()

                    let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                let tabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                self.presentViewController(tabBarController, animated: true, completion: nil)
            })
        
        }
    }
}

