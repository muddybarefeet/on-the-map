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
    var Parse = ParseClient.sharedInstance()
    var Udacity = UdacityClient.sharedInstance()
    
    
    override func viewWillAppear(animated: Bool) {
        print("IN map")
        super.viewWillAppear(animated)
        
        //get the user locations
        Parse.getAllStudentLocations() { (data, error) in
            if error == nil {
                //then the data came back successfully
                self.makeAnnotationsArray()
            } else {
                //error from request
                print("THERE WAS AN ERROR GETTING LOCATION DATA FOR ALL")
            }
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = MapDelegate
    }
    
    func makeAnnotationsArray () {
        
        var annotations = [MKPointAnnotation]()
        
        for dictionary in Parse.locations {
            
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
        
        Parse.getStudentLocation() { (data, error) in
            if error == nil {
                if let data = data {
                    if data.count > 0 {
                        //show the ALERT to see if the user wants to edit the location already posted
                        let alertController = UIAlertController(title: "You already have a location set", message: "Do you want to update this?", preferredStyle: UIAlertControllerStyle.Alert)
                        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action:UIAlertAction!) in
                            print("you have pressed the Cancel button");
                            //TODO
                        }
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                            print("you have pressed OK button");
                            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LocationEditorView")
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                self.Parse.upsertMethod = "PUT"
                                self.presentViewController(controller, animated: true, completion: nil)
                            }
                        }
                        alertController.addAction(cancelAction)
                        alertController.addAction(OKAction)
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.presentViewController(alertController, animated: true, completion:nil)
                        }
                    } else {
                        //segue to the editor controller
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LocationEditorView") 
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                             self.Parse.upsertMethod = "POST"
                            self.presentViewController(controller, animated: true, completion: nil)
                        }
                    }
                }
            } else {
                print("error", error)
            }
        }
        
        
    }
    
    @IBAction func logout(sender: AnyObject) {
        Udacity.logout() { (success, error) in
            if (success != nil) {
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
                self.presentViewController(controller, animated: true, completion: nil)
            } else {
                print("error in logout", error)
            }
        }
    }
}