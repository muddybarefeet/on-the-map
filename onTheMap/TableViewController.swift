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
    var Parse = ParseClient.sharedInstance()
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
    
    @IBAction func editLocation(sender: AnyObject) {
        Parse.getStudentLocation() { (data, error) in
            if error == nil {
                if let data = data {
                    if data.count > 0 {
                        let alertController = UIAlertController(title: "Warning", message: "You already have a set location. Would you like to update this?", preferredStyle: UIAlertControllerStyle.Alert)
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
                    //this clears the alert
                }
                alertController.addAction(Action)
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.presentViewController(alertController, animated: true, completion:nil)
                }
            }
        }
    }
    
    @IBAction func refresh(sender: AnyObject) {
        //update the locations array and then reload the data
        Parse.getAllStudentLocations() { (data, error) in
            if error == nil {
                self.tableView!.reloadData()
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
    
}

