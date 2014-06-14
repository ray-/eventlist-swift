//
//  MasterViewController.swift
//  CalendarList
//
//  Created by Mendoza, Ray on 6/13/14.
//  Copyright (c) 2014 Mendoza, Ray. All rights reserved.
//

import UIKit
import EventKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var events = NSMutableArray()
    var store : EKEventStore = EKEventStore()

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.endIndex-1].topViewController as? DetailViewController
        }
        store.requestAccessToEntityType(EKEntityTypeEvent, completion: { (Bool granted, NSError error) in
            if granted {
                self.loadInitialData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        if events == nil {
            events = NSMutableArray()
        }
        events.insertObject(NSDate.date(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    // #pragma mark - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let indexPath = self.tableView.indexPathForSelectedRow()
            let object = events[indexPath.row] as EKEvent
            ((segue.destinationViewController as UINavigationController).topViewController as DetailViewController).detailItem = object
        }
    }

    // #pragma mark - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func loadInitialData() {
        let calendar = NSCalendar.currentCalendar()
        let oneDayAgoComponents = NSDateComponents()
        let oneYearFromNowComponents = NSDateComponents()

        oneDayAgoComponents.day = -1
        oneYearFromNowComponents.year = 1
            

        let oneDayAgo = calendar.dateByAddingComponents(oneDayAgoComponents, toDate: NSDate(), options: nil )
        let oneYearFromNow = calendar.dateByAddingComponents(oneYearFromNowComponents, toDate: NSDate(), options: nil)
        let predicate = store.predicateForEventsWithStartDate(oneDayAgo, endDate: oneYearFromNow, calendars: nil)
        
        let eventsFound = store.eventsMatchingPredicate(predicate)
        events.addObjectsFromArray(eventsFound)
        
    }
 
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let event = events[indexPath.row] as EKEvent
        cell.textLabel.text = event.title
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            events.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            let object = events[indexPath.row] as EKEvent
            self.detailViewController!.detailItem = object
        }
    }


}

