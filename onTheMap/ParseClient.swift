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
    
    func getStudentLocation (completionHandlerForCurrentLocation: (data: AnyObject?, error: String?) -> Void) {
        
        let baseURL = Constants.Parse.baseURL + Constants.Parse.StudentLocation
        let parameterString = "{\"uniqueKey\":\"\(UdacityClient.sharedInstance().userID)\"}"
        let customAllowedSet =  NSCharacterSet(charactersInString:"=\"#%/<>:?@\\^`{|}").invertedSet
        let escapedString = parameterString.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)
        let URL = baseURL + "?" + Constants.ParseParameterKeys.Where + "=" + escapedString!
        
        let headers = [
            Constants.ParseParameterValues.ApplicationID: Constants.ParseParameterKeys.ApplicationID,
            Constants.ParseParameterValues.ApiKey: Constants.ParseParameterKeys.ApplicationKey
        ]
        
        request.get(URL, headers: headers, isUdacity: false) { (data, response, error) in
            if error == nil {
                guard let results = data!["results"] else {
                    completionHandlerForCurrentLocation(data: nil, error: "There was no results key in the response")
                    return
                }
                completionHandlerForCurrentLocation(data: results, error: nil)
            } else {
                print("error :(", error)
                completionHandlerForCurrentLocation(data: nil, error: "There was an error in the request")
            }
        }
        
    }
    
    func getAllStudentLocations (completionHandlerForGetAllLocations: (data: AnyObject?, error: String?) -> Void) {
        
        let baseURL = Constants.Parse.baseURL + Constants.Parse.StudentLocation
        let parameters = "?" + Constants.ParseParameterKeys.Order + "=" + Constants.ParseParameterValues.UpdatedAt
        let headers = [
            Constants.ParseParameterValues.ApplicationID: Constants.ParseParameterKeys.ApplicationID,
            Constants.ParseParameterValues.ApiKey: Constants.ParseParameterKeys.ApplicationKey
        ]
        
        let URL = baseURL + parameters
        request.get(URL, headers: headers, isUdacity: false) { (data, response, error) in
            if error == nil {
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
    
    func postUserLocation (completionHandlerForPostStudentLocation: (data:AnyObject?, error: String?) -> Void) {
        
        let URL = Constants.Parse.baseURL + Constants.Parse.StudentLocation
        let headers = [
            Constants.ParseParameterValues.ApplicationID: Constants.ParseParameterKeys.ApplicationID,
            Constants.ParseParameterValues.ApiKey: Constants.ParseParameterKeys.ApplicationKey
        ]
        let jsonBody = "{\"uniqueKey\": \"\(UdacityClient.sharedInstance().userID)\", \"firstName\": \"\(self.userData["firstName"])\", \"lastName\": \"\(self.userData["lastName"])\",\"mapString\": \"\(self.userData["mapString"])\", \"mediaURL\": \"\(self.userData["mediaURL"])\",\"latitude\": \(self.userData["latitude"]), \"longitude\": \(self.userData["latitude"])}"
        
        request.post(jsonBody,baseURL: URL,headers: headers,isUdacity: false) { (data, response, error) in
            if error == nil {
                print("data returned", data)
                completionHandlerForPostStudentLocation(data: data, error: nil)
            } else {
                print("error returned", error)
                completionHandlerForPostStudentLocation(data: nil, error: "There was an error")
            }
        }
        
    }
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
}