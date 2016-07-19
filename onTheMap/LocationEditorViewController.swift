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
    
    let TextDelegate = TextFieldDelegate()
//    let MapDelegate = MapViewDelegate()
    
    override func viewDidLoad() {
        submitButton.enabled = false
        answerText.textAlignment = .Center
        answerText.delegate = TextDelegate
        submitButton.layer.cornerRadius = 10
        submitButton.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    @IBAction func selectLocation(sender: AnyObject) {
        print("select location")
        getLocation(answerText.text!)
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
        //update the text in the button to confirm View
        submitButton.setTitle("Confirm Location", forState: .Normal)
        submitButton.sizeToFit()
    }
    
    
}
