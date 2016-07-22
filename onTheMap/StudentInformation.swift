//
//  StudentLocationStruct.swift
//  onTheMap
//
//  Created by Anna Rogers on 7/18/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit

struct StudentLocationStruct {
    
    var firstName: String
    var lastName: String
    var mapString: String
    var latitude: Double
    var longitude: Double
    var mediaURL: String
    
    var objectId: String
    var uniqueKey: String
    
//    var updatedAt: String
//    var createdAt: String
    
    init (studentDictionary: NSDictionary) {
        
//        let dateFormatter = NSDateFormatter()
//        //MMM dd, yyyy, HH:mm
//        dateFormatter.dateFormat = "MMM dd, yyyy, HH:mm"
        
//        var updated = studentDictionary["updatedAt"]
//        var created = studentDictionary["createdAt"]
//        
//        print("updated", updated)
//        print("created", created)
//        if let update = updated {
//            updatedAt = dateFormatter.dateFromString(update)!
//        }
//        if let create = updated {
//            createdAt = dateFormatter.dateFromString(create)!
//        }
        
        firstName = (studentDictionary["firstName"] as? String)!
        lastName = (studentDictionary["lastName"] as? String)!
        mapString = studentDictionary["mapString"] as! String
        latitude = studentDictionary["latitude"] as! Double
        longitude = studentDictionary["longitude"] as! Double
        mediaURL = studentDictionary["mediaURL"] as! String
        objectId = studentDictionary["objectId"] as! String
        uniqueKey = studentDictionary["uniqueKey"] as! String
        //format the dates
//        updatedAt = studentDictionary["updatedAt"] as! String
//        createdAt = studentDictionary["createdAy"] as! String
    
    }
    
    
}
