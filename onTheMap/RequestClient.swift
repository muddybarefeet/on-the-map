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
    
    static let sharedInstance = RequestClient()
    private init() {}
    
    func get (url: String, headers: [String:String], isUdacity: Bool, completionHandlerForGet: (data: AnyObject?, response: NSHTTPURLResponse?, errorString: String?) -> Void) {
        let request = makeRequest(url, headers: headers, method: "GET", jsonBody:[:])
        sendRequest(request, isUdacity: isUdacity, completionHandlerForRequest: completionHandlerForGet)
    }
    
    func post(jsonBody: [String : AnyObject]?, url: String, headers: [String:String], isUdacity: Bool, completionHandlerForPost: (data: AnyObject?, response: NSHTTPURLResponse?, errorString: String?) -> Void) {
        
        let request = makeRequest(url, headers: headers, method: "POST", jsonBody: jsonBody)
        sendRequest(request, isUdacity: isUdacity, completionHandlerForRequest: completionHandlerForPost)
    }
    
    func put(jsonBody: [String : AnyObject]?, url: String, headers: [String:String], isUdacity: Bool, completionHandlerForPut: (data: AnyObject?, response: NSHTTPURLResponse?, errorString: String?) -> Void) {
        let request = makeRequest(url, headers: headers, method: "PUT", jsonBody: jsonBody)
        sendRequest(request, isUdacity: false, completionHandlerForRequest: completionHandlerForPut)
    }
    
    //no simplification of this code as it is so different from the other methods
    func delete(url: String, completionHandlerForDelete: (data: AnyObject?, response: NSHTTPURLResponse?, error: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        sendRequest(request, isUdacity: true, completionHandlerForRequest: completionHandlerForDelete)
    }
    
    func makeRequest (url: String, headers: [String:String], method: String, jsonBody: [String : AnyObject]?) -> NSURLRequest  {
        //format the url
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        //format headers if there are any
        request.HTTPMethod = method
        if method == "POST" || method == "PUT" {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if headers.count > 0 {
            for (key, value) in headers {
                request.addValue(key, forHTTPHeaderField: value)
            }
        }
        if jsonBody?.count > 0 {
            if let requestBodyDictionary = jsonBody {
                let serealisedBody: NSData?
                do {
                    serealisedBody = try NSJSONSerialization.dataWithJSONObject(requestBodyDictionary, options: [])
                } catch {
                    serealisedBody = nil
                }
                request.HTTPBody = serealisedBody
            }
        }
        return request
    }

    
    func sendRequest (request: NSURLRequest, isUdacity: Bool, completionHandlerForRequest: (data: AnyObject?, response: NSHTTPURLResponse?, errorString: String?) -> Void) {
        
        //check that there is a netwotrk connection
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                if error != nil {
                    completionHandlerForRequest(data: nil, response: nil, errorString: "There was an error sending the request to the server.")
                    return
                }
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    completionHandlerForRequest(data: nil, response: nil, errorString: "The status code returned was not a OK")
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
                    print("Could not parse the response to a readable format")
                    return
                }
                completionHandlerForRequest(data: parsedResult, response: (response as! NSHTTPURLResponse), errorString: nil)
            }
            task.resume()
        } else {
            print("No internet connection")
            completionHandlerForRequest(data: nil, response: nil, errorString: "There was no internet connection found")
        }
        
    }
    
    
    
//    class func sharedInstance() -> RequestClient {
//        struct Singleton {
//            static var sharedInstance = RequestClient()
//        }
//        return Singleton.sharedInstance
//    }
    
}
