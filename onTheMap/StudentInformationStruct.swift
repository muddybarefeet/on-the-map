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
    
    var updatedAt: NSDate?
    var createdAt: NSDate?
    
    init (studentDictionary: NSDictionary) {
        
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "MMM dd, yyyy, HH:mm"
//
//        let updated = studentDictionary["updatedAt"]
//        let created = studentDictionary["createdAt"]
        
//        print( "String(updated.dynamicType) -> \(updated.dynamicType)")

//        if let update = updated {
//            updatedAt = dateFormatter.dateFromString(update as! String)!
//        }
//        if let create = created {
//            createdAt = dateFormatter.dateFromString(create as! String)!
//        }
        
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


