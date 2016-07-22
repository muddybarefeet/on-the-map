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
                //then make the annotations
                self.makeAnnotationsArray()
            } else {
                //error from request
                print("error", error)
                let alertController = UIAlertController(title: "Alert", message: "There was an error getting all users locations. Try hitting the refresh button.", preferredStyle: UIAlertControllerStyle.Alert)
                let Action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                alertController.addAction(Action)
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.presentViewController(alertController, animated: true, completion:nil)
                }
                
            }
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = MapDelegate
    }
    
    func makeAnnotationsArray () {
        
        let app = UIApplication.sharedApplication().delegate
        let appDelegate = app as! AppDelegate
        
        var annotations = [MKPointAnnotation]()
        
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
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }
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
                let alertController = UIAlertController(title: "Alert", message: "For some reason this button is not available at the current time. Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                let Action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                alertController.addAction(Action)
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.presentViewController(alertController, animated: true, completion:nil)
                }
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