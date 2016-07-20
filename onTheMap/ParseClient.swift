//
//  ParseClient.swift
//  onTheMap
//
//  Created by Anna Rogers on 7/19/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import Foundation

import UIKit

class ParseClient {
    
    let request = RequestClient.sharedInstance()
    
    var userData = [
        "firstName": "",
        "lastName": "",
        "mapString": "",
        "latitude": 0.0,
        "longitude": 0.0,
        "mediaURL": ""
    ]
    
    func getStudentLocation () {
        
        let parameters = [
            Constants.ParseParameterKeys.Where: "{\"uniqueKey\":\"\(UdacityClient.sharedInstance().userID)\"}"
        ]
        
//        let URL = createURL(parameters, withPathExtension: Constants.Parse.StudentLocation)
        
    }
    
    func getAllStudentLocations () {
        
        let baseURL = Constants.Parse.baseURL + Constants.Parse.StudentLocation
        let parameters = "?" + Constants.ParseParameterKeys.Order + "=" + Constants.ParseParameterValues.UpdatedAt
//        let URL = createURL(parameters, withPathExtension: Constants.Parse.StudentLocation)
        let headers = [
            Constants.ParseParameterValues.ApplicationID: Constants.ParseParameterKeys.ApplicationID,
            Constants.ParseParameterValues.ApiKey: Constants.ParseParameterKeys.ApplicationKey
        ]
        
        let URL = baseURL + parameters
        request.get(URL, headers: headers, isUdacity: false) { (data, response, error) in
            if (error != nil) {
                print("data!",data, error)
            } else {
                print("errror", error, data)
            }
        }
        
    }
    
    
    // create a URL from parameters
    func createURL(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.Parse.ApiScheme
        components.host = Constants.Parse.ApiHost
        components.path = Constants.Parse.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
}