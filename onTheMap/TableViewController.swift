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
    var annotations = [MKPointAnnotation]()
    
    override func viewWillAppear(animated: Bool) {
        print("IN table")
//        tableView!.reloadData()
    }
    
    
    //    fuction to return the number of cells to make
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(annotations.count)
//        return annotations.count
//    }
//    
//    //    function to tell the cell what it is
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("infoCell")
//        let locationInfo = locations[indexPath.row]
//        print("location info", locationInfo)
//        return cell!
//        
//    }
    
//    //    function for on selecting a cell what to do
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let detailController = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
//        detailController.meme = memes[indexPath.row].memedImage
//        navigationController?.pushViewController(detailController, animated: true)
//        
//    }
    
}
