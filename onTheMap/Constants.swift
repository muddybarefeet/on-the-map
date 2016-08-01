//
//  Constants.swift
//  onTheMap
//
//  Created by Anna Rogers on 7/19/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import Foundation
import UIKit

class Constants {
    
    struct Parse {
        static let baseURL = "https://api.parse.com/1/classes/"
        static let StudentLocation = "StudentLocation"
    }
    
    struct Udacity {
        static let baseURL = "https://www.udacity.com/api/"
        static let Session = "session"
        static let Users = "users/"
        static let UdacitySignUp = "https://www.udacity.com/account/auth#!/signup"
    }
    
    struct ParseParameterKeys {
        static let ApiKey = "api_key"
        static let Order = "order"
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ApplicationKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let Where = "where"
        static let Limit = "limit"
    }

    
    struct UdacityParameterKeys {
        static let JSONField = "application/json"
    }
    
    
    struct UdacityParameterValues {
        static let AcceptJSON = "Accept"
        static let ContentType = "Content-Type"
    }
    
    struct ParseParameterValues {
        static let ApplicationID = "X-Parse-Application-Id"
        static let ApplicationKey = "X-Parse-REST-API-Key"
        static let UpdatedAt = "-updatedAt"
        static let OneHundred = "100"
    }
    
    struct ParseResponseKeys {
        static let Title = "title"
        static let ID = "id"
    }
    
}