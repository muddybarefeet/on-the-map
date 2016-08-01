//
//  StudentLocationsStruct.swift
//  onTheMap
//
//  Created by Anna Rogers on 8/1/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit

struct StudentLocationsStruct {
    
    //singleton
    static let sharedInstance = StudentLocationsStruct()
    private init() {}
    
    //place to store all the student locations
    var locations = [StudentInformation]()
    
}
