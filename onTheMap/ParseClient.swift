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
    
    var objectId: String = ""
    var upsertMethod: String = ""
    
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
                guard let result = data!["results"]!![0] as? [String: AnyObject] else {
                    completionHandlerForCurrentLocation(data: nil, error: "There was no results key in the response")
                    return
                }
                self.objectId = result["objectId"]! as! String
                completionHandlerForCurrentLocation(data: result, error: nil)
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
                    completionHandlerForGetAllLocations(data: nil, error: "No results key in the return data")
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
    
    func upsertUserLocation (completionHandlerForUpsertStudentLocation: (success: Bool?, error: String?) -> Void) {
        
        let URL = Constants.Parse.baseURL + Constants.Parse.StudentLocation
        let headers = [
            Constants.ParseParameterValues.ApplicationID: Constants.ParseParameterKeys.ApplicationID,
            Constants.ParseParameterValues.ApiKey: Constants.ParseParameterKeys.ApplicationKey
        ]
        
        var body = userData
        body["uniqueKey"] = UdacityClient.sharedInstance().userID
        
        if (upsertMethod == "POST") {
            request.post(body,url: URL,headers: headers,isUdacity: false) { (data, response, error) in
                if error == nil {
                    guard let objectID = data!["objectId"] as? String else {
                        completionHandlerForUpsertStudentLocation(success: nil, error: "No createdAt key in the return data")
                        return
                    }
                    //could add in logic to check the objectIds match?
                    completionHandlerForUpsertStudentLocation(success: true, error: nil)
                } else {
                    print("error returned", error)
                    completionHandlerForUpsertStudentLocation(success: nil, error: "There was an error")
                }
            }
        } else if (upsertMethod == "PUT") {
            let url = URL + "/" + objectId
            request.put(body, url: url, headers: headers, isUdacity: false) { (data, response, error) in
                if error == nil {
                    completionHandlerForUpsertStudentLocation(success: true, error: nil)
                } else {
                    print("error returned", error)
                    completionHandlerForUpsertStudentLocation(success: nil, error: "Error upserting student location")
                }
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