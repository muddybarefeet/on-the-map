//
//  LoginViewController.swift
//  onTheMap
//
//  Created by Anna Rogers on 7/19/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var textFieldDelegate = TextFieldDelegate()
    let Udacity = UdacityClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailInput.delegate = textFieldDelegate
        passwordInput.delegate = textFieldDelegate
    }
    
    @IBAction func login(sender: AnyObject) {
        
        //login into the app
        //authenticate the user and then segue to the next view
        
        Udacity.login(Constants.User.email, password: Constants.User.pass) { (data, error) in
                if error == nil {
                //complete the login to show the user the app
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                    NSOperationQueue.mainQueue().addOperationWithBlock {
//                        progressIndicator.removeFromSuperview()
                        self.presentViewController(controller, animated: true, completion: nil)
                    }
                } else {
                //throw an error
                    print("ERROR IN LOGIN VIEW CONTROLLER", error)
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