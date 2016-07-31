//
//  StudentInformationStruct.swift
//  onTheMap
//
//  Created by Anna Rogers on 7/22/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit

struct StudentInformation {
    
    var firstName: String
    var lastName: String
    var mapString: String
    var latitude: Double
    var longitude: Double
    var mediaURL: String
    
    var objectId: String
    var uniqueKey: String
    
    init (studentDictionary: NSDictionary) {
        
        firstName = (studentDictionary["firstName"] as? String)!
        lastName = (studentDictionary["lastName"] as? String)!
        mapString = studentDictionary["mapString"] as! String
        latitude = studentDictionary["latitude"] as! Double
        longitude = studentDictionary["longitude"] as! Double
        mediaURL = studentDictionary["mediaURL"] as! String
        objectId = studentDictionary["objectId"] as! String
        uniqueKey = studentDictionary["uniqueKey"] as! String
        
    }
    
    
}


