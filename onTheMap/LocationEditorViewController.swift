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

    
    var Parse = ParseClient.sharedInstance()
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    var mapDelegate = MapViewDelegate()
    
    override func viewDidLoad() {
        answerText.textAlignment = .Center
        answerText.delegate = self
        submitButton.layer.cornerRadius = 10
        submitButton.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LocationEditorViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
        //activity spinner
        locationView.delegate = mapDelegate
        activitySpinner.center = self.view.center
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        print("tap gesture fn called")
        answerText.resignFirstResponder()
    }
    
    
    @IBAction func selectLocation(sender: AnyObject) {
        if submitButton.titleLabel?.text == "Plot" {
            self.getLocation(answerText.text!)
        } else if submitButton.titleLabel?.text == "Confirm Location" {
            //change the question and empty the answer box
            answerText.text = ""
            questionLabel.text = "Enter a link to share:"
            submitButton.setTitle("Submit", forState: .Normal)
        } else if submitButton.titleLabel?.text == "Submit" {
            //save the center of the maps coords
            let newCoords = locationView.centerCoordinate
            print("center", newCoords)
            Parse.userData["latitude"] = newCoords.latitude
            Parse.userData["longitude"] = newCoords.longitude
            //make sure there is text in the media URL
            if (answerText.text != "") {
                Parse.userData["mediaURL"] = answerText.text
                Parse.upsertUserLocation() { (success, error) in
                    if (success != nil) {
                        print("Upseted student location", success)
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    } else {
                        print("Error", error)
                        let alertController = UIAlertController(title: "Alert", message: "There was an error updating your details.", preferredStyle: UIAlertControllerStyle.Alert)
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
    
    
    //want these to be moved back to the view controller at some point
    func getLocation (address: String) {
        //show loading spinner
        activitySpinner.startAnimating()
        view.addSubview(activitySpinner)
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil) {
                let alertController = UIAlertController(title: "Alert", message: "There was an reading your address. Please try a different address.", preferredStyle: UIAlertControllerStyle.Alert)
                let Action = UIAlertAction(title: "Try again", style: .Default) { (action:UIAlertAction!) in
                    //just want the alert to go does this automatically
                    print("try again button clicked")
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
                print("coordinates1: ", coordinates)
                self.plotLocation(coordinates)
            }
        })
    }
    
    func geocodeAddressString(addressString: String, completionHandler: CLGeocodeCompletionHandler) {}
    
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

extension LocationEditorViewController: UITextFieldDelegate {

    //here instead of in a delagate because need to access view outlets
    func textFieldDidBeginEditing(textField: UITextField) {
        print("called function to edit")
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


}
