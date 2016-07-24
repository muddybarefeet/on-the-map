//
//  LocationEditorViewController.swift
//  onTheMap
//
//  Created by Anna Rogers on 7/18/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class LocationEditorViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerText: UITextField!
    @IBOutlet weak var locationView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var questionView: UIView!

    
    var Parse = ParseClient.sharedInstance
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var mapDelegate = MapViewDelegate()
    
    override func viewDidLoad() {
        styleView()
        //activity spinner
        locationView.delegate = mapDelegate
        activitySpinner.center = self.view.center
        answerText.delegate = self
    }
    
    func styleView () {
        answerText.textAlignment = .Center
        submitButton.layer.cornerRadius = 10
        submitButton.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        questionLabel.font = UIFont (name: "HelveticaNeue-Light", size: 18)
        let gradient: CAGradientLayer = CAGradientLayer().turquoiseColor()
        gradient.frame = questionView.bounds
        questionView.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    @IBAction func selectLocation(sender: AnyObject) {
        if submitButton.titleLabel?.text == "Plot" {
            answerText.resignFirstResponder()
            self.getLocation(answerText.text!)
        } else if submitButton.titleLabel?.text == "Confirm Location" {
            //change the question and empty the answer box
            answerText.text = ""
            questionLabel.text = "Enter a link to share:"
            submitButton.setTitle("Submit", forState: .Normal)
        } else if submitButton.titleLabel?.text == "Submit" {
            //save the center of the maps coords
            let newCoords = locationView.centerCoordinate
            Parse.userData["latitude"] = newCoords.latitude
            Parse.userData["longitude"] = newCoords.longitude
            //make sure there is text in the media URL
            if (answerText.text != "") {
                Parse.userData["mediaURL"] = answerText.text
                Parse.upsertUserLocation() { (success, error) in
                    if (success != nil) {
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    } else {
                        let alertController = UIAlertController(title: "Alert", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                        let Action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                            //this clears the alert
                        }
                        alertController.addAction(Action)
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.presentViewController(alertController, animated: true, completion:nil)
                        }
                    }
                }
            } else {
                let alertController = UIAlertController(title: "Alert", message: "There was no site address entered. Please add a site URL of your choice.", preferredStyle: UIAlertControllerStyle.Alert)
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
    
    
    func getLocation (address: String) {
        //show loading spinner
        activitySpinner.startAnimating()
        view.addSubview(activitySpinner)
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil) {
                let alertController = UIAlertController(title: "Alert", message: "Unable to find this location", preferredStyle: UIAlertControllerStyle.Alert)
                let Action = UIAlertAction(title: "Try again", style: .Default) { (action:UIAlertAction!) in
                }
                alertController.addAction(Action)
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.presentViewController(alertController, animated: true, completion:nil)
                }
            }
            if let placemark = placemarks?.first {
                //get back the location, convert to coordinates and then send to be plotted
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                //save the addressString
                self.Parse.userData["mapString"] = address
                self.plotLocation(coordinates)
            }
        })
    }
    
    func plotLocation(coords: CLLocationCoordinate2D) {
        //move the map view to the right place
        let latDelta:CLLocationDegrees = 1.0
        let longDelta:CLLocationDegrees = 1.0
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let pointLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(coords.latitude, coords.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(pointLocation, theSpan)
        locationView.setRegion(region, animated: true)
        
        //drop the pin in the correct location no wanted removed method to try using static pin
        //let dropPin = MKPointAnnotation()
        //dropPin.coordinate = coords
        //dropPin.title = self.answerText.text
        //self.locationView.addAnnotation(dropPin)
        
        //SAVE THE coords in the click of the final submit button
        submitButton.setTitle("Confirm Location", forState: .Normal)
        //stop activity spinner
        activitySpinner.stopAnimating()
        view.willRemoveSubview(activitySpinner)
    }

    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension LocationEditorViewController: UITextFieldDelegate, MKMapViewDelegate {

    //here instead of in a delagate because need to access view outlets
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
        if submitButton.titleLabel?.text == "Confirm Location" {
            //if the button label confirm and the user tries to edit the button then reset the button label to plot so the location can be reset
            submitButton.setTitle("Plot", forState: .Normal)
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var newText: NSString
        newText = textField.text!
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
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
    
}
