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
    
    var userID: String = ""
    var sessionID: String = ""
    var sessionExp: String = ""
    
    var user: [String:String] = [
        "firstName": "",
        "lastName": ""
    ]
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    
}
