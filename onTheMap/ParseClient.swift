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
    
    static let sharedInstance = ParseClient()
    private init() {}
    
    let request = RequestClient.sharedInstance
    
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
    
    let headers = [
        Constants.ParseParameterKeys.ApplicationID: Constants.ParseParameterValues.ApplicationID,
        Constants.ParseParameterKeys.ApplicationKey: Constants.ParseParameterValues.ApplicationKey
        
    ]
    
    //get the user location object to check the student location
    func getStudentLocation (completionHandlerForCurrentLocation: (data: AnyObject?, error: String?) -> Void) {
        let baseURL = Constants.Parse.baseURL + Constants.Parse.StudentLocation
        let parameterString = "{\"uniqueKey\":\"\(UdacityClient.sharedInstance.userID)\"}"
        
        print("encoding the USER ID......")
        let allowedSet =  NSCharacterSet.URLPathAllowedCharacterSet()
        let escapedString = parameterString.stringByAddingPercentEncodingWithAllowedCharacters(allowedSet)
        let url = baseURL + "?" + Constants.ParseParameterKeys.Where + "=" + escapedString!
        print("encoded------------------>", url)
        request.get(url, headers: headers, isUdacity: false) { (data, response, error) in
            if error == nil {
                guard let results = data!["results"]! else {
                    completionHandlerForCurrentLocation(data: nil, error: "There was no results key in the response")
                    return
                }
                self.objectId = results[0]["objectId"]! as! String
                completionHandlerForCurrentLocation(data: results[0], error: nil)
            } else {
                completionHandlerForCurrentLocation(data: nil, error: error)
            }
        }
    }
    
    //the the locations of all the students
    func getAllStudentLocations (completionHandlerForGetAllLocations: (data: AnyObject?, error: String?) -> Void) {
        let baseURL = Constants.Parse.baseURL + Constants.Parse.StudentLocation
        let parameters = "?" + Constants.ParseParameterKeys.Order + "=" + Constants.ParseParameterValues.UpdatedAt
        let URL = baseURL + parameters
        request.get(URL, headers: headers, isUdacity: false) { (data, response, error) in
            if error == nil {
                guard let results = data!["results"] as? [[String: AnyObject]] else {
                    completionHandlerForGetAllLocations(data: nil, error: "No results key in the return data")
                    return
                }
                self.parseUserLocations(results)
                completionHandlerForGetAllLocations(data: data, error: nil)
                
            } else {
                completionHandlerForGetAllLocations(data: nil, error: error)
            }
        }
    }
    
    //pass student locations to the StudentLocationStruct 
    func parseUserLocations (data: [NSDictionary]) -> Void {
        ////loop through results and pass each one to the struct to reconstruct
        var students = [StudentInformation]()
        for dictionary in data {
            //pass the dictionary to the StudentLocationStruct struct
            let model = StudentInformation(studentDictionary: dictionary)
            students.append(model)
        }
        //then set the students array as the locations in app delegate
        let app = UIApplication.sharedApplication().delegate
        let appDelegate = app as! AppDelegate
        appDelegate.locations = students
    }
    
    //method to post or upate the users location
    func upsertUserLocation (completionHandlerForUpsertStudentLocation: (success: Bool?, error: String?) -> Void) {
        let URL = Constants.Parse.baseURL + Constants.Parse.StudentLocation
        var body = userData
        body["uniqueKey"] = UdacityClient.sharedInstance.userID
        if (upsertMethod == "POST") {
            request.post(body,url: URL,headers: headers,isUdacity: false) { (data, response, error) in
                if error == nil {
                    completionHandlerForUpsertStudentLocation(success: true, error: nil)
                } else {
                    print("error returned", error)
                    completionHandlerForUpsertStudentLocation(success: nil, error: error)
                }
            }
        } else if (upsertMethod == "PUT") {
            let url = URL + "/" + objectId
            request.put(body, url: url, headers: headers, isUdacity: false) { (data, response, error) in
                if error == nil {
                    completionHandlerForUpsertStudentLocation(success: true, error: nil)
                } else {
                    completionHandlerForUpsertStudentLocation(success: nil, error: error)
                }
            }
        }
    }
    
}