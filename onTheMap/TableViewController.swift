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
    
//    cell reuse identifier = infoCell
    var Udacity = UdacityClient.sharedInstance()
    
    var locations: [StudentLocationStruct] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).locations
    }
    
    override func viewWillAppear(animated: Bool) {
        print("IN table")
//        tableView!.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(locations.count)
        return locations.count
    }
    
    
        //    function to tell the cell what it is
        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("infoCell") as UITableViewCell!
            let locationInfo = locations[indexPath.row]
            //what is a subscript member?
            print("row", indexPath.row)
            print(locationInfo.firstName)
            cell.textLabel?.text = locationInfo.firstName + " " + locationInfo.lastName
            return cell
            
        }
    
        //MAKE A LINK CLICKABLE
        //    function for on selecting a cell what to do
        override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let cellClicked = locations[indexPath.row]
            let app = UIApplication.sharedApplication()
            let mediaURL = cellClicked.mediaURL
            app.openURL(NSURL(string: mediaURL)!)
        }
    
    
    @IBAction func logout(sender: AnyObject) {
        Udacity.logout() { (success, error) in
            if (success != nil) {
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
                self.presentViewController(controller, animated: true, completion: nil)
            } else {
                print("Error in logout",error)
            }
        }
    }
    
}
