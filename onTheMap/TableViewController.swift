//
//  TableViewController.swift
//  onTheMap
//
//  Created by Anna Rogers on 7/17/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class TableViewController: UITableViewController {
    
    var Udacity = UdacityClient.sharedInstance()
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    var locations: [StudentInformation] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).locations
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView!.reloadData()
        activitySpinner.center = self.view.center
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    
    // function to tell the cell what it is
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("infoCell") as UITableViewCell!
        let locationInfo = locations[indexPath.row]
        cell.textLabel?.text = locationInfo.firstName + " " + locationInfo.lastName
        return cell
        
    }

    //function for on selecting a cell what to do
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellClicked = locations[indexPath.row]
        let app = UIApplication.sharedApplication()
        var mediaURL = cellClicked.mediaURL
        if (mediaURL.hasPrefix("www")) {
            //add https:// to the front if they do not have this
            let urlPrefix = mediaURL.startIndex.advancedBy(0)..<mediaURL.endIndex.advancedBy(-8)
            mediaURL.replaceRange(urlPrefix, with: "https://")
        }
        let nsURL = NSURL(string: mediaURL)!
        let isOpenable = app.canOpenURL(nsURL)
        print("IS Openable", isOpenable, mediaURL)
        if isOpenable {
            app.openURL(nsURL)
        } else {
            //throw an alert!
            let alertController = UIAlertController(title: "Alert", message: "This URL was not openable.", preferredStyle: UIAlertControllerStyle.Alert)
            let Action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                //this clears the alert
            }
            alertController.addAction(Action)
//            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.presentViewController(alertController, animated: true, completion:nil)
//            }
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
                print("Error in logout",error)
            }
        }
    }
    
}
