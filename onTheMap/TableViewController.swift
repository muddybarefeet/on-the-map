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
            let cell = tableView.dequeueReusableCellWithIdentifier("infoCell")
            let locationInfo = locations[indexPath.row] as? StudentLocationStruct
            cell?.textLabel?.text = "Things"
            print("location info", locationInfo)
            return cell!
        }
    
    //    //    function for on selecting a cell what to do
    //    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //        let detailController = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
    //        detailController.meme = memes[indexPath.row].memedImage
    //        navigationController?.pushViewController(detailController, animated: true)
    //        
    //    }
    
    
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
