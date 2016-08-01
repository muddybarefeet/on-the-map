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
    
    var Parse = ParseClient.sharedInstance
    var Udacity = UdacityClient.sharedInstance
    
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    var annotations = [MKPointAnnotation]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //get the user locations
        updateLocations()
        activitySpinner.center = self.view.center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    @IBAction func refresh(sender: AnyObject) {
        updateLocations()
    }
    
    func updateLocations () {
        mapView.removeAnnotations(annotations)
        //get all the latest student locations
        getAllLocations()
    }
    
    func getAllLocations () {
        Parse.getAllStudentLocations () { (success, error) in
            if error == nil {
                self.makeAnnotationsArray()
            } else {
                //error from request
                print("error", error)
                let alertController = UIAlertController(title: "Alert", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                let Action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                    print("okay button")
                }
                alertController.addAction(Action)
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.presentViewController(alertController, animated: true, completion:nil)
                }
                
            }
        }
    }
    
    func makeAnnotationsArray () {
        
        let students = StudentLocations.sharedInstance
        for dictionary in students.locations {
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: dictionary.latitude, longitude: dictionary.longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = dictionary.firstName + " " + dictionary.lastName
            annotation.subtitle = dictionary.mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        //once the annotations array has been filled then add to the map view
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.addAnnotations(self.annotations)
        }

    }
    
    
    @IBAction func addLocation(sender: AnyObject) {
        Parse.getStudentLocation() { (data, error) in
            if error == nil {
                if let data = data {
                    if data.count > 0 {
                        let alertController = UIAlertController(title: "Notice", message: "You already have a set location. Would you like to update this?", preferredStyle: UIAlertControllerStyle.Alert)
                        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action:UIAlertAction!) in
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                //this clears the alert
                            }
                        }
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
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
                let alertController = UIAlertController(title: "Alert", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                let Action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                }
                alertController.addAction(Action)
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.presentViewController(alertController, animated: true, completion:nil)
                }
            }
        }
    }
    
    @IBAction func logout(sender: AnyObject) {
        activitySpinner.startAnimating()
        view.addSubview(activitySpinner)
        Udacity.logout() { (success, error) in
            if (success != nil) {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.activitySpinner.stopAnimating()
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.view.willRemoveSubview(self.activitySpinner)
                }
            } else {
                let alertController = UIAlertController(title: "Alert", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                let Action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                }
                alertController.addAction(Action)
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.presentViewController(alertController, animated: true, completion:nil)
                }
            }
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    // method to place the pin on the map and how it is styled
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            //tell the pin if extra information can be show about the pin boolean
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            //view to display on the right side of the standard callout bubble
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    //on click of a pin, open the url in the subtitle
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if var mediaURL = (view.annotation?.subtitle!)! as String? {
                if (mediaURL.hasPrefix("www")) {
                    //add https:// to the front if they do not have this
                    mediaURL = "https://" + mediaURL
                }
                let nsURL = NSURL(string: mediaURL)!
                let isOpenable = app.canOpenURL(nsURL)
                if isOpenable {
                    app.openURL(nsURL)
                } else {
                    let alertController = UIAlertController(title: "Alert", message: "This URL was not openable", preferredStyle: UIAlertControllerStyle.Alert)
                    let Action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                        //this clears the alert
                    }
                    alertController.addAction(Action)
                    presentViewController(alertController, animated: true, completion:nil)
                }
            }
        }
    }
    
}