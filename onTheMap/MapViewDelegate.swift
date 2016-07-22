//
//  MapViewDelegate.swift
//  onTheMap
//
//  Created by Anna Rogers on 7/18/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit
import MapKit

class MapViewDelegate: NSObject, MKMapViewDelegate {
    
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
//            pinView?.draggable = true

        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
//    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
//        print("dragging")
//        
////        if newState == MKAnnotationViewDragState.Ending {
////            let ann = view.annotation
////            print("annotation dropped at: \(ann!.coordinate.latitude),\(ann!.coordinate.longitude)")
////        }
////        switch newState {
////        case .Starting:
////            print("start drag")
////            view.dragState = .Dragging
////        case .Ending, .Canceling:
////            print("stop drag")
////            view.dragState = .None
////        default: break
////        }
//    }
    
    //on click of a pin, open the url in the subtitle
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //check that the annotation is on the right like we set
        if control == view.rightCalloutAccessoryView {
            //Returns the singleton app instance.
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    
}
