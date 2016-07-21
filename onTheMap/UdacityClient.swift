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
    
    var request = RequestClient.sharedInstance()
    var Parse = ParseClient.sharedInstance()
    
    var userID: String = ""
    var sessionID: String = ""
    var sessionExp: String = ""
    
    var user: [String:String] = [
        "firstName": "",
        "lastName": ""
    ]
    
    let headers = [
        Constants.UdacityParameterKeys.JSONField: Constants.UdacityParameterValues.AcceptJSON
    ]
    
    func login (email: String, password: String, completionHandlerForAuth: (data: AnyObject?, error: String?) -> Void) {
        //pass the get method the things to make the url and the request
        let baseURL = Constants.Udacity.baseURL + Constants.Udacity.Session
        
        let body = [
            "udacity" : [
                "username": email,
                "password": password
            ]
        ]
        
        print("base url: ", baseURL)
        
        request.post(body, url: baseURL, headers: headers,isUdacity: true) { (data, response, error) in
            if (error != nil) {
                //call completion handler to return to function above
                completionHandlerForAuth(data:nil, error: error?.debugDescription)
            } else {
                guard let statusCode = response?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    completionHandlerForAuth(data: nil, error: "There was a response code other than 2xx returned!")
                    return
                }
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
                
                //call error on completion handler
                
                completionHandlerForAuth(data: data, error: nil)
                self.getUserData()
            }
        }
        
    }
    
    private func getUserData() {
        let baseURL = Constants.Udacity.baseURL + Constants.Udacity.Users + userID

        request.get(baseURL, headers: [:], isUdacity: true) { (data, response, error) in
            if error == nil {
                // MAKE SURE THAT THE VALUE OF THE OBJECT IS AnyObject and NOT String else weird things happen!
                guard let userKey = data!["user"] as? [String: AnyObject] else {
                    print("No user key on return data")
                    return
                }
                
                //save the user info ready to post data to parse
                self.Parse.userData["firstName"] = userKey["first_name"] as! String
                self.Parse.userData["lastName"] = userKey["last_name"] as! String
                
            } else {
                print("error getting user data")
               //throw alert
            }
        }
        
    }
    
    //make the class a singleton
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
}
