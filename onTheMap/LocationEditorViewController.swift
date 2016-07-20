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

class LocationEditorViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerText: UITextField!
    @IBOutlet weak var locationView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    var Parse = ParseClient.sharedInstance()
    
    let TextDelegate = TextFieldDelegate()
//    let MapDelegate = MapViewDelegate()
    
    override func viewDidLoad() {
        submitButton.enabled = false
        answerText.textAlignment = .Center
        answerText.delegate = TextDelegate
        submitButton.layer.cornerRadius = 10
        submitButton.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications () {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LocationEditorViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        submitButton.enabled = true
    }
    
    
    
    @IBAction func selectLocation(sender: AnyObject) {
        if submitButton.titleLabel?.text == "Plot" {
            self.getLocation(answerText.text!)
        } else if submitButton.titleLabel?.text == "Confirm Location" {
            //change the question
            answerText.text = ""
            questionLabel.text = "Enter a link to share:"
            submitButton.setTitle("Submit", forState: .Normal)
        } else if submitButton.titleLabel?.text == "Submit" {
            //save the link and return to the main screen
            //make sure there is text in the media URL
            if (questionLabel.text != "") {
                Parse.userData["mediaURL"] = answerText.text
                dismissViewControllerAnimated(true, completion: nil)
                print("user",Parse.userData)
            } else {
                //TODO make this an error make the button disabled?
                print("There was no site address entered. Please add a site URL")
            }
        }
    }
    
    //want these to be moved back to the view controller at some point
    func getLocation (address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil) {
                print("Error", error)
            }
            if let placemark = placemarks?.first {
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                //save the addressString
                self.Parse.userData["mapString"] = address
                self.plotLocation(coordinates)
            }
        })
    }
    
    func geocodeAddressString(addressString: String, completionHandler: CLGeocodeCompletionHandler) {}
    
    func plotLocation(coords: CLLocationCoordinate2D) {
        //move the map view to the right place
        let latDelta:CLLocationDegrees = 0.1
        let longDelta:CLLocationDegrees = 0.1
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let pointLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(coords.latitude, coords.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(pointLocation, theSpan)
        locationView.setRegion(region, animated: true)
        
        //drop the pin in the correct location
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = coords
        dropPin.title = self.answerText.text
        self.locationView.addAnnotation(dropPin)
        //SAVE THE coords
        Parse.userData["latitude"] = coords.latitude
        Parse.userData["longitude"] = coords.longitude
        
        submitButton.setTitle("Confirm Location", forState: .Normal)
        
    }
    
    
}
