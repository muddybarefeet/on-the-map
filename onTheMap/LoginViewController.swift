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

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var textFieldDelegate = TextFieldDelegate()
    let Udacity = UdacityClient.sharedInstance()
    
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //facebook login
        
        
        emailInput.delegate = textFieldDelegate
        passwordInput.delegate = textFieldDelegate
        activitySpinner.center = self.view.center
    }
    
    override func viewDidAppear(animated: Bool) {
        let fbLoginButton: FBSDKLoginButton = FBSDKLoginButton()
        // Optional: Place the button in the center of your view.
        fbLoginButton.center = self.view.center
        fbLoginButton.frame = CGRectMake(fbLoginButton.frame.origin.x, view.frame.maxY - 100,fbLoginButton.frame.size.width,fbLoginButton.frame.size.height)
        self.view!.addSubview(fbLoginButton)
        fbLoginButton.addTarget(self, action: #selector(fbLogin), forControlEvents: .TouchUpInside)
    }
    
    
    func fbLogin (sender: AnyObject) {
        
        print("Clicked fb button")
        let login: FBSDKLoginManager = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile"], fromViewController: self) { (FBSDKLoginManagerLoginResult, error) in
            if error != nil {
                print("Process error", error)
            }
            else if FBSDKLoginManagerLoginResult.isCancelled {
                print("Cancelled")
            }
            else {
                print("Logged in", FBSDKLoginManagerLoginResult.token.tokenString)
                self.Udacity.fbAuthToken = FBSDKLoginManagerLoginResult.token.tokenString
                //now call login method with the auth token
                self.Udacity.fbLogin()
            }
        }
        
    }
    
    
    
    @IBAction func login(sender: AnyObject) {
        
        activitySpinner.startAnimating()
        self.view.addSubview(activitySpinner)
        
        //login into the app
        //authenticate the user and then segue to the next view
        Udacity.login(Constants.User.email, password: Constants.User.password) { (data, error) in
                if error == nil {
                    //complete the login to show the user the app
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.presentViewController(controller, animated: true, completion: nil)
                    }
                    //not show but for completness
                    self.activitySpinner.stopAnimating()
                    self.view.willRemoveSubview(self.activitySpinner)
                } else {
                    print("error in login", error)
                    let alertController = UIAlertController(title: "Error", message: "These user credentials are not valid. Please try again or Sign Up.", preferredStyle: UIAlertControllerStyle.Alert)
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
                        self.presentViewController(alertController, animated: true, completion:nil)
                    }
                    self.activitySpinner.stopAnimating()
                    self.view.willRemoveSubview(self.activitySpinner)
                }
            }
    }
    
}

extension LoginViewController {
    
    //keyboard functions
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    //  ---------- code for moving the image up when the keyboard loads ------
    func subscribeToKeyboardNotifications () {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        view.frame.origin.y = getKeyboardHeight(notification) * (-1)
    }
    
    //  return the keyboard to the bottom position
    func reset() {
        self.view.frame.origin.y = 0
    }
    
    func keyboardWillHide(notification: NSNotification) {
        reset()
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }

}