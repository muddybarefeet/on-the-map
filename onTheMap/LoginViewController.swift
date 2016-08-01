//
//  LoginViewController.swift
//  onTheMap
//
//  Created by Anna Rogers on 7/19/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    var textFieldDelegate = TextFieldDelegate()
    let Udacity = UdacityClient.sharedInstance
    
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailInput.delegate = textFieldDelegate
        passwordInput.delegate = textFieldDelegate
        activitySpinner.center = self.view.center
        fbLoginButton.delegate = self
        //add property to button
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        initAppearance()
    }
    
    func initAppearance() -> Void {
        loginButton.layer.cornerRadius = 5
        fbLoginButton.layer.cornerRadius = 10
        let background = CAGradientLayer().turquoiseColor()
        background.frame = self.view.bounds
        self.view.layer.insertSublayer(background, atIndex: 0)
    }
    
    //functions for fb login
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if (result.token != nil) {
            print("token", result.token)
            self.Udacity.fbAuthToken = String(result.token)
            self.Udacity.fbLogin() { (success, error) in
                if ((success) != nil) {
                    //segue to app
                    self.segueToApp()
                } else {
                    //throw alert
                    self.loginError(error!)
                }
            }
        } else {
            print("no token :(")
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
        //remove FB access token from app
        self.Udacity.fbAuthToken = nil
    }
    
    @IBAction func login(sender: AnyObject) {
        activitySpinner.startAnimating()
        self.view.addSubview(activitySpinner)
        //login into the app
        //authenticate the user and then segue to the next view
        Udacity.login(emailInput.text!, password: passwordInput.text!) { (data, error) in
            if error == nil {
                //complete the login to show the user the app
                self.segueToApp()
            } else {
                print("error in login", error)
                self.loginError(error!)
            }
        }
    }
    
    private func segueToApp () {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.activitySpinner.stopAnimating()
            self.view.willRemoveSubview(self.activitySpinner)
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    private func loginError (error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        let Action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
            print("Clicked ok")
        }
        let SignUpAction = UIAlertAction(title: "Sign Up", style: .Default) { (action:UIAlertAction!) in
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: Constants.Udacity.UdacitySignUp)!)
        }
        alertController.addAction(Action)
        alertController.addAction(SignUpAction)
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.activitySpinner.stopAnimating()
            self.view.willRemoveSubview(self.activitySpinner)
            self.presentViewController(alertController, animated: true, completion:nil)
        }
    }
    
    
    @IBAction func signUp(sender: AnyObject) {
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: Constants.Udacity.UdacitySignUp)!)
    }
    
}

