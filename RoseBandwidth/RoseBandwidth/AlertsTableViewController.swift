//
//  AlertsTableViewController.swift
//  RoseBandwidth
//
//  Created by Anthony Minardo on 2/7/15.
//  Copyright (c) 2015 edu.rosehulman. All rights reserved.
//

import UIKit
import CoreData


class AlertsTableViewController: UITableViewController {

    var managedObjectContext : NSManagedObjectContext?
    
    var alerts = [Alerts]()


    @IBAction func cellSwitched(sender: UISwitch) {
        var cell  = (sender.superview?.superview?.superview?.superview as! AlertTableViewCell)
        var path = self.tableView.indexPathForCell(cell)
        alerts[path!.row].isEnabled = sender.on
        updateOn(sender, cell: cell)
    }
    
    func updateOn(sender: UISwitch, cell: AlertTableViewCell) {
        if (!sender.on) {
            UIView.animateWithDuration(0.5, animations: {
                cell.backgroundColor = UIColor.groupTableViewBackgroundColor()
                cell.contentView.viewWithTag(5)?.backgroundColor = UIColor.groupTableViewBackgroundColor()
                cell.contentView.viewWithTag(6)?.backgroundColor = UIColor.groupTableViewBackgroundColor()
            })
        } else {
            UIView.animateWithDuration(0.5, animations: {
                cell.backgroundColor = UIColor.whiteColor()
                cell.contentView.viewWithTag(5)?.backgroundColor = UIColor.whiteColor()
                cell.contentView.viewWithTag(6)?.backgroundColor = UIColor.whiteColor()
            })
        }
    }
    
    
    let alertsIdentifier = "Alerts"
    var alertCellIdentifier = "alertsCell"
    let showDetailSegueIdentifier = "showDetailView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        updateAlerts()
        savedManagedObjectContext()
        updateAlerts()
    }

    override func viewDidAppear(animated: Bool) {
        updateAlerts()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateAlerts() {
        
        var loginCredentialsIdentifier = "LoginCredentials"
        let fetchRequest = NSFetchRequest(entityName: loginCredentialsIdentifier)
        
        var error : NSError? = nil
        var credentials = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as! [LoginCredentials]
        
        if error != nil {
            println("There was an unresolved error: \(error?.userInfo)")
            abort()
        }
        
        if (credentials.count > 0){
        
            let fetchRequest = NSFetchRequest(entityName: alertsIdentifier)
        
            var error : NSError? = nil
            alerts = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as! [Alerts]
        
            if error != nil {
                println("There was an unresolved error: \(error?.userInfo)")
                abort()
            }
        
            if (alerts.count > 0) {
                var i = 0
                for alert in alerts {
                    if alert.username != credentials[0].username {
                        alerts.removeAtIndex(i)
                        i--
                    }
                    i++
                }
            }
            
            alerts.sort({
                $0.threshold.floatValue > $1.threshold.floatValue
            })
        }
    }
    
    func savedManagedObjectContext() {
        var error : NSError?
        
        managedObjectContext?.save(&error)
        if error != nil {
            println("There was an unresolved error: \(error?.userInfo)")
            abort()
        }
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return alerts.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(alertCellIdentifier, forIndexPath: indexPath) as! AlertTableViewCell
        // Configure the cell...
        if (alerts[indexPath.row].alertName == "") {
            alerts[indexPath.row].alertName = "0"
        }
        if (alerts[indexPath.row].alertType == "") {
            alerts[indexPath.row].alertType = "%"
        }
        cell.titleLabel.text = "\(alerts[indexPath.row].alertName)\(alerts[indexPath.row].alertType)";
        cell.descLabel.text = "Your data has exceeded your \(alerts[indexPath.row].alertName)\(alerts[indexPath.row].alertType) limit";
        var truth = alerts[indexPath.row].isEnabled as Bool;
        cell.onSwitch.setOn(truth, animated: false)
        updateOn(cell.onSwitch, cell: cell)
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let alertToDelete = alerts[indexPath.row]
            managedObjectContext?.deleteObject(alertToDelete)
            savedManagedObjectContext()
            updateAlerts()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            let newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == showDetailSegueIdentifier {
            if let selectedIndexPath = tableView.indexPathForSelectedRow(){
                let alert = alerts[selectedIndexPath.row]
                (segue.destinationViewController as! AddAlertViewController).viewTitle = "Edit Alert"
                (segue.destinationViewController as! AddAlertViewController).alert = alert
                (segue.destinationViewController as! AddAlertViewController).managedObjectContext = managedObjectContext
            }
        }
    }
    

}
