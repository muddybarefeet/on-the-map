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
    
    var locations = [[String:AnyObject]]()
    
//    func getStudentLocation () {
//        let parameters = [
//            Constants.ParseParameterKeys.Where: "{\"uniqueKey\":\"\(UdacityClient.sharedInstance().userID)\"}"
//        ]
////        let URL = createURL(parameters, withPathExtension: Constants.Parse.StudentLocation)
//    }
    
    func getAllStudentLocations (completionHandlerForGetAllLocations: (data: AnyObject?, error: String?) -> Void) {
        
        let baseURL = Constants.Parse.baseURL + Constants.Parse.StudentLocation
        let parameters = "?" + Constants.ParseParameterKeys.Order + "=" + Constants.ParseParameterValues.UpdatedAt
//        let URL = createURL(parameters, withPathExtension: Constants.Parse.StudentLocation)
        let headers = [
            Constants.ParseParameterValues.ApplicationID: Constants.ParseParameterKeys.ApplicationID,
            Constants.ParseParameterValues.ApiKey: Constants.ParseParameterKeys.ApplicationKey
        ]
        
        let URL = baseURL + parameters
        request.get(URL, headers: headers, isUdacity: false) { (data, response, error) in
            if error == nil {
                guard let statusCode = response?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    completionHandlerForGetAllLocations(data: nil, error: "There was a response code other than 2xx returned!")
                    return
                }
                guard let results = data!["results"] as? [[String: AnyObject]] else {
                    completionHandlerForGetAllLocations(data: nil, error: "No results key n the return data")
                    return
                }
                self.locations = results
                completionHandlerForGetAllLocations(data: data, error: nil)
            } else {
                print("not got users locations :(")
                completionHandlerForGetAllLocations(data: nil, error: "Unable to get all student loactions.")
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