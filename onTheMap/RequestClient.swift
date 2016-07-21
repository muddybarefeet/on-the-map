//
//  RequestClient.swift
//  onTheMap
//
//  Created by Anna Rogers on 7/19/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import Foundation
import UIKit

class RequestClient {
    
    func get (baseURL: String, headers: [String:String], isUdacity: Bool, completionHandlerForGet: (data: AnyObject?, response: NSHTTPURLResponse?, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL)!)
        //add any headers?
        if headers.count > 0 {
            print("adding headers")
            for (key, value) in headers {
                request.addValue(key, forHTTPHeaderField: value)
            }
        }
        sendRequest(request, isUdacity: isUdacity, completionHandlerForRequest: completionHandlerForGet)
    }
    
    func post(jsonBody: String, baseURL: String, headers: [String:String], isUdacity: Bool, completionHandlerForPost: (data: AnyObject?, response: NSHTTPURLResponse?, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if headers.count > 0 {
            print("adding headers")
            for (key, value) in headers {
                request.addValue(key, forHTTPHeaderField: value)
            }
        }
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        print("BODY", jsonBody.dataUsingEncoding(NSUTF8StringEncoding))
        sendRequest(request, isUdacity: isUdacity, completionHandlerForRequest: completionHandlerForPost)
    }
    
    func sendRequest (request: NSURLRequest, isUdacity: Bool, completionHandlerForRequest: (data: AnyObject?, response: NSHTTPURLResponse?, errorString: String?) -> Void) {
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandlerForRequest(data: nil, response: nil, errorString: "There was an error in the reqest sent!")
                return
            }
            
            guard let data = data else {
                completionHandlerForRequest(data: nil, response: nil, errorString: "There was no data in the response")
                return
            }
            
            let newData:NSData
            //see if need to remove the first few characters or not
            if isUdacity {
                newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            } else {
                newData = data
            }
            
            var parsedResult: AnyObject?
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
        
            completionHandlerForRequest(data: parsedResult, response: (response as! NSHTTPURLResponse), errorString: nil)
            //return the parsed result
            
        }
        
        task.resume()
        
    }
    
    
    class func sharedInstance() -> RequestClient {
        struct Singleton {
            static var sharedInstance = RequestClient()
        }
        return Singleton.sharedInstance
    }
    

    
    
    
}
