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
//    var Parse = ParseClient.sharedInstance()
    
    var locations = [[String:AnyObject]]()
    //TODO: make the map refresh??
    
    override func viewWillAppear(animated: Bool) {
        print("IN map")
        super.viewWillAppear(animated)
        
        //get the user locations
        ParseClient.sharedInstance().getAllStudentLocations()
        
        
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
//        Parse.getStudentLocation()
        
        //function to add the loaction of the user to the locations array
        
        //1. on click show a modal view
        //2. in view have a text field to add a location and a label to ask the question and button "Find on the Map"
        //3. on click of find on the map then go to new view
        
    }
    
}