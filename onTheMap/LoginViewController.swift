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
        
        //1. post to get a a sessionID: PARAMETERS:
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(self.emailInput.text!)\", \"password\": \"\(self.passwordInput.text!)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                return
            }
            
            guard let data = data else {
                print("No data")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            var parsedResult: AnyObject?
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let decodeJsonAccount = parsedResult!["account"] as? NSDictionary else {
                print("Account key not found")
                return
            }
            guard let decodeJsonSession = parsedResult!["session"] as? NSDictionary else {
                print("Session key not found")
                return
            }
            
            self.Udacity.userID = decodeJsonAccount["key"]! as! String
            self.Udacity.sessionExp = decodeJsonSession["expiration"] as! String
            self.Udacity.sessionID = decodeJsonSession["id"] as! String
            print("LOGGED IN step one")
            
        }
        
        task.resume()
        
        //get the user data at https://www.udacity.com/api/users/USERID
        //call this method and then storee the firstName and LastName
        let controller = storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
        presentViewController(controller, animated: true, completion: nil)
        
        getUserData()
        
    }
    
    func getUserData () {
        print("get data called")
        
        //TODO remove hard coded userID
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/8539194464")!)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            if error != nil {
                print("There was an error in the request")
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */

            var parsedResult: AnyObject?
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            print("data", parsedResult)
            
            guard let user = parsedResult!["user"] as? NSDictionary else {
                print("There was no user key")
                return
            }
            
            self.Udacity.user["firstName"] = user["first_name"] as? String
            self.Udacity.user["lastName"] = user["last_name"] as? String
            
        }
        task.resume()
        
        //then we want to move to the next view if any error then we stay on the same view
    
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