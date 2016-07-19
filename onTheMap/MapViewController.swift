//
//  MapViewController.swift
//  onTheMap
//
//  Created by Anna Rogers on 7/17/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var refreshBtn: UIBarButtonItem!
    @IBOutlet weak var pinBtn: UIBarButtonItem!
    
    let MapDelegate = MapViewDelegate()
    
    var locations = [[String:AnyObject]]()
    //TODO: make the map refresh??
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        //here we will call the method to query the Parse API for the data for the map
        // 1.set parameters
        let parameters = [
           Constants.ParseParameterKeys.Order: Constants.ParseParameterValues.UpdatedAt
        ]
        // 2.build URL and Configure request
        let request = NSMutableURLRequest(URL: tmdbURLFromParameters(parameters))
        print("url", request)
        request.addValue(Constants.ParseParameterValues.ApplicationID, forHTTPHeaderField: Constants.ParseParameterKeys.ApplicationID)
        request.addValue(Constants.ParseParameterValues.ApiKey, forHTTPHeaderField: Constants.ParseParameterKeys.ApplicationKey)
        
        // 3. Make request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            
            guard error == nil else {
                print("There was an error in the request")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print("There was a status code other than 2xx returned!")
                return
            }
            
            guard let data = data else {
                print("Undable to read the data returned")
                return
            }
            
            var parsedResult: AnyObject?
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                print("Could not parse the data")
                return
            }
            
            //returned data is an array of objects
            guard let results = parsedResult!["results"] as? [[String: AnyObject]] else {
                print("no results key in data")
                return
            }
            
            //check values in results
            if results.count > 0 {
                for result in results {
                    self.locations.append(result)
                }
                self.makeAnnotationsArray()
            }
            
        }
        // 4. start request
        task.resume()
        
    }
    
//    function to create the URL
    func tmdbURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        let components = NSURLComponents()
        components.scheme = Constants.Parse.ApiScheme
        components.host = Constants.Parse.ApiHost
        components.path = Constants.Parse.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.URL!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = MapDelegate
    }
    
    func makeAnnotationsArray () {
        
        var annotations = [MKPointAnnotation]()
        
        for dictionary in locations {
            
            let studentLocation = StudentLocationStruct(
                lat: CLLocationDegrees((dictionary["latitude"] as? Double)!),
                long: CLLocationDegrees((dictionary["longitude"] as? Double)!),
                first: dictionary["firstName"] as! String,
                last: dictionary["lastName"] as! String,
                mediaURL: dictionary["mediaURL"] as? String
            )
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: studentLocation.lat, longitude: studentLocation.long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = studentLocation.first + " " + studentLocation.last
            annotation.subtitle = studentLocation.mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        //once the annotations array has been filled then add to the map view
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.addAnnotations(annotations)
        }
        
        
    }
    
    @IBAction func addLocation(sender: AnyObject) {
        
        //TODO LATER: add a check to see if the logged in user is already in the data from parse
        
        //function to add the loaction of the user to the locations array
        
        //1. on click show a modal view
        //2. in view have a text field to add a location and a label to ask the question and button "Find on the Map"
        //3. on click of find on the map then go to new view
        
    }
    
}
