//
//  UdacityClient.swift
//  onTheMap
//
//  Created by Anna Rogers on 7/19/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import Foundation
import UIKit

class UdacityClient {
    
    var request = RequestClient.sharedInstance
    var Parse = ParseClient.sharedInstance()
    
    var userID: String = ""
    var sessionID: String = ""
    var sessionExp: String = ""
    
    var user: [String:String] = [
        "firstName": "",
        "lastName": ""
    ]
    
    var fbAuthToken = ""
    
    let headers = [
        Constants.UdacityParameterKeys.JSONField: Constants.UdacityParameterValues.AcceptJSON
    ]
    
    //login to the app
    func login (email: String, password: String, completionHandlerForAuth: (data: AnyObject?, error: String?) -> Void) {

        let url = Constants.Udacity.baseURL + Constants.Udacity.Session
        let body = [
            "udacity" : [
                "username": email,
                "password": password
            ]
        ]
        request.post(body, url: url, headers: headers,isUdacity: true) { (data, response, error) in
            if (error != nil) {
                //call completion handler to return to function above
                completionHandlerForAuth(data:nil, error: error)
            } else {
                //get the data from the response needed
                guard let decodeJsonAccount = data!["account"] as? NSDictionary else {
                    completionHandlerForAuth(data: nil, error: "There was no account key in the response")
                    return
                }
                guard let decodeJsonSession = data!["session"] as? NSDictionary else {
                    completionHandlerForAuth(data: nil, error: "There was no session key in the response")
                    return
                }
                self.userID = decodeJsonAccount["key"]! as! String
                self.sessionExp = decodeJsonSession["expiration"] as! String
                self.sessionID = decodeJsonSession["id"] as! String
                completionHandlerForAuth(data: data, error: nil)
                self.getUserData()
            }
        }
    }
    
    func fbLogin () {
        let url = Constants.Udacity.baseURL + Constants.Udacity.Session
        let jsonBody = [
            "facebook_mobile": [
                "access_token": fbAuthToken
            ]
        ]
        request.post(jsonBody, url: url, headers: headers, isUdacity: true) { (data, response, error) in
            if (error != nil) {
                print("error: ",error)
            } else {
               print("data: ", data)
            }
        }
        
    }
    
    //get the users data after login
    private func getUserData() {
        let baseURL = Constants.Udacity.baseURL + Constants.Udacity.Users + userID
        request.get(baseURL, headers: [:], isUdacity: true) { (data, response, error) in
            if error == nil {
                // MAKE SURE THAT THE VALUE OF THE OBJECT IS AnyObject and NOT String else weird things happen!
                guard let userKey = data!["user"] as? [String: AnyObject] else {
                    print("No user key on return data")
                    return
                }
                //save the user info ready for editing the student location
                self.Parse.userData["firstName"] = userKey["first_name"] as! String
                self.Parse.userData["lastName"] = userKey["last_name"] as! String
            } else {
                print("error getting user data")
            }
        }
    }
    
    //log out function
    func logout (completionHandlerForLogout: (success: Bool?, error: String?) -> Void) {
        let url = Constants.Udacity.baseURL + Constants.Udacity.Session
        request.delete(url) { (data, request, error) in
            if error == nil {
                print("Logout good")
                completionHandlerForLogout(success: true, error: nil)
            } else {
                completionHandlerForLogout(success: nil, error: error)
            }
        }
    }
    
    //create singleton instance of class
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
}
