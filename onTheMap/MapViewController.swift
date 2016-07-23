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
        mapView.delegate = MapDelegate
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
        Parse.getAllStudentLocations() { (data, error) in
            if error == nil {
                self.makeAnnotationsArray()
            } else {
                //error from request
                print("error", error)
                let alertController = UIAlertController(title: "Alert", message: "There was an error getting all users locations. Try hitting the refresh button.", preferredStyle: UIAlertControllerStyle.Alert)
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
        
        let app = UIApplication.sharedApplication().delegate
        let appDelegate = app as! AppDelegate
        
        for dictionary in appDelegate.locations {
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
                        let alertController = UIAlertController(title: "You already have a location set.", message: "Do you want to update this?", preferredStyle: UIAlertControllerStyle.Alert)
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
                let alertController = UIAlertController(title: "Alert", message: "For some reason this button is not available at the current time. Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                let Action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                    //this clears the alert
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
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
                self.presentViewController(controller, animated: true, completion: nil)
                self.activitySpinner.stopAnimating()
                self.view.willRemoveSubview(self.activitySpinner)
            } else {
                print("error in logout", error)
            }
        }
    }
}